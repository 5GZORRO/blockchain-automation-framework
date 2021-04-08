# USAGE: 
# docker build . -t baf-build
# docker run -v $(pwd):/home/blockchain-automation-framework/ baf-build

FROM ubuntu:16.04

# Create working directory
WORKDIR /home/

RUN apt update -y && \
    apt-get -y install apt-transport-https ca-certificates curl

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && touch /etc/apt/sources.list.d/kubernetes.list
RUN echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        unzip \
        build-essential \
        default-jre \
	    openssh-client \
        gcc \
        git \
        libdb-dev libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev \
        jq \
        gettext-base \
        openvpn \
        nodejs \
        sudo \
        kubectl \
        openvpn \
        software-properties-common

RUN curl -O https://releases.hashicorp.com/vault/1.6.2/vault_1.6.2_linux_amd64.zip && \
    unzip vault_1.6.2_linux_amd64.zip && \
    mv vault /usr/local/bin

RUN apt purge python2.7-minimal -y

RUN add-apt-repository -y ppa:deadsnakes/ppa && apt-get update && apt-get install -y python3.6 && mv /usr/bin/python3.6 /usr/bin/python3

RUN curl -sS  https://bootstrap.pypa.io/get-pip.py >> setup.py && python3 setup.py

RUN pip3 install ansible && \
    pip3 install jmespath && \
    pip3 install openshift==0.10.1

RUN rm /etc/apt/apt.conf.d/docker-clean
RUN mkdir /etc/ansible/
RUN /bin/echo -e "[ansible_provisioners:children]\nlocal\n[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Copy the provisional script to build container
COPY ./run.sh /home
COPY ./reset.sh /home
RUN chmod 755 /home/run.sh
RUN chmod 755 /home/reset.sh
ENV PATH=/root/bin:/root/.local/bin/:$PATH

# The mounted repo should contain a build folder with the following files
# 1) K8s config file as config
# 2) Network specific configuration file as network.yaml
# 3) Private key file which has write-access to the git repo

#path to mount the repo
# VOLUME /home/blockchain-automation-framework/

CMD ["/home/run.sh"]
