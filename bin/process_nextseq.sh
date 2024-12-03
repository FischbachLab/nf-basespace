#!/usr/bin/env bash
set -x
set -e
set -u
set -o pipefail

s=${1} #server
t=${2} #token
p=${3} #project
o=${4} #out_path

# export $@
echo $PATH

LOCAL=.

# Setup directory structure
OUTPUTDIR=${LOCAL}/tmp_$( date +"%Y%m%d_%H%M%S" )

MYTMP="${OUTPUTDIR}/mytmp"

FASTQS="${OUTPUTDIR}/fastqs"

mkdir -p "${MYTMP}" "${FASTQS}"

bs download project --api-server=${s} --access-token=${t} -n ${p} -o ${MYTMP} --extension fastq.gz

bs list biosample --api-server=${s} --access-token=${t} --project-name=${p}  -f csv | tail -n+2 | cut  -f1 -d, > ${MYTMP}/sample_list.txt

#cat ${MYTMP}/sample_list.txt | awk  '{system(" cat "$MYTMP"/"$1"*/*_R1_001.fastq.gz > "$FASTQS"/"$1"_R1.fastq.gz &&  cat "$MYTMP"/"$1"*/*_R2_001.fastq.gz > "$FASTQS"/"$1"_R2.fastq.gz ")}'

for i in $(cat ${MYTMP}/sample_list.txt )
do
        # Check if the fastq file exists
        if ls "$MYTMP"/${i}*/*_R1_001.fastq.gz 1> /dev/null 2>&1;  then
                cat "$MYTMP"/${i}*/*_R1_001.fastq.gz > "$FASTQS"/${i}_R1.fastq.gz &&  cat "$MYTMP"/${i}*/*_R2_001.fastq.gz > "$FASTQS"/${i}_R2.fastq.gz
        else
                echo "Sample ${i} does not exist."
        fi

done



#aws s3 sync ${FASTQS} $o/NextSeq/${t}/
