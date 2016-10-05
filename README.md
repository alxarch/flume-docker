# Flume docker image

Docker image for apache flume.

The image also installs hadoop to find it in the classpath (configurable by build arg)

## Build args

### HADOOP_VERSION

Defaults to 3.7.0
Change if you need different version

## Usage

As base image:

```
FROM flume:latest
ADD flume.properties /flume/conf/flume.properties
EXPOSE 44444
CMD ["agent" "-n", "customagent", "-Xmx1024m"]
```

As runnable:

```
docker run \
	-v $PWD/conf:/flume/conf \
	-e FLUME_MONITORING=http \
	-p 41414:41414 \
	-p 44444:44444 \
	flume agent -n agent007
```

> *WARNING* default config is for testing only and uses a sequence source that
> generates events continuously draining the cpu

## Entrypoint

The entrypoint wraps `flume-ng` to provide default arguments and 
expand environment variables in config files.

## Volumes

### /flume/conf

The conf dir for flume.

## Environment variables

### FLUME_CONF_DIR
Defaults to `/flume/conf/`
Default configuration directory to use when no `-c` argument is given.
Override this if you mounted your conf dir elsewhere or have a setup where
multiple conf dirs are needed

### FLUME_CONF_FILE

Defaults to `$FLUME_CONF_DIR/flume.properties`.
Default configuration file to use when no `-f` argument is given.
Override this if you need to have multiple property files in conf dir

### FLUME_DEFAULT_AGENT

Defaults to `agent`.
Default agent name to use when no `-n` argument is given

### FLUME_MONITORING

If set to `http` will open flume's [json reporting](https://flume.apache.org/FlumeUserGuide.html#json-reporting) on port 41414.

## Environment variables substitution

The `entrypoint.sh` script uses [`envsubst`](https://linux.die.net/man/1/envsubst)
for substituting environment variables in the configuration file. For example:

```
agent.sinks.hdfsSink.hdfs.path = ${HDFS_ROOT}/data/foo/bar
```

becomes

```
agent.sinks.hdfsSink.hdfs.path = hdfs://example.com/data/foo/bar
```

if the container runs with `HDFS_ROOT=hdfs://example.com` environment.
