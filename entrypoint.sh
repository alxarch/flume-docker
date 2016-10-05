#!/usr/bin/env bash

_FLUME_NG=${FLUME_NG:=bin/flume-ng}
FLUME_CONF_DIR=${FLUME_CONF_DIR:=conf/}
FLUME_CONF_FILE=${FLUME_CONF_FILE:=$FLUME_CONF_DIR/flume.properties}
FLUME_DEFAULT_AGENT=${FLUME_DEFAULT_AGENT:="agent"}
AGENT=$FLUME_DEFAULT_AGENT

case "$1" in
	agent)
		shift
		ARGS=""
		while [ "$1" ]; do
			case "$1" in
				-f|--file) FLUME_CONF_FILE=$2; shift 2 ;;
				-c|--conf) FLUME_CONF_DIR=$2; shift 2 ;;
				-n|--name) AGENT=$2; shift 2 ;;
				*) ARGS="$ARGS $1"; shift ;;
			esac
		done
		case "$FLUME_MONITORING" in
			http) ARGS="$ARGS -Dflume.monitoring.type=http" ;;
		esac

		case "$FLUME_LOGGER" in
			"") ;;
			*) ARGS="$ARGS -Dflume.root.logger=$FLUME_LOGGER" ;;
		esac

		cat $FLUME_CONF_FILE | envsubst > "$FLUME_CONF_FILE.local"

		ARGS="-c $FLUME_CONF_DIR -n $AGENT $ARGS"
		$_FLUME_NG agent -f $FLUME_CONF_FILE.local $ARGS
		;;
	*)
		$_FLUME_NG $@
		;;
esac
