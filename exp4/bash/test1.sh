#!/bin/env bash

ARGS=$(getopt -o i:q:r:w:p:s:fh --long input:,quality:,resolution:,watermark:,prefix:,suffix:,format,help -n "test.sh" -- "$@")


function usage(){
cat << EOF
Version: 0.0.1 (2019 Apr 16)

Usage: bash $1 [filename] ... [OPTION] ...

    -i  --input <filename|path>         Input image for processing
    -q, --quality <percent>             Image quality compression
    -r, --resize <percent>          	Image resolution compression
    -w, --watermark <text>              Add text watermark
    -p, --prefix <prefix>               Add prefix
    -s, --suffix <suffix>               Add suffix
    -f, --format              	   	Transform image format
    -h, --help                          get the help info

Example: 
     bash $1 -i 1.svg --suffix "suf" -f
     bash $1 -i ./ -p "pre" -w "textfortest" --quality 50 -r 500x400

EOF
exit 0
}


function check_input()
{
   if [[ -d $1 ]]; then
      p=$(pwd) && cd $1
   elif [[ -f $1 ]]; then
      p=$(pwd) && cd $(dirname $1)
   else
     echo "Path or file do not exsit!"
     exit 1
   fi
}



function quality()
{
   [[ "$(identify -format "%m" "$1")" == "JPEG" ]] && command=${command}" -quality $2"
}


function resize()
{
   [[ "PNGSVGJPEG" =~ $(identify -format "%m" "$1") ]] && command=${command}" -resize $2"
}


function watermark()
{
   command=${command}" -gravity southeast -fill black -pointsize 16 -draw \"text 20,10 '$2'\""
}


function format()
{
   [[ "PNGSVG" =~ $(identify -format "%m" "$1") ]] && f=${1%.*}".jpg" && command=${command}" after_"$f
}


function prefix()
{
   mv "after_$1" "$2$1"
   echo "[+] Add prefix $2 successfully!"  
}


function suffix()
{
   mv "after_$1" "$1$2"
   echo "[+] Add suffix $2 successfully!"
}


eval set -- "$ARGS"
while true; do
   case "$1" in 
	-i|--input)	input=$2;	shift 2 ;;
	-q|--quality)   quality=$2;     shift 2 ;;
	-r|--resize) 	resize=$2;      shift 2 ;;
	-w|--watermark) watermark=$2;	shift 2 ;;
	-p|--prefix) 	prefix=$2;	shift 2 ;;
	-s|--suffix)  	suffix=$2;	shift 2 ;;
	-f|--format) 	format=true;    shift 1 ;;
	-h|--help)	usage "$0";  	shift 1 ;;
	--)		break;
   esac
done


check_input "$input"
files=$(ls "$p/$input")


for f in $files; do
   f=${f##*/} && [[ ! "jpegjpgsvgpng" =~ ${f#*.} ]] && continue
   command="convert"
   
   if [[ "$quality" ]];   then quality   "$f" 	"$quality";   fi
   if [[ "$resize" ]];    then resize    "$f"   "$resize";    fi
   if [[ "$watermark" ]]; then watermark "$f"	"$watermark"; fi
   
   command=${command}" $f"
   if [[ "$format" ]]; then 
	format "$f"
   else
	command=${command}" after_"${f}
   fi
   
   eval "$command"
   if [[ "$prefix" ]];	  then prefix	 "$f"  "$prefix";    fi
   if [[ "$suffix" ]];	  then suffix	 "$f"  "$suffix";    fi
done
