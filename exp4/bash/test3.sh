#! /bin/env bash

filename=$1
url=$2
linenum=$(cat $1 | wc -l)

function top_src_host()
{
   echo "================= Top 100 Src Host =============="
   awk -F '\t' 'NR != 1 {a[$1]++} END {for(i in a) {print i,a[i]}}' $filename | sort -nr -k2 | head -n 10
}
# top_src_host

function top_url()
{
   echo "================= Top 100 Url ================"
   awk -F '\t' 'NR != 1 {a[$5]++} END {for(i in a) {print i,a[i]}}' $filename | sort -nr -k2 | head -n 10
}

# top_url

function response_stats()
{
   echo "=============== Response Stats ================"
   awk -F '\t' 'NR != 1 {a[$6]++} END {for(i in a) {printf("%d\t%d\t%10.2f%\n",i,a[i],100*a[i]/'$linenum')}}' $filename
}
# response_stats

function top_src_host_ip()
{
   echo "=============== Top 100 Src Host IP ================"
   awk -F '\t' 'NR != 1 {if($1~/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/) a[$1]++} END {for(i in a) {print i,a[i]}}' $filename | sort -nr -k2 | head -n 100
}
# top_src_host_ip

function given_url_top_src_host()
{
   echo "=============== Given URL Top 100 Src Host ================"
   awk -F '\t' 'NR != 1 {if($5=="'$url'") a[$1]++} END {for(i in a) {print i,a[i]}}' $filename | sort -nr -k2 | head -n 10 
}
# given_url_top_src_host

function status_code_top_url()
{
    a=$(awk -F '\t' 'NR != 1 {if($6~/^4[0-9]{2}$/) print $6}' $filename | sort -u)
    echo "=============== Status Code 4xx Top URL ================"
    for res in ${a[@]}; 
    do
	awk -F '\t' 'BEGIN {res="'$res'"} NR != 1 {if(res==$6) a[$5]++} END {for(i in a) {print res,i,a[i]}}' $filename | sort -nr -k2 | head -n 10 
    done
}
status_code_top_url
