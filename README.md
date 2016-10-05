# Flume docker image with environment variables

Docker image for apache flume

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
