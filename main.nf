#!/usr/bin/env nextflow
nextflow.enable.dsl=1

/*
 * Define the pipeline parameters
 *
 */

// Pipeline version
version = '0.1'

params.help            = false
params.resume          = false

log.info """
project                   : ${params.project}
config                    : ${params.config}
seqtype                   : ${params.seqtype}
container                 : ${params.container}
output                    : ${params.output}
"""

// Help and avoiding typos
if (params.help) exit 1
if (params.resume) exit 1, "Are you making the classical --resume typo? Be careful!!!! ;)"

//if (params.GPU != "ON" && params.GPU != "OFF") exit 1, "Please specify ON or OFF in GPU processors are available"

def output_path = "${params.output}/Miseq/${params.project}/fastqs/"

//echo ${params.GPU} > gpu.log ; env > env.log ; find / -name 'libcuda*' > libcuda.log 2> libcuda.err || true ; nvidia-smi &> nvidia.log || true ; ls -l /proc/driver/nvidia/* > proc.log || true
// tensortest.py &> tensortest.log || true ;
//nvcc hello.cu -o hello


process copy_files{
        cpus 2
        memory 8.GB

        secret 'BASESPACE_API_SERVER'
        secret 'BASESPACE_API_TOKEN'

        container params.container

        publishDir "${params.output}/NextSeq/${params.project}/", mode: 'copy'

        errorStrategy 'ignore'
        output:
        file ("*.fastq.gz") into output


        script:
        """
        mkdir mytmp
        bs download project --api-server=\$BASESPACE_API_SERVER --access-token=\$BASESPACE_TOKEN -n ${params.project} -o mytmp --extension fastq.gz

        mv mytmp/*/*.fastq.gz .
        """
}
