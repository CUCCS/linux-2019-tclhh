#! /bin/env bash

filename=$1
linenum=$(cat $filename | wc -l)

function age_stats()
{
   below=$(awk -F '\t' '$6 < 20 && NR != 1 {print $6}' $filename|wc -l)
   middle=$(awk -F '\t' '$6 >= 20 && $6 <= 30 && NR != 1{print $6}' $filename|wc -l)
   above=$(awk -F '\t' '$6 > 30 && NR != 1 {print $6}' $filename|wc -l)
   all=$(($below+$middle+$above))
   echo "=================== Age Stats ================="
   echo -e "[0,20)\t\t$below\t\t$(echo "scale=2;100*$below/$all" | bc)%"  
   echo -e "[20,30]\t\t$middle\t\t$(echo "scale=2;100*$middle/$all" | bc)%"   
   echo -e "(30,100)\t$above\t\t$(echo "scale=2;100*$above/$all" | bc)%"    
}
age_stats

function max_age()
{
    max=$(awk -F '\t' 'BEGIN {max = 0} {if ($6 > max && $6 < 100) max = $6} END{print max}' $filename)
    echo "================ Max Age ==============="
    awk -F '\t' 'BEGIN{max = "'$max'"}{if($6 == max)print $9 "\t\t\t" $6}' $filename
}
max_age

function min_age()
{
    min=$(awk -F '\t' 'BEGIN {min = 1000} {if ($6 < min) min = $6} END{print min}' $filename)
    echo "================ Min Age ==============="
    awk -F '\t' 'BEGIN{min = "'$min'"}{if($6 == min)print $9 "\t\t\t" $6}' $filename
}
min_age

function position_stats()
{     
     echo "=========== Position Age ==============="
     awk -F '\t' 'NR!=1{if($5 == "Défenseur") print "Defender";else print $5}' $filename| sort -f | uniq -c | awk '{printf("%10s\t%d\t%.2f%%\n",$2,$1,100*$1/'$linenum')}'
}
position_stats 

function max_len_name()
{
    max=$(awk -F '\t' 'BEGIN {max = 0} {if (length($9) > max) max = length($9)} END{print max}' $filename)
    echo "=========== Max Name Length ==============="
    awk -F '\t' 'BEGIN{max = "'$max'"}{if(length($9) == max)print $9 "\t\t\t" max}' $filename
}
max_len_name

function min_len_name()
{
    min=$(awk -F '\t' 'BEGIN {min = 10000} {if (length($9) < min) min = length($9)} END{print min}' $filename)
    echo "=========== Min Name Length ==============="
    awk -F '\t' 'BEGIN{min = "'$min'"}{if(length($9) == min)print $9 "\t\t\t" min}' $filename
}
min_len_name
 
