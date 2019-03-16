#!/bin/bash

# A very basic docker binary install that can be expanded upon

DOCKER_VERSION=${install_docker_version}
INSTALL_DOCKER_COMPOSE=${install_docker_compose}
DOCKER_COMPOSE_VERSION=1.23.2

function install_docker_ubuntu(){

    # install depepdencies
    apt-get update && \
        apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository -y -u \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

    apt-get install -y docker-ce=$DOCKER_VERSION
}

function install_docker_centos(){
    yum -y install \
        yum-utils \
        device-mapper-persistent-data \
        lvm2


    cat > /etc/yum.repos.d/docker-ce.repo <<-'EOF'
	[docker-ce-stable]
	name=Docker CE Stable - $basearch
	baseurl=https://download.docker.com/linux/centos/7/$basearch/stable
	enabled=1
	gpgcheck=1
	gpgkey=https://download.docker.com/linux/centos/gpg
	EOF


    docker_version=$(yum list docker-ce --showduplicates|grep $DOCKER_VERSION|sort -r|tail -1|awk '{print $2}')

    yum install -y \
        --setopt=obsoletes=0 \
        docker-ce-$docker_version

    systemctl enable docker && systemctl start docker
}

function install_docker_compose(){
    curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod 755 /usr/local/bin/docker-compose
}


# install ubuntu is not currently wired up
type docker >/dev/null || install_docker_centos


[ "$INSTALL_DOCKER_COMPOSE" = 1 ] && (type docker-compose 2>/dev/null || install_docker_compose)