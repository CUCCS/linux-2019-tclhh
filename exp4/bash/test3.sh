#! /bin/env bash

filename=$1
shift
linenum=$(wc -l < "$filename")

function usage(){
cat << EOF
Usage: bash $1 [filename] ... [OPTION] ...

option:
    -A  				=> show all statistical information 
    -u  				=> show top 100 url
    -i					=> show top 100 ip
    -c					=> show top 100 src host
    -r					=> show response status
    -s					=> show status code top url
    -g					=> show given url top src host
    -h					=> show help info

Example:
    bash $1 web_log.tsv -g "test.com"		show given url "test.com" the most top 100 src url
    bash $1 web_log.tsv -ui 			show top 100 url + show top 100 ip

EOF
}


function top_src_host()
{
   echo -e "\n================= Top 100 Src Host ================"
   awk -F '\t' 'NR != 1 {a[$1]++} END {for(i in a) { printf("%-40s\t20%d\n",i,a[i]) }}' "$filename" | sort -nr -k2 | head -n 100
}


function top_url()
{
   echo -e "\n======================= Top 100 Url ========================="
   awk -F '\t' 'NR != 1 {a[$5]++} END {for(i in a) { printf("%-50s\t20%d\n",i,a[i]) }}' "$filename" | sort -nr -k2 | head -n 100
}


function response_stats()
{
   echo -e "\n================ Response Stats ================="
   awk -F '\t' 'NR != 1 {a[$6]++} END {for(i in a) { printf("%d\t\t%d\t\t%10.4f%\n",i,a[i],100*a[i]/'"$linenum"') }}' "$filename"
}


function top_src_host_ip()
{
   echo -e "\n=============== Top 100 Src Host IP ================"
   awk -F '\t' 'NR != 1 {if($1~/^([0-9]{1,3}\.){3}[0-9]$/) a[$1]++} END {for(i in a) {printf("%-20s\t\t%d\n",i,a[i])}}' "$filename" | sort -nr -k2 | head -n 100
}


function given_url_top_src_host()
{
   echo -e "\n=============== Given URL Top 100 Src Host ================"
   awk -F '\t' 'NR != 1 {if($5=="'"$1"'") a[$1]++} END {for(i in a) {printf("%-40s\t%d\n",i,a[i])}}' "$filename" | sort -nr -k2 | head -n 10 
}


function status_code_top_url()
{
    a=$(awk -F '\t' 'NR != 1 {if($6~/^4[0-9]{2}$/) print $6}' "$filename" | sort -u)
    echo -e "\n======================= Status Code 4xx Top URL ========================="
    for res in $a; 
    do
	awk -F '\t' 'BEGIN {res='"$res"'} NR != 1 {if(res==$6) a[$5]++} END {for(i in a) {printf("%d\t%-60s\t\t%d\n",res,i,a[i])}}' "$filename" | sort -nr -k3 | head -n 100 
    done
}


function all_statistics_info()
{
   top_src_host
   top_url
   top_src_host_ip 
   response_stats
   status_code_top_url
}


while getopts ":Auircsg:h" opt; do 
   case $opt in
	A) all_statistics_info ;;
	u) top_url ;;
	i) top_src_host_ip ;;
	r) response_stats ;;
	c) top_src_host ;;
	s) status_code_top_url ;;
	g) given_url_top_src_host "$OPTARG" ;;
	h) usage "$0"  exit 0 ;;
	?) echo "Unknown option $OPTARG " ;;
	*) echo "Unknown error while processing options" ;;
   esac
done
	
