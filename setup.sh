#!/bin/bash

function nkloudshowBanner() {
    echo "========================================================================="
    echo "         Welcome NKloud Storage Gateway - by Fatbrain.ai"
    echo "========================================================================="
    echo -e "\n"
    echo "This is a guided setup. Please take a few minutes to carefully make your "
    echo "choices."
    echo -e "\n"
}

function generateRColneConf(){
    echo "[MIN]" > generated_rclone.conf
    echo "type = s3" >> generated_rclone.conf
    echo "provider = Minio" >> generated_rclone.conf
    echo "env_auth = false" >> generated_rclone.conf
    echo "access_key_id = $2" >> generated_rclone.conf
    echo "secret_access_key = $3" >> generated_rclone.conf
    echo "endpoint = http://$1:9000" >> generated_rclone.conf
    echo "acl = bucket-owner-full-control" >> generated_rclone.conf
    echo "#bucketname = $4" >> generated_rclone.conf
    echo -e "Done!\n"
    echo -e "\n"
}

function getS3Confiuration(){
    echo "You will now be asked for Minio host and port seperately..."
    echo -e "\n"
    echo "Please provide Minio host name (DNS name only) here (like so "
    echo "ec2-54-185-122-8.us-west-2.compute.amazonaws.com ):"
    read miniohost
    echo "Please provide Minio access key (like so cmElWxpMjHd3qp0q):"
    read minioaccesskey
    echo "Please provide Minio secret key (like so 4vM1gKR1C5KWgRCuMCi4m3bIekKPlM7y):"
    read miniosecretkey
    echo "Please provide Minio bicket name (like so mybucket):"
    read bucketname

    generateRColneConf $miniohost $minioaccesskey $miniosecretkey $bucketname
    export FBNK_BUCKETNAME=$bucketname
}

function getVirtaulVolumeConf(){
    echo "You will now be asked to enter empty folder names to be used "
    echo "exclusively for the appliance..."
    echo -e "\n"
    echo "Please provide folder name that can hold upto 150 GBs of data"
    echo "for shares here (like so /mnt/vol0):"
    read sharefoldervol
    echo "Please provide folder name that can hold upto 0.1 GBs of data"
    echo "for appliance configuration data here (like so /mnt/vol1):"
    read configfoldervol
    echo "Please provide folder name that can hold upto 2.0 GBs of data"
    echo "for appliance configuration backup here (like so /mnt/vol2):"
    read backupfoldervol

    generateEnvironmentFile $sharefoldervol $configfoldervol $backupfoldervol
    applyChanges $configfoldervol
}

function generateEnvironmentFile(){
    echo "#Environment file for appliance" > generated_env
    echo "FBNK_SHARE=\"$1\"" >> generated_env
    echo "FBNK_CONFIG=\"$2\"" >> generated_env
    echo "FBNK_BACKUP=\"$3\"" >> generated_env
    echo "FBNK_BUCKETNAME=$FBNK_BUCKETNAME" >> generated_env
}

function applyChanges(){
    echo "Your configuration take is completed, if you need do not apply it."
    echo "and run the setup"
    echo "Apply changes now?(y/n):"
    read applychanges
    if [ $applychanges == 'y' ]; then
        cp -f ./generated_env ./.env
        source ./.env
        cp -f ./generated_rclone.conf $1/rclone.conf
    fi
}

nkloudshowBanner
getS3Confiuration
getVirtaulVolumeConf

docker compose up
echo "Attempting to recover from failure... Please stand by it should take just a few more moments."
sleep 10s
didapplstart=$(docker compose ls | grep "stor-gateway")
if [ -z "$didapplstart" ]; then
    sleep 10s
    docker compose up
fi