FROM ubuntu:20.04

#input GitHub runner version argument

ARG RUNNER_VERSION

ENV DEBIAN_FRONTEND=noninteractive

LABEL BaseImage="ubuntu:20.04"

LABEL RunnerVersion=${RUNNER_VERSION}
 
# update the base packages + add a non-sudo user

RUN apt-get update -y && apt-get upgrade -y && useradd -m docker
 
# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)

RUN apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git azure-cli jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip
 
# cd into the user directory, download and unzip the github actions runner

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
&& curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
&& tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
 
# install some additional dependencies

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY startup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/startup.sh 

USER docker
 
# set the entrypoint to the start.sh script

ENTRYPOINT ["/usr/local/bin/startup.sh"]
CMD ["startup.sh"]
