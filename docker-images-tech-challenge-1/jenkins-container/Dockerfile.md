# Dockerfile for the Jenkins container

FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y \
    docker.io \
    awscli


# Make sure you run cat /etc/group | grep docker to see the group ID for your docker user on your host machine
RUN groupmod -g 993 docker

# Adds the docker group as a secondary group for the jenkins user
RUN usermod -aG docker jenkins

USER jenkins