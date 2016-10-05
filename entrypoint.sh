#!/usr/bin/env sh
FLUME=/opt/flume/bin/flume-ng

case "$1" in
	agent)
		ARGS="$(getopt -l "file:name:" -o f:n: -- $@)"
		eval set -- $ARGS
		while true ; do
			case "$1" in
				-f|--file) CONFIG=$2 ; shift ;;
				-n|--name) AGENT=$2 ; shift ;;
				--) shift ; break ;;
				*) echo "Failed to parse args" ; exit 1 ;;
			esac
		done

		if [ -f $CONFIG ]; then
			sed -e "$(
			printenv |
			awk -F'=|\n' '/FLUME_[a-zA-Z0-9_]+=[a-zA-Z0-9_\-]+/{print $1, $2}' |
			sed -e 's/\//\\\//g' |
			awk '{print "s/{{"$1"}}/"$2"/g;"}'
			)" $CONFIG > "${CONFIG}.local"
			CONFIG="${CONFIG}.local"
		fi

		$FLUME $MODE \
			-c conf \
			-f $CONFIG \
			-n $AGENT $@
		;;

	*) $FLUME $@ ;;
esac
