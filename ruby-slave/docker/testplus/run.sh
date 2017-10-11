#!/usr/bin/env bash
# read the options
# brew install gnu-getopt
# echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.zshrc
TEMP=`getopt --options c:e:p:s:r:o:j:i:h: --long cmd:,environment:,platform:,script-path:,round:,output:,json:,ip:,home: -n 'run.sh' -- "$@"`
if [ $? != 0 ]; then
    echo "Terminating..."
    exit 1
fi
eval set -- "$TEMP"
while true ; do
   case "$1" in
   	   -c|--cmd)
           case "$2" in
               "") shift 2 ;;
               *) CMD=$2 ; shift 2 ;;
           esac ;;
       -e|--environment)
           case "$2" in
               "") shift 2 ;;
               *) ENV=$2 ; shift 2 ;;
           esac ;;
       -p|--platform)
           case "$2" in
               "") shift 2 ;;
               *) PLATFORM=$2 ; shift 2 ;;
           esac ;;
       -s|--script-path)
           case "$2" in
               "") shift 2 ;;
               *) SCRIPT=$2 ; shift 2 ;;
           esac ;;
       -r|--round)
           case "$2" in
               "") shift 2 ;;
               *) ROUND=$2 ; shift 2 ;;
           esac ;;
       -o|--output)
           case "$2" in
               "") shift 2 ;;
               *) OUTPUT=$2 ; shift 2 ;;
           esac ;;
       -j|--json)
           case "$2" in
               "") shift 2 ;;
               *) JSON=$2 ; shift 2 ;;
           esac ;;
       -i|--ip)
           case "$2" in
               "") shift 2 ;;
               *) IP=$2 ; shift 2 ;;
           esac ;;
       -h|--home)
           case "$2" in
               "") shift 2 ;;
               *) MYHOME=$2 ; shift 2 ;;
           esac ;;
       --) shift ; break ;;
       *) echo "Internal error!" ; exit 1 ;;
   esac
done
FLAG=1
if [ -z ${CMD+x} ]; then echo "ERROR: required command is missing (--cmd|-c)"; FLAG=0; fi
if [ -z ${ENV+x} ]; then echo "ERROR: required environment is missing (--environment|-e)"; FLAG=0; fi
if [ -z ${PLATFORM+x} ]; then echo "ERROR: required platform is missing (--platform|-p)"; FLAG=0; fi
if [ -z ${SCRIPT+x} ]; then echo "ERROR: required script-path is missing (--script-path|-s)"; FLAG=0; fi
if [ -z ${ROUND+x} ]; then echo "ERROR: required test round is missing (--round|-r)"; FLAG=0; fi
if [ -z ${OUTPUT+x} ]; then echo "ERROR: required output file is missing (--output|-o)"; FLAG=0; fi
if [ -z ${JSON+x} ]; then echo "ERROR: required json data is missing (--json|-j)"; FLAG=0; fi
if [ -z ${IP+x} ]; then echo "ERROR: required IP is missing (--ip|-i)"; FLAG=0; fi
if [ -z ${MYHOME+x} ]; then echo "ERROR: required home path is missing (--home|-h)"; FLAG=0; fi
if [ $FLAG -eq 0 ]; then
	exit 2
else
	cd $MYHOME && pwd
	echo "java $ENV,$PLATFORM,$SCRIPT,$ROUND,$OUTPUT,$JSON,$IP"
fi
