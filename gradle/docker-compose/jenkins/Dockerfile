FROM jenkins/jenkins:lts-jdk11
USER root

RUN apt-get update && \
apt-get install -qy \
  apt-utils \
  libyaml-dev \
  build-essential \
  python-dev \
  libxml2-dev \
  libxslt-dev \
  libffi-dev \
  libssl-dev \
  default-libmysqlclient-dev \
  python-mysqldb \
  python-pip \
  libjpeg-dev \
  zlib1g-dev \
  libblas-dev\
  liblapack-dev \
  libatlas-base-dev \
  apt-transport-https \
  ca-certificates \
  wget \
  software-properties-common \
  zip \
  unzip \
  sudo \
  gfortran && \
rm -rf /var/lib/apt/lists/*
# Install docker
RUN wget https://download.docker.com/linux/debian/gpg && \
    apt-key add gpg && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -qy docker-ce

# Install compose
RUN curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

RUN pip install cffi --upgrade
RUN pip install pip2pi ansible==2.0

# Install aws cli 2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install


COPY --chown=jenkins:jenkins executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt

COPY --chown=jenkins:jenkins jenkins-plugin-cli.sh /usr/local/bin/jenkins-plugin-cli.sh
RUN chmod +x /usr/local/bin/jenkins-plugin-cli.sh && \
/usr/local/bin/jenkins-plugin-cli.sh --plugin-file /usr/share/jenkins/ref/plugins.txt


# add the jenkins user to the docker group so that sudo is not required to run docker commands
RUN groupmod -g 1026 docker && gpasswd -a jenkins docker && \
touch /var/run/docker.sock && \
sudo chgrp docker /var/run/docker.sock && \
sudo chmod g+w /var/run/docker.sock

USER jenkins
