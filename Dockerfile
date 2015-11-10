FROM python:3.4

# install from pypi and clean up for a slightly smaller image
RUN pip3 install --no-cache-dir awscli==1.9.2 \
	&& find /usr/local \
		\( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		-exec rm -rf '{}' +

# install tools we need for the labs
RUN apt-get update && apt-get install -y --no-install-recommends \
		groff \
		less \
	&& rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
    -O /usr/local/bin/jq \
  && chmod +x /usr/local/bin/jq

# some customisations for the shell environment
ADD dot.bashrc /root/.bashrc
ADD dot.inputrc /root/.inputrc

# create mount for config files
VOLUME /root/.aws

# create mount for project files
VOLUME /root/aws-bootcamp
