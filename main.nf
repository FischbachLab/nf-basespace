#!/usr/bin/env nextflow
nextflow.enable.dsl=2

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
seqtype                   : ${params.seqtype}
output                    : ${params.output}
"""

// Help and avoiding typos
if (params.help) exit 1

//def output_path = "${params.output}/Miseq/${params.project}/fastqs/"
/*
Get the aws secret server and token
Test aws secret id
{
   "ARN": "arn:aws:secretsmanager:us-west-2:458432034220:secret:BASESPACE_API_SERVER-tPjWUU",
   "Name": "BASESPACE_API_SERVER",
   "VersionId": "8909b99d-75e2-4183-bf7b-efef5504fe09",
   "SecretString": "{\"BASESPACE_API_SERVER\":\"https://api.basespace.illumina.com\"}",
   "VersionStages": [
       "AWSCURRENT"
   ],
   "CreatedDate": "2023-03-27T14:23:12.158000-07:00"
}
*/
/*
process aws_test{
        cpus 2
        memory 8.GB

        container 'fischbachlab/nf-json-processor:latest'

        input:

        output:
        val server into server_ch
        val token into token_ch

        script:
        """
        export AWS_DEFAULT_REGION=us-west-2
        server=\$(aws secretsmanager get-secret-value --secret-id BASESPACE_API_SERVER | jq -r .SecretString | jq -r .BASESPACE_API_SERVER)
        token=\$(aws secretsmanager get-secret-value --secret-id BASESPACE_API_TOKEN | jq -r .SecretString | jq -r .BASESPACE_API_TOKEN)
        """
}
*/

process aws_test1{
        cpus 2
        memory 8.GB

        container 'fischbachlab/nf-json-processor:latest'

        input:
        val x
        output:
        stdout

        script:
        """
        aws_secretsmanager1.sh $x
        """
}
process aws_test2{
        cpus 2
        memory 8.GB

        container 'fischbachlab/nf-json-processor:latest'

        input:
        val x
        output:
        stdout

        script:
        """
        aws_secretsmanager2.sh $x
        """
}


/*
Transfer files from Basespace to s3
*/
def seq="MiSeq"
if (  params.seqtype == "miseq" || params.seqtype == "Miseq" || params.seqtype == "MiSeq" )
  seq="MiSeq"
else
  seq="NextSeq"

process transfer_seq_files{
        cpus 2
        memory 8.GB

        //secret 'BASESPACE_API_SERVER'
        //secret 'BASESPACE_API_TOKEN'

        container params.container

        publishDir "${params.output}/${seq}/${params.project}/", mode: 'copy', overwrite: true

        input:
        val ser
        val tok

        output:
        path ("fastqs/*.fastq.gz"), optional: true
        path ("*.fastq.gz"), optional: true

        script:

        if (  params.seqtype == "miseq" || params.seqtype == "Miseq" || params.seqtype == "MiSeq" )
          """
          mkdir fastqs mytmp
          bs download project --api-server=$ser --access-token=$tok -n ${params.project} -o mytmp --extension fastq.gz
          mv -f mytmp/*/*.fastq.gz fastqs
          """
        else if ( params.seqtype == "nextseq" || params.seqtype == "Nextseq" || params.seqtype == "NextSeq")
          """
          process_nextseq.sh $ser $tok ${params.project} ${params.output}
          mv tmp_*/fastqs/*.fastq.gz .
          """
        else
          throw new IllegalArgumentException("Unknown seqtype $params.seqtype")
}

workflow {
                ch1 = Channel.from('BASESPACE_API_SERVER')
                ch2 = Channel.from('BASESPACE_API_TOKEN')
                out1 = aws_test1(ch1)
                out2 = aws_test2(ch2)
                out3 = transfer_seq_files(out1, out2)

}
