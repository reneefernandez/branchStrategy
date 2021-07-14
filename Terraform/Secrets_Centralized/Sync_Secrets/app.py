import boto3
import argparse
import json
import sys

from botoappc.exceptions import ClientError


def set_secret(src_secret_value, dst_name, dst_profile, region_name):

    print(f"Setting secret: {dst_name}")

    session = boto3.session.Session(profile_name=dst_profile)
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name,        
    )

    response = client.put_secret_value(
        SecretId=dst_name,
        SecretString=src_secret_value
    )
    
    
def get_secret(secret_name, region_name, profile_name):

    print(f"Getting secret value from: {secret_name}")

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
    else:
        # Secrets Manager decrypts the secret value using the associated KMS CMK
        # Depending on whether the secret was a string or binary, only one of these fields will be populated
        if 'SecretString' in get_secret_value_response:
            text_secret_data = get_secret_value_response['SecretString']
        else:
            binary_secret_data = get_secret_value_response['SecretBinary']

        return text_secret_data or binary_secret_data

def get_secret_profile(secret_name, region_name):

    print(f"Getting secret profile for: {secret_name}")

    profile_list = [
        "sharedservices",
        "latest",
        "production"
    ]
    for profile_name in profile_list:
        session = boto3.session.Session(profile_name=profile_name)
        client = session.client(
            service_name='secretsmanager',
            region_name=region_name,        
        )

        try:
            response = client.describe_secret(
                SecretId=secret_name
            )

            if response:
                return profile_name
        except:
            print(f"{secret_name} not found in {profile_name} account")

def backup_secret_to_file(secret_name, secret_value):

    print(f"Backing up secret: {secret_name}")

    with open(f"{secret_name}.json", 'w') as outfile:
        json.dump(json.loads(secret_value), outfile, indent=4, sort_keys=True)


def compare_secrets(src_secret, dst_secret):

    print("Verifying secrets are set correctly...")
    if src_secret == dst_secret:
        print("Secrets match!")
    else:
        print("Secrets do not match. Something went wrong. Please check secret manager values.")
        sys.exit(1)

def get_env_components(environment, component):
    # TODO: Impliment syncing compnenents from environment lambda
    pass

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Sync some secrets.')
    parser.add_argument('-s','--src_secret_name', help='src secret name')
    parser.add_argument('-d','--dst_secret_name', help='destination secret name')
    parser.add_argument('-e','--environment', help='environment to sync')
    parser.add_argument('-c','--component', help='component to sync')
    parser.add_argument('-r', '--region', help='aws region')

    args = parser.parse_args()

    src_secret_name = args.src_secret_name
    dst_secret_name = args.dst_secret_name
    if args.src_secret_name and args.dst_secret_name:
        src_secret_name = args.src_secret_name
        dst_secret_name = args.dst_secret_name
    elif args.environment and args.component:
        src_secret_name, dst_secret_name = get_env_components(args.environment, args.component)

    region_name = args.region

    src_profile = get_secret_profile(src_secret_name, region_name)
    dst_profile = get_secret_profile(dst_secret_name, region_name)

    src_secret = get_secret(src_secret_name, region_name, src_profile)
    dst_secret = get_secret(dst_secret_name, region_name, dst_profile)
    
    backup_secret_to_file(src_secret_name, src_secret)
    if dst_secret:
        backup_secret_to_file(dst_secret_name, dst_secret)

    set_secret(
        src_secret_value=src_secret,
        dst_name=dst_secret_name,
        dst_profile=dst_profile,
        region_name=region_name
    )
    dst_secret = get_secret(dst_secret_name, region_name, dst_profile)

    compare_secrets(src_secret, dst_secret)
