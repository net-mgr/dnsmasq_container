#!/bin/bash

#This script only works under below conditions
# 1. Docker is installed

# default value
DEFAULT_ATTACH_OPTION=it # {i|t|it|d}
DEFAULT_PORT=5353 # host port which container binds
DEFAULT_COMMAND="" # command which execute in container
                   # using default entrypoint of image, specify ""

# constant value
IMAGE_NAME=dnsmasq
CONTAINER_NAME=dnsmasq
SCRIPT_NAME=dnsmasq-docker.sh

function print_usage(){
    cat <<_EOT_
$SCRIPT_NAME

Usage:
    $SCRIPT_NAME SubCommand

Description:
    start and stop $IMAGE_NAME on container

SubCommands:
    start    start $IMAGE_NAME container
             for more details, run '$SCRIPT_NAME start -h'
    stop     stop $IMAGE_NAME container
    status   show conditions of $IMAGE_NAME container
    restart  restart $IMAGE_NAME container
    help     show this usage
_EOT_
}

function print_start_usage(){
    cat <<_EOT_
Usage:
    $SCRIPT_NAME start [OPTION] [COMMAND]

Description:
    run $IMAGE_NAME container
    if COMMAND is specified, run COMMAND instead of dafault entrypoint

Options:
    -a         attach: connect tty to container
    -d         dettach: input and output is discarded
                        This option overrides -a option
    -p number  port: bind 'number' port (default $PORT)
    -h         help: show this usage
_EOT_
}

function main(){
    if ! user_belongs_dockergroup; then
        echo "$(whoami) must belong 'docker' group"
        exit 1
    fi

    cd "$(dirname "$0")"

    subcommand=$1
    shift

    case $subcommand in
        start)
            start $@
            ;;
        stop)
            stop
            ;;
        status)
            status
            ;;
        restart)
            restart $@
            ;;
        help)
            print_usage
            ;;
        "")
            print_usage
            ;;
        *)
            echo "Invalid option: '$1'"
            exit 1
            ;;
    esac
    return 0
}

function start(){
    PORT=$DEFAULT_PORT
    COMMAND=$DEFAULT_COMMAND
    ATTACH_OPTION=$DEFAULT_ATTACH_OPTION
    set_start_options $@

    if container_is_running $CONTAINER_NAME; then
        echo "$CONTAINER_NAME is already runnning"
        exit 1
    fi

    if ! image_exists; then
        echo "docker image not found: $IMAGE_NAME"
        echo "build container image from Dockerfile"
        exit 1
    fi

    if [ ! istty ] && [ $ATTACH_OPTION = it ]; then
        ATTACH_OPTION=i
    fi

    if port_is_used; then
        echo "Port $PORT is already used"
        exit 1
    fi

    echo "starting $CONTAINER_NAME"
    docker run \
        -$ATTACH_OPTION \
        -p $PORT:53/tcp \
        -p $PORT:53/udp \
        -v $PWD/conf/dnsmasq.conf:/etc/dnsmasq.conf \
        -v $PWD/conf/hosts:/etc/hosts \
        --rm \
        --name $CONTAINER_NAME \
        $IMAGE_NAME $COMMAND
}

function set_start_options(){
    while getopts dhop: OPT; do
        case $OPT in
            a)
                ATTACH_OPTION=it
                ;;
            d)
                ATTACH_OPTION=d
                ;;
            h)
                print_start_usage
                exit 0
                ;;
            p)
                PORT=$OPTARG
                ;;
            *)
                echo "Invalid option: $OPT"
                exit 1
                ;;
        esac
    done
    COMMAND=${@:$OPTIND}
}

function stop(){
    if ! container_is_running; then
        echo "$CONTAINER_NAME is not running"
        exit 1
    fi

    echo -n "trying to stop $CONTAINER_NAME... "
    docker stop $CONTAINER_NAME > /dev/null && \
        echo "done."
}

function status(){
    if container_is_running; then
        echo "$CONTAINER_NAME is running"
    else
        echo "$CONTAINER_NAME is not running"
    fi
}

function restart(){
    stop
    start $@
}

function user_belongs_dockergroup(){
    if [ $(groups | grep -c -e docker -e root) = 0 ]; then
        return 1
    else
        return 0
    fi
}

function container_is_running(){
    if [ $(docker ps -a --format "table {{.Names}}" |grep -cx "$CONTAINER_NAME") = 0 ]; then
        return 1
    else
        return 0
    fi
}

function image_exists(){
    if [ $(docker images $IMAGE_NAME | wc -l) = 1 ]; then
        return 1
    else
        return 0
    fi
}

function istty(){
    if [ "$(tty)" = "not a tty" ]; then
        return 1
    else
        return 0
    fi
}

function port_is_used(){
    if [ $(ss -antu | grep -c $PORT) != 0 ]; then
        return 0
    else
        return 1
    fi
}

main "$@"
