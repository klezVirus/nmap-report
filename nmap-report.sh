#!/bin/bash

PARAMS=""
tools=(dirb nikto whatweb sslscan iker yawast)

usage() {
	echo -e "[*] Usage:"
	echo -e "[*] $0 [-r] [-n|-e] [-d] <NMAP-FILE>\n"
	echo -e "\t-r: Build a reusable version of the report"
	echo -e "\t-n: Build target files for ${tools[@]}"
	echo -e "\t-e: Executes ${tools[@]} [implies -n]"
	echo -e "\t-d: Show debug messages"
	exit 1
}

execute() {

for tool in ${tools[@]}
do
	if [[ "$(which $tool)" != "" ]]; then
		mkdir -p $tool
		case "$tool" in
			dirb)
				echo "dirb-exec"
			;;
			nikto)
				echo "nikto-exec"
			;;
			sslscan)
				echo "sslscan-exec"
			;;
			ike)
				echo "iker-exec"
			;;
		esac
	fi
done
}

FILE=""
exe=0
report=0
gen=0
debug=0

if [ $# -lt 1 ]; then
	usage
fi

while (( "$#" )); do
  case "$1" in
    -h|--help)
      usage
      break
      ;;
    -r|--report)
      report=1
      shift 1
      ;;
    -g|--generate)
      gen=1
      shift 1
      ;;
	-e|--execute)
      exe=1
      shift 1
      ;;
	-d|--debug)
      debug=1
      shift 1
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo  "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      if [[ "$PARAMS" == "" ]]
	then
		FILE="$1"
	fi
      shift
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"

if [ ! -f "$FILE" ]; then
	echo "[!] Not a valid nmap file"
	usage
fi

cat "$FILE" | grep -P "report|open" > "./_tmp"

ip=""
nothing_found=1
printf "%.15s\t%.5s\t%.15s\t%.40s\n" "IP             " "PORT" "PROTOCOL" "SERVICE"
while read line
do
	if [[ "$(echo $line | grep report)" == "" ]]; then
		port="$(echo $line | grep -o -P '^\d{2,5}')"
		proto="$(echo $line | awk '{print $3}')"
		t=$((9 - $(echo $proto | wc -c)))
		
		if [ $gen -gt 0 ] ; then
			scheme=""
			if [[ "$(echo $proto | grep -v https)" == "" ]]; then
			scheme="https"
			elif [[ "$(echo $proto | grep -v http)" == "" ]]; then
			scheme="http"
			elif [[ "$(echo $proto | grep -v ssl)" == "" ]]; then
			scheme="ssl"
			elif [[ "$(echo $proto | grep -v ike)" == "" ]]; then
			scheme="ike"
			fi
			
			if [[ "$scheme" != "" ]]; then 
				case "scheme" in 
					"ssl") 
						echo "$ip:$port" >> "./ssl-targets.txt"
					break
					;;
					"ike") 
						echo "$ip" >> "./ike-targets.txt"
					break
					;;
					*)
						echo "$scheme://$ip:$port" >> "./$scheme-targets.txt"
					break
					;;
				esac
			fi
		fi
		if [ $t -gt 0 ]; then
			printf -v pad "%.${t}s" "        "
			proto="$proto$pad"
		fi
		reason="$(echo $line | awk '{print $4}')"
		
		skip=0
		s="$(echo $line | awk '{print $5}')"
		if [[ "$s" == "ttl" ]]; then
			if [[ "$(echo $line | awk '{print $7}')" == "" ]]; then
				skip=1
			fi
			sn=7
		else
			sn=5
		fi
		if [ $skip -eq 0 ]; then
			service="$(echo $line | awk -v start=$sn '{for (i=start;i<NF;i++) printf "%s%s",$i,(i+4>NF?" ":FS);print $NF}')"
		else
			service="Unknown Service"
		fi
		nothing_found=0
		printf "%.15s\t%.5s\t%.15s\t%.40s\n" "$ip" "$port" "$proto" "$service"
		sn=
	else
		if [[ $nothing_found -eq 1 ]] && [[ ! -z $ip ]];  then
			printf "%.15s\t%.5s\t%.15s\t%.40s\n" "$ip" "N/A" "No Open Ports" "No Services"
		fi
		printf "%.s-" {1..73}
		printf "\n"
		ip="$(echo $line | grep -o -P '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')"
		nothing_found=1
	fi
done < "./_tmp"
rm -f "./_tmp"

if [ $exe -gt 0 ]; then
	execute
fi
