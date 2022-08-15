#!/bin/bash

# flags that optionally take part in the script
# if help flag is presented, __help is invoked and script will exit
declare VERBOSE=false;
declare RECURSIVE=false;
declare _BAD_INPUTS=0;
declare _FAILED_INPUTS=0;
declare _SKIPPED_INPUTS=0;
declare _DECOMPRESSED_INPUTS=0;

# colors to be used for different echos
declare WHITE=`tput setaf 7`;
declare RED=`tput setaf 1`;
declare GREEN=`tput setaf 2`;
declare YELLOW=`tput setaf 3`;

# most decompressors use -f flag to force ovewrite a file
# however, in some case (like unzip) a different flag is used
# therefor, the force flag will be declared for each new decompressor added
declare -a FORCE_OVERWRITE=( [0]="-f" [1]="-f" [2]="-o" [3]="-f");
declare -a ALLOWED_COMPRESSORS=( [0]="gzip" [1]="x-bzip2" [2]="zip" [3]="x-compress" );
declare -a ALLOWED_DEOMPRESSORS=( [0]="gunzip" [1]="bunzip2" [2]="unzip" [3]="uncompress" );


__resultOutput() {
    echo "${WHITE}[SKIPPED]: ${1} | ${GREEN} [DECOMPRESSED]: ${2} | ${YELLOW} [BAD INPUTS]: ${3} | ${RED} [FAILED]: ${4}"
}

# the __log function will conditionally fire if -v flag is passed as argument
__log () {


    local LOG_LEVELS=([0]="alert" [1]="warning" [2]="success" [3]="info");
    local LOG_COLORS=([0]=${RED} [1]=${YELLOW} [2]=${GREEN} [3]=${WHITE});

    local LEVEL=$1
    shift
    if [ "$VERBOSE" = true ]; then
        echo "${LOG_COLORS[$LEVEL]}[${LOG_LEVELS[$LEVEL]}]" "$@${WHITE}"
    fi
}

# Display help function will conditionally fire if -h flag is passed as argument
__help() {
    echo "This script can upack any compression format"
    echo
    echo "Syntax: ./extract [-h|-v|-r] file [file...]"
    echo "options:"
    echo "-h     Print this __help."
    echo "-v     Verbose mode."
    echo "-r     Will run recursively on folders."
    echo
}


# the main logical instance in the script
# handles file input, folder input, recursive unpack and bad inputs
__processUserInput() {
    for INPUT in $@; do

        #  ***** case: FILE *****
        if [ -f "$INPUT" ] ; then
            processFile "$INPUT"
            let "_FILE_INPUTS++";
        #-----------------------------------------------#


        #  ***** case: DIRECTORY AND RECURSIVE *****
        elif [ -d "$INPUT" -a "$RECURSIVE" = true ] ; then
            local DIR=$(pwd);
            cd $INPUT
            for i in *; do
                __processUserInput $i;
            done
            cd $DIR
        #-----------------------------------------------#


        #  ***** case: DIRECTORY AND NOT RECURSIVE ***** 
        elif [ -d $INPUT -a "$RECURSIVE" = false ] ; then
            local DIR=$(pwd);
            cd $INPUT
            for i in *; do
                if [ -f "$i" ]; then
                    __processUserInput $i;
                fi
            done
            cd $DIR
        #-----------------------------------------------#


        #  ***** case: WRONG INPUT *****
        else
            __log 1 "${INPUT} not a file";
            let "_BAD_INPUTS++";
        fi
        #-----------------------------------------------#
    done
}


# file extractor that receives 3 arguments based on file format
# unpacks the provided file with the correct decompressor 
# overwrites an existing file if the unpacked result has the same name
__extractFile() {

    __onSucess() {
        __log 2 "Successfully unpacked ${1}";
        let "_DECOMPRESSED_INPUTS++";
    }

    __onFailure() {
        __log 0 "Failed to unpack ${1}";
        let "_FAILED_INPUTS++";
    }

    local FILE=$3
    local FORCE=$2
    local UNPACK=$1

    yes | ${UNPACK} ${FORCE} ${FILE} \
    && __onSucess $FILE || __onFailure $FILE
}


# using the file command and some regex to export the compression type
# chooses the correct decompressor and force flag and calls __extractFile with args
processFile() { 
    local PROCESSED_FILE=$1;
    local FILE_OUTPUT=$(file -b --mime-type ${PROCESSED_FILE})
    local FILE_FORMAT=$(echo "${FILE_OUTPUT}" | grep -o -P '(?<=\/).*' | xargs | awk '{print tolower($0)}');

    local _IS_COMPRESSED=false;

    for (( i=0; i<${#ALLOWED_COMPRESSORS[@]}; i++ )); do

        if [[ "$FILE_FORMAT" == ${ALLOWED_COMPRESSORS[i]} ]]; then
            
            _IS_COMPRESSED=true;

            local FORCE=${FORCE_OVERWRITE[i]}

            local UNPACK_WITH=${ALLOWED_DEOMPRESSORS[i]};

            __log 3 "${PROCESSED_FILE} will be unpacked with ${UNPACK_WITH}"

            __extractFile ${UNPACK_WITH} ${FORCE} ${PROCESSED_FILE};
        fi

    done

    if [ "$_IS_COMPRESSED" = false ]; then
        let "_SKIPPED_INPUTS++";
    fi
}

# counter: args to shift to get the list
declare shift=1; 

while getopts hrv opt; do
    case $opt in
        h)  
            __help
            exit
        ;;
        r) 
            RECURSIVE=true
            let "shift++"
        ;;
        v) 
            VERBOSE=true
            let "shift++"
        ;;
    esac
done

# skip flags if any
# file is considered named argument. everything that comes after 
# that is the list of files to process...
shift $shift;

__processUserInput $@ \
&& __resultOutput $_SKIPPED_INPUTS $_DECOMPRESSED_INPUTS $_BAD_INPUTS $_FAILED_INPUTS;