FROM java:8

ARG FLUME_VERSION="1.6.0"
ARG HADOOP_VERSION="2.7.3"
ARG APACHE_MIRROR="https://dist.apache.org/repos/dist/release"
ARG APACHE_DIST_MIRROR="https://dist.apache.org/repos/dist/release"

# Import keys for flume and hadoop
ADD keys/* /tmp/
RUN set -x \
	&& cd /tmp \

	# Install hadoop
	&& curl -fSL "${APACHE_MIRROR}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" -o hadoop-${HADOOP_VERSION}.tar.gz \
	&& curl -fSL "${APACHE_MIRROR}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.mds" -o hadoop-${HADOOP_VERSION}.tar.gz.mds \
	&& curl -fSL "${APACHE_DIST_MIRROR}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.asc" -o hadoop-${HADOOP_VERSION}.tar.gz.asc \
	&& shasum -a 256 hadoop-${HADOOP_VERSION}.tar.gz \
	&& gpg --import hadoop-KEYS \
	&& gpg --verify hadoop-${HADOOP_VERSION}.tar.gz.asc \
	&& tar xvzf hadoop-${HADOOP_VERSION}.tar.gz -C / --strip-components 1 \
	&& rm -rf /tmp/hadoop-* \

	# Install flume
	&& curl -fSL "${APACHE_MIRROR}/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz" -o apache-flume-${FLUME_VERSION}-bin.tar.gz \
	&& curl -fSL "${APACHE_DIST_MIRROR}/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz.asc" -o apache-flume-${FLUME_VERSION}-bin.tar.gz.asc \
	&& gpg --import apache-flume-KEYS \
	&& gpg --verify apache-flume-${FLUME_VERSION}-bin.tar.gz.asc \
	&& mkdir -p /flume \
	&& tar xvzf apache-flume-${FLUME_VERSION}-bin.tar.gz -C /flume --strip-components 1 \
	&& rm -rf /tmp/apache-flume-* \

	# Copy default properties
	&& cp /flume/conf/flume-conf.properties.template /flume/conf/flume.properties \

	# Install envsubst for dynamic config file
	&& apt-get update && apt-get install -y --no-install-recommends gettext-base \
	&& rm -rf /var/lib/apt/lists/*


EXPOSE 41414
WORKDIR /flume
# Expose flume config dir as a volume
VOLUME /flume/conf

# Entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
