#! /bin/env bash

filename=$1
shift

function usage(){
cat << EOF
Version: 0.0.1 (2019 Apr 15)

Usage: bash $1 [filename] ... [OPTION] ...
       bash $1 -h

Arguments:
    -A  				<*> show all statistical information 
    -a					<*> show age status
    -o  				<*> show the oldest 
    -y					<*> show the youngest
    -p					<*> show position status
    -l					<*> show the longest name
    -s					<*> show the shortest name
    -h					<*> show help info

Example: 
    bash $1 worldcupplayerinfo.tsv -A 	        show all statistics information
    bash $1 worldcupplayerinfo.tsv -pos           show position status + show the oldest + show the shortest 

EOF
}


function check_file()
{
   if [[ "$filename" =~ ^-h(.*)$ ]]; then 
	usage "$0"
	exit
   elif [[ ! -f "$filename" ]]; then
	echo "File does not exist! or Unknown input!"
	exit
   else
	linenum=$( wc -l < "$filename" )
   fi
}


function all_statistics_info()
{
   age_stats
   max_age
   min_age
   position_stats
   max_len_name
   min_len_name	
}


function age_stats()
{
   below=$(awk -F '\t' '$6 < 20 && NR != 1 { print $6 }' "$filename" | wc -l)
   middle=$(awk -F '\t' '$6 >= 20 && $6 <= 30 && NR != 1 { print $6 }' "$filename" | wc -l)
   above=$(awk -F '\t' '$6 > 30 && NR != 1 {print $6}' "$filename" | wc -l)
   echo -e "\n=================== Age Stats ================="
   echo "scale=2; 100*$below/$linenum" | bc | awk '{printf("%-10s\t %5d\t\t %10.3f%\n", "[0,20)", '"$below"', $0)}'
   echo "scale=2; 100*$middle/$linenum" | bc | awk '{printf("%-10s\t %5d\t\t %10.3f%\n", "[20,30]", '"$middle"', $0)}'
   echo "scale=2; 100*$above/$linenum" | bc | awk '{printf("%-10s\t %5d\t\t %10.3f%\n", "(30,99]", '"$above"', $0)}'
}


function max_age()
{
    max=$(awk -F '\t' 'BEGIN {max = 0} NR != 1 {if ($6 > max && $6 < 100) max = $6} END {print max}' "$filename")
    echo -e "\n============== Max Age ============="
    awk -F '\t' 'BEGIN{ max = '"$max"' } { if ($6 == max) print $9 "\t\t\t" $6 }' "$filename"
}


function min_age()
{
    min=$(awk -F '\t' 'BEGIN {min = 1000} NR != 1 {if ($6 < min) min = $6} END {print min}' "$filename")
    echo -e "\n============== Min Age =============="
    awk -F '\t' 'BEGIN{ min = '"$min"' } { if($6 == min) print $9 "\t\t\t" $6 }' "$filename"
}


function position_stats()
{     
     echo -e "\n=========== Position Age ==============="
     awk -F '\t' 'NR != 1 { if($5 == "Défenseur") print "Defender";else print $5}' "$filename" | sort -f | uniq -c | awk '{printf("%-10s\t%d\t%.2f%%\n",$2,$1,100*$1/'"$linenum"')}'
}


function max_len_name()
{
    max=$(awk -F '\t' 'BEGIN {max = 0} t = $9 {gsub(" ","",t); if (length(t) > max) max = length(t)} END{print max}' "$filename")
    echo -e "\n=========== Max Name Length ==============="
    awk -F '\t' 'BEGIN{max = '"$max"'} t = $9 {gsub(" ","",t); if(length(t) == max) print $9 "\t\t" max}' "$filename"
}


function min_len_name()
{
    min=$(awk -F '\t' 'BEGIN {min = 10000} t = $9 {gsub(" ","",t); if(length(t) < min) min = length(t)} END{print min}' "$filename")
    echo -e "\n=========== Min Name Length ==============="
    awk -F '\t' 'BEGIN{min = '"$min"'} t = $9 {gsub(" ","",t); if(length(t) == min) print $9 "\t\t\t\t" min}' "$filename"
}


check_file
while getopts ":Aaoypls" opt; do 
   case $opt in
	A) all_statistics_info ;;
	a) age_stats ;;
	o) max_age ;;
	y) min_age ;;
	p) position_stats ;;
	l) max_len_name ;;
	s) min_len_name ;;
	?) echo -e "\nUnknown option $OPTARG " ;;
	*) echo -e "\nUnknown error while processing options" ;;
   esac
done
echo ''
