#!/bin/bash
case $1 in
  Production | Preview)
    prefix_bucket="production"
    echo -n "production"
    ;;
  Staging | Latest)
    prefix_bucket="latest"
    echo -n "latest"
    ;;
  *)
    exit 100
    ;;
esac
echo "------ step 1 ---"
if  mountpoint -q '/var/lib/jenkins/ondemand_envs/EFS_ondemand' ; then
    echo "/var/lib/jenkins/ondemand_envs/EFS_ondemand is a mount point,EFS mounted"
    sudo umount /var/lib/jenkins/ondemand_envs/EFS_ondemand
else
    echo "/var/lib/jenkins/ondemand_envs/EFS_ondemand is not a mount point, waiting for EFS"
fi
echo "------ step 2 ---"
sudo rm -rf /var/lib/jenkins/ondemand_envs/EFS*
sudo rm -rf /var/lib/jenkins/ondemand_envs/Backup*
echo "------ step 3 ---"
Source_Environment="$(curl  https://r0pw71mgn5.execute-api.us-west-2.amazonaws.com/prod/active-env  | jq '.body' | jq ".${1}_appd" | sed -e 's/^\"//g' | sed -e 's/\"//')"
echo "The Source Environment is ------->  $Source_Environment "
echo "------ step 4 ---"
EFS_Name_ondemand="efs-${2}"
ID_EFS_ondemand="$(aws efs describe-file-systems --query "FileSystems[?Name=='$EFS_Name_ondemand'].FileSystemId" --region us-west-2 --profile ${3} | jq '.[0]' | sed -e 's/\"//g')"
echo "ID ondemand EFS is $ID_EFS_ondemand "
IP_EFS_ondemand="$(aws efs describe-mount-targets --max-items 1 --file-system-id $ID_EFS_ondemand --region us-west-2 --profile ${3} | jq '.MountTargets[0].IpAddress' | sed -e 's/\"//g')"
echo "------ step 5 ---"
sudo mkdir -p /var/lib/jenkins/ondemand_envs/EFS_ondemand
sudo mount $IP_EFS_ondemand:/ /var/lib/jenkins/ondemand_envs/EFS_ondemand
echo "folder created and mounted"
echo "------ step 6 ---"
sudo mkdir -p /var/lib/jenkins/ondemand_envs/EFS_Backup
echo "folder to store backups created"
echo "------ step 7 ---"
Current_Date="$(date +%Y-%m-%d)"
echo "source env is $Source_Environment"
Name_Env_Active_Capital="$(echo $Source_Environment | sed 's/.*/\u&/')"
echo $Name_Env_Active_Capital
BK_DB_To_Download="$(aws s3api list-objects --bucket backups-client-${prefix_bucket} --prefix BackupsLandingPage/DatabasesBackups${Name_Env_Active_Capital}/BK_${Name_Env_Active_Capital}_DB_client_${Current_Date} --query "reverse(sort_by(Contents, &LastModified))[*].{Key:Key}" --profile Shared_Services | jq '.[0].Key' | sed -e 's/\"//g')"
BK_Files_To_Download="$(aws s3api list-objects --bucket backups-client-${prefix_bucket} --prefix BackupsLandingPage/FilesBackups${Name_Env_Active_Capital}/BK_${Name_Env_Active_Capital}_Files_client_${Current_Date} --query "reverse(sort_by(Contents, &LastModified))[*].{Key:Key}" --profile Shared_Services | jq '.[0].Key' | sed -e 's/\"//g')"
echo "The name of DB-backup to Download is $BK_DB_To_Download"
echo "The name of Files-backup to Download is $BK_Files_To_Download"
sudo aws s3api get-object --bucket backups-client-$prefix_bucket --key $BK_DB_To_Download /var/lib/jenkins/ondemand_envs/Backup_DB_${prefix_bucket}_${Current_Date}.sql.gz --profile Shared_Services
sudo aws s3api get-object --bucket backups-client-$prefix_bucket --key $BK_Files_To_Download /var/lib/jenkins/ondemand_envs/Backup_Files_${prefix_bucket}_${Current_Date}.tar.gz --profile Shared_Services
echo "step 8"
sudo tar -xzf /var/lib/jenkins/ondemand_envs/Backup_Files_${prefix_bucket}_${Current_Date}.tar.gz -C /var/lib/jenkins/ondemand_envs/EFS_Backup/
sudo gunzip  /var/lib/jenkins/ondemand_envs/Backup_DB_${prefix_bucket}_${Current_Date}.sql.gz
DB_Name="$(aws secretsmanager get-secret-value --secret-id SecretLP-${2} --version-stage AWSCURRENT --region us-west-2 --query SecretString --output text --profile Shared_Services | jq '.DBName' | sed -e 's/\"//g')"
DB_EndPoint="$(aws secretsmanager get-secret-value --secret-id SecretLP-${2} --version-stage AWSCURRENT --region us-west-2 --query SecretString --output text --profile Shared_Services | jq '.EndPoint' | sed -e 's/\"//g')"
DB_Pass="$(aws secretsmanager get-secret-value --secret-id SecretLP-${2} --version-stage AWSCURRENT --region us-west-2 --query SecretString --output text --profile Shared_Services | jq '.PassDB' | sed -e 's/\"//g')"
DB_User="$(aws secretsmanager get-secret-value --secret-id SecretLP-${2} --version-stage AWSCURRENT --region us-west-2 --query SecretString --output text --profile Shared_Services | jq '.UserDB' | sed -e 's/\"//g')"
echo "the database endpoint is $DB_EndPoint"
sudo rsync -aur --delete /var/lib/jenkins/ondemand_envs/EFS_Backup/ /var/lib/jenkins/ondemand_envs/EFS_ondemand/
if [ "$DB_EndPoint" = "$2-rds.client.com" ];then
    echo "Match"
    mysql -h $DB_EndPoint -u $DB_User -p$DB_Pass -e "drop database $DB_Name;"
    mysql -h $DB_EndPoint -u $DB_User -p$DB_Pass -e "create database $DB_Name;"
    mysql -h $DB_EndPoint -u $DB_User -p$DB_Pass $DB_Name < /var/lib/jenkins/ondemand_envs/Backup_DB_${prefix_bucket}_${Current_Date}.sql
else
    echo "error no match"
    echo "you are using $2-rds.client.com, bad name"
    exit 100
fi