#!/usr/bin/env bash

set -ex


# Adding ECS configuration
echo "ECS_CLUSTER=cb-ecs_cluster-${client_name}" >> /etc/ecs/ecs.config
echo "ECS_BACKEND_HOST=" >> /etc/ecs/ecs.config

# Adding CloudWatch Agent configuration
mkdir -p /etc/cwagentconfig
echo '{"metrics":{"namespace":"${client_name}-CWAgent","metrics_collected":{"disk":{"measurement":[{"name":"used_percent","rename":"DISK_USED","unit":"Percent"}],"resources":["/rootfs","/rootfs/media/volume"],"drop_device":true},"swap":{"measurement":[{"name":"used_percent","rename":"SWAP_USED","unit":"Percent"}]}}}}' > /etc/cwagentconfig/cwagent-config.json

# Prepare AWS cli
instance_id=$(ec2-metadata -i | cut -d' ' -f2)
sudo su
yum install -y awscli jq
aws configure set region "${region_name}"

# Associate Elastic IP
aws ec2 associate-address --instance-id $instance_id --allocation-id "${eip_allocation_id}"

  # mount volume

aws ec2 wait volume-available --volume-ids "${media_volume}"
aws ec2 attach-volume --device /dev/sdf --volume-id "${media_volume}" --instance-id "$instance_id"
while [ $(ls /sys/block | wc -l) -lt 2 ]; do
  sleep 1s
done
sleep 5s

volume=$(readlink -f /dev/sdf)
blkid -o value -s TYPE "$volume" || mkfs.ext3 "$volume"
fs=$(blkid -o value -s TYPE "$volume")
mntpt=/media/volume
mkdir -p $mntpt
mount "$volume" "$mntpt"
mkdir -p -m 777 $mntpt/{logo,logs,tmp,scmloop,access,git,hg,svn,docs,search,src,lucene,plugins,utils,peer-discovery}
uuid=$(sudo blkid -s UUID -o value "$volume")
cat /etc/fstab | grep -q "$uuid" || echo "UUID=$uuid $mntpt $fs defaults,nofail 0 2" >> /etc/fstab


# Add host
echo "127.0.0.1   codebeamer-app" >> /etc/hosts

# Setting ECS agent to always restart
sed -i 's/Restart=.*$/Restart=always/' /usr/lib/systemd/system/ecs.service
systemctl daemon-reload

# Add updater script to utils
cat <<"EOF" > /media/volume/utils/update_resources.sh
#!/bin/sh
tmp_file=/tmp/appuser.zip
curl https://${home_resources_bucket}/${client_name}/appuser.zip --output $tmp_file
unzip -o -d /home $tmp_file
rm $tmp_file

mkdir -p -m 755 /home/appuser/codebeamer/update/
curl https://${client_resources_bucket}/${client_name}/root.zip --output /home/appuser/codebeamer/update/root.zip
source ~/run.sh
EOF

cat <<"EOF" > /media/volume/utils/endpoint.sh
#!/bin/sh
echo "** Start update resource **"

source ~/utils/update_resources.sh

echo "** Start codeBeamer image **"

source "$@"
EOF

# Add uploader script
cat <<"EOF" > /media/volume/utils/upload.sh
#!/usr/bin/env bash

DOCKER_USERNAME=${docker_username}
DOCKER_PASSWORD=${docker_password}
DOCKER_IMAGE=intland/utils:fileuploader

set -euo pipefail

attachments=()
for file in "$@"
do
  target=$(echo "/target/$file" | sed 's@//*@/@g')
  attachments+=(-v "$(realpath $file):$target:ro")
done

docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

docker run "$${attachments[@]}" -e CLIENT=${client_name} $DOCKER_IMAGE
EOF

chmod 777 /media/volume/utils/update_resources.sh /media/volume/utils/endpoint.sh /media/volume/utils/upload.sh
# chown 1001 /media/volume/* -R

# Install AWS Inspector agent
if [ "${inspector_enabled}" = true ] ; then
  curl -O https://inspector-agent.amazonaws.com/linux/latest/install
  bash install
fi
