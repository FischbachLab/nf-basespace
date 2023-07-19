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

# check files to move/copy the latest version of fastq files in case of duplicated samples
for i in ${MYTMP}/*/*.fastq.gz
do
   fastq_name=$(basename "$i")
   fastq_dir=$(dirname "$i")
   fastq_size=$(stat -c %s  "$fastq_dir/$fastq_name")

   is_exist=false
    for file in "$FASTQS"/*
    do
      # Extract the file name from the path
      file_name=$(basename "$file")
      file_dir=$(dirname "$file")

      # Check if the file name matches the desired filename
      if [[ "$file_name" == "$fastq_name" ]]; then
         echo "File $fastq_name exists in the directory."
         # full_path=$(find $directory -type f -name $filename)

         # Get the size of file
         file_size=$(stat -c %s "$file")
         if [[ $fastq_size -gt $file_size ]]; then
             echo "Override the small file"
             cp -f "$fastq_dir/$fastq_name" $FASTQS
         fi
         is_exist=true
         break
      fi
    done

  if [ -f "$fastq_dir/$fastq_name" ] && [ "$is_exist" == false ]; then
     echo "new file: coping file"
     mv "$fastq_dir/$fastq_name" $FASTQS
  fi

done
