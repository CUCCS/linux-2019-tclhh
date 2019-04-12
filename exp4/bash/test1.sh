#! /bin/env bash


function usage
{
    echo "Usage:"
    echo "  -i  --input <filename>              Input image for processing"
    echo "  -o  --output <filename>             Output image for saving"
    echo "  -q, --quality <percent>             Image quality compression"
    echo "  -r, --resolution <percent>          Image resolution compression"
    echo "  -w, --watermark <text>              Add text watermark"
    echo "  -p, --prefix <prefix>               Add prefix"
    echo "  -s, --suffix <suffix>               Add suffix"
    echo "  -t, --transform                     Transform image format"
    echo "  -h, --help                          get the help info"
}



function proc_opts {
while getopts ":i:q:r:w:t:hs:p:" opt
  do 
	case "${opt}" in
   	  "w") if [[ ${OPTARGS} ]] ;then
		  watermark=${OPTARG} 
	       else 
		  echo "[-] ERROR: The watermark cannot be empty!"
		  echo "[+] You cau use -h to get help!" 
		  return 1
	       fi ;;
	
   	  "q")
		if [[ ${OPTARGS} ]] ;then 
		   quality=${OPTARGS}		
		else
		   echo "[-] ERROR: The compression quality cannot be empty!"
		   echo "[+] You cau use -h to get help!"
		   return 2
		fi ;;
	  "r") 
		if [[ ${OPTARGS} ]] ;then
		   resolution=${OPTARGS}
		else
		   echo "[-] ERROR: The compression resolution cannot be empty!"
		   echo "[+] You cau use -h to get help!"
		   return 3
		fi ;;
	   "i") 
		if [[ ${OPTARGS}&& -f ${OPTARGS} ]] ;then
		   input=${OPTARGS}
		else 
		   echo "[-] ERROR: The input file error!"
	    	   echo "[+] You cau use -h to get help!"
		   exit 4
		fi ;;
	   "o") 
		if [[ ${OPTARGS} ]] ;then
		   output=${OPTARGS}
		else 
		   echo "[-] ERROR: The output file cannot be empty!"
	    	   echo "[+] You cau use -h to get help!"
		   exit 5
		fi ;;
	   "s") 
		if [[ ${OPTARGS} ]] ;then
		   suffix=${OPTARGS}
		else
		   echo "[-] ERROR: The suffix cannot be empty!"
	    	   echo "[+] You cau use -h to get help!"
		   exit 6
		fi ;;
	   "p") 
		if [[ ${OPTARGS} ]] ;then
		   prefix=${OPTARGS}
		else
		   echo "[-] ERROR: The prefix cannot be empty!"
	    	   echo "[+] You cau use -h to get help!"
		   exit 7
		fi ;;
	    "t")
		if [[ ${OPTARGS} ]] ;then
		   transfer=${OPTARGS}
		else
		   echo "[-] ERROR: The transfer format cannot be empty!"
	    	   echo "[+] You cau use -h to get help!"
		   exit 8
		fi ;;
	    "h")	
    		 usage ;;
	    "?")
		 echo "[-] ERROR: Unknow option $OPTARG"
		 exit 9 ;;
	    ":")
		 echo "[-] ERROR: No argument value for option $OPTARG"
		 exit 10 ;;
   	    *) #Should not occur
		 echo "[-] ERROR: Unknown error while processing options"
		 ;;
	esac
  done
}


function quality
{
   $(convert $1 -quality $2 $3)
   echo "[+] Quality compresses successfully!"
}


function resolution
{
   $(convert $1 -resize $2 $3)
   echo "[+] Resolution compresses successfully!"
}


function textwatermark
{
   $(convert $1 -draw )
}


function format
{
   $(convert $1 $2)
   echo "[+] Format transformes successfully!"
}


proc_opts $@

