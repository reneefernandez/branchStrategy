import boto3
import argparse
import json
import sys

from time import sleep
from botoappc.exceptions import ClientError


def update_stack(stack_name, params, region_name, profile_name):

    print(f"Updating stack: {stack_name}")

    if profile_name is None:
        client = boto3.client(
            service_name='cloudformation',
            region_name=region_name,        
        )
    else:
        session = boto3.session.Session(profile_name=profile_name)

        client = session.client(
            service_name='cloudformation',
            region_name=region_name,        
        )

    response = client.update_stack(
        StackName=stack_name,
        UsePreviousTemplate=True,
        Parameters=params,
        Capabilities=[
            'CAPABILITY_IAM','CAPABILITY_NAMED_IAM','CAPABILITY_AUTO_EXPAND',
        ]
    )

    print(response)

    while True:
        describe_response = client.describe_stacks(StackName=stack_name)
        message = describe_response['Stacks'][0]['StackStatus']
        print(describe_response['Stacks'][0]['StackStatus'])
        if "IN_PROGRESS" not in describe_response['Stacks'][0]['StackStatus']:
            break
        sleep(2)


def get_stack_params(stack_name, region_name, profile_name):

    print(f"Describing stack: {stack_name}")

    if profile_name is None:
        client = boto3.client(
            service_name='cloudformation',
            region_name=region_name,        
        )
    else:
        session = boto3.session.Session(profile_name=profile_name)

        client = session.client(
            service_name='cloudformation',
            region_name=region_name,        
        )

    response = client.describe_stacks(
        StackName=stack_name,
    )

    return response['Stacks'][0]['Parameters']


def get_secret(secret_name, region_name, profile_name, set_export):

    if not set_export:
        print(f"Getting secret value from: {secret_name}")

    if profile_name is None:
        client = boto3.client(
            service_name='secretsmanager',
            region_name=region_name,        
        )
    else:
        session = boto3.session.Session(profile_name=profile_name)
        client = session.client(
            service_name='secretsmanager',
            region_name=region_name,        
        )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("The requested secret " + secret_name + " was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("The request had invalid params:", e)
        sys.exit(1)
    else:
        # Secrets Manager decrypts the secret value using the associated KMS CMK
        # Depending on whether the secret was a string or binary, only one of these fields will be populated
        if 'SecretString' in get_secret_value_response:
            text_secret_data = get_secret_value_response['SecretString']
        else:
            binary_secret_data = get_secret_value_response['SecretBinary']

        return text_secret_data or binary_secret_data


def update_secret(dst_secret_name, param_list, profile_name, region_name):
    print(f"Updating secret {dst_secret_name}")
    param_dict = json.dumps({item['ParameterKey']:item['ParameterValue'] for item in param_list}, sort_keys=True)
    # print(param_dict)

    if profile_name is None:
        client = boto3.client(
            service_name='secretsmanager',
            region_name=region_name,        
        )
    else:
        session = boto3.session.Session(profile_name=profile_name)
        client = session.client(
            service_name='secretsmanager',
            region_name=region_name,        
        )

    response = client.put_secret_value(
        SecretId=dst_secret_name,
        SecretString=param_dict,
    )

    print(f"Updated secret: {response}")


def backup_secret_to_file(secret_name, secret_value):

    print(f"Backing up secret: {secret_name}")

    with open(f"{secret_name}.json", 'w') as outfile:
        json.dump(secret_value, outfile, indent=4, sort_keys=True)


def build_sam_param_override(secret_value):
    return ' '.join([f"ParameterKey={k},ParameterValue={v}" for k,v in json.loads(secret_value).items()])

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Services secrets.')
    parser.add_argument('-s','--src_secret_name', help='src secret name')
    parser.add_argument('-ds', '--dst_secret_name', help="dst secret name")
    parser.add_argument('-r', '--region', nargs="?", type=str, default='us-west-2', help='aws region')
    parser.add_argument('-p', '--profile', help='aws stack profile')
    parser.add_argument('-sp', '--secrets_profile', help='aws secrets_profile')
    parser.add_argument('-dsp', '--dst_secrets_profile', help='aws dest secrets_profile')
    parser.add_argument('-o', '--output_file_name', help="output filename")
    parser.add_argument('-gp', '--generate_params', nargs="?", type=bool, const=True, default=False, help="output filename")
    parser.add_argument('-gs', '--get_stack', nargs="?", type=bool, const=True, default=False, help="output filename")
    parser.add_argument('-sn', '--stack_name', help="src stack name")
    parser.add_argument('-usn', '--update_stack_name', help="update_stack_name")


    args = parser.parse_args()

    output_filename = args.output_file_name or args.src_secret_name or 'params'

    if args.get_stack:
        param_list = get_stack_params(args.stack_name, args.region, args.profile)
        if args.dst_secret_name is not None:
            update_secret(args.dst_secret_name, param_list, args.dst_secrets_profile, args.region)
        else:   
            backup_secret_to_file(output_filename, param_list)

    else:
        src_secret = get_secret(args.src_secret_name, args.region, args.secrets_profile, set_export=args.generate_params)


        if args.generate_params:
            print(build_sam_param_override(src_secret))

        elif args.update_stack_name:
            params = [{"ParameterKey":k, "ParameterValue": v} for k,v in json.loads(src_secret).items()]

            stack_name = args.update_stack_name
            update_stack(stack_name, params, args.region, args.profile)
        else:
            print("Incorrect params. Please check parameter values.")