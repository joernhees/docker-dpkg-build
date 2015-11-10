FROM debian
MAINTAINER Joern Hees

RUN apt-get update && apt-get install -y \
		build-essential \
		devscripts \
		wget \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
VOLUME /export

COPY build.sh /
ENTRYPOINT ["/build.sh"]
