FROM python:3.4

# install from pypi and clean up for a slightly smaller image
RUN pip3 install --no-cache-dir awscli==1.9.2 \
	&& find /usr/local \
		\( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		-exec rm -rf '{}' +
