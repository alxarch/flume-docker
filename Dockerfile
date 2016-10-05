FROM java:8

ARG FLUME_VERSION="1.6.0"
ARG HADOOP_VERSION="2.7.3"
ARG APACHE_MIRROR="https://dist.apache.org/repos/dist/release"
ARG APACHE_DIST_MIRROR="https://dist.apache.org/repos/dist/release"

# Import keys for hadoop
ADD keys/hadoop/KEYS /tmp/hadoop-KEYS
RUN set -x \
	&& cd /tmp \
	&& curl -fSL "${APACHE_MIRROR}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" -o hadoop-${HADOOP_VERSION}.tar.gz \
	&& curl -fSL "${APACHE_MIRROR}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.mds" -o hadoop-${HADOOP_VERSION}.tar.gz.mds \
	&& curl -fSL "${APACHE_DIST_MIRROR}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.asc" -o hadoop-${HADOOP_VERSION}.tar.gz.asc \
	&& shasum -a 256 hadoop-${HADOOP_VERSION}.tar.gz \
	&& gpg --import hadoop-KEYS \
	&& gpg --verify hadoop-${HADOOP_VERSION}.tar.gz.asc \
	&& tar xvzf hadoop-${HADOOP_VERSION}.tar.gz -C / --strip-components 1 \
	&& rm -rf /tmp/hadoop-*

# Import keys for flume
ADD keys/flume/KEYS /tmp/apache-flume-KEYS
RUN set -x \
	&& cd /tmp \
	&& curl -fSL "${APACHE_MIRROR}/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz" -o apache-flume-${FLUME_VERSION}-bin.tar.gz \
	&& curl -fSL "${APACHE_DIST_MIRROR}/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz.asc" -o apache-flume-${FLUME_VERSION}-bin.tar.gz.asc \
	&& gpg --import apache-flume-KEYS \
	&& gpg --verify apache-flume-${FLUME_VERSION}-bin.tar.gz.asc \
	&& mkdir -p /opt/flume \
	&& tar xvzf apache-flume-${FLUME_VERSION}-bin.tar.gz -C /opt/flume --strip-components 1 \
	&& rm -rf /tmp/apache-flume-*

WORKDIR /opt/flume
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
