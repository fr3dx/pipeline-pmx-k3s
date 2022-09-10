# Gitlab CICD pipeline demo project. 
> USED TOOLS/TECHNOLOGIES:
```
Proxmox Virtual Environment 7.2-5
Packer - > makes Ubuntu 22.04.1 VM template, Rocky 9 and Debian 11 planned
Terraform - > makes VM(s)
Ansible -> deploys k3s on VMs
(Backup repo)
```

## Prerequisites:
> GITLAB VARS:
```
Trigger vars:

TMPLT    == "1"
VM       == "1"
K3S      == "1"
INFRA    == "1"
```

```
CICD vars:

GL_DNS_NAME
GL_PASSWD
GL_USERNAME
GL_TFSTATE_ADDR
GL_TFSTATE_TOKEN
PKR_VAR_pm_api_token_id
PKR_VAR_pm_api_token_secret
PM_API_TOKEN_ID
PM_API_TOKEN_SECRET
PM_API_URL
SSH_priv_key
SSH_pub_key
TF_VAR_ssh_passwd
VM_USER
```
## Gitlab runner:

> SETTINGS
```
sudo vi /etc/gitlab-runner/config.toml
...
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "test"
  url = "http://{ YOUR_IP/DNS_NAME }"
  token = "{ YOUR_TOKEN }"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "bitnami/gitlab-runner"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]
    network_mode = "gitlab-runner-network"
    shm_size = 0

...

```

> NETWORK SETTINGS
```
ip -br -c link
ip -br address show ens18
ip -d -c link show ens18
ip link set dev ens18 promisc on
ip -d -c link show ens18
ip route list
```

```
sudo ip link add git-net link ens18 type macvlan mode bridge
sudo ip addr add 192.168.99.237/32 dev git-net
sudo ip link set git-net up
sudo ip route del 192.168.99.0/24
sudo ip route add 192.168.99.0/24 dev git-net
```
OR create script + service
```
sudo vi /home/{ HOME }/gl_net.sh 
sudo vi /etc/systemd/system/gl_net.service
...

[Unit]
Description=GL net

[Service]
Type=oneshot
ExecStart=/home/{ HOME }/gl_net.sh

[Install]
WantedBy=multi-user.target

...
sudo chmod 640 /etc/systemd/system/gl_net.service 
```
> GITLAB COMMANDS
```
sudo gitlab-runner restart
sudo gitlab-ctl restart
```
> DOCKER
```
sudo docker network create -d macvlan --subnet 192.168.99.0/24 --gateway 192.168.99.1 --ip-range 192.168.99.239/32 -o parent=ens18 gitlab-runner-network

sudo docker run -d --network=gitlab-runner-network --dns 192.168.99.1 --ip 192.168.99.238 -p 8801:8801 --name bitnami-gitlab-runner --restart always -v /srv/gitlab-runner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock bitnami/gitlab-runner:latest
```
```
Special thanks to Tim (https://docs.technotim.live/posts/k3s-etcd-ansible/) and to the open source community!
```