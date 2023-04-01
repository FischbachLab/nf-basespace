# nf-basespace

Simple Nextflow pipeline for copying sequencing files from Illumina Basespace to aws s3 bucket by aws Batch

## Execution example
### The 1st DSL2 workflow
#### --seqtype option is either MiSeq or NextSeq
#### --project option requires to provide the project name showed in Illumina Basespace

#### Miseq example
```
aws batch submit-job \
    --job-name nf-basespace \
    --job-queue priority-maf-pipelines \
    --job-definition nextflow-production \
    --container-overrides command="FischbachLab/nf-basespace, \
    "--seqtype", "MiSeq", \
    "--project","230308_TY-16Sv4_KH9HP", \
    "--output", "s3://genomics-workflow-core/Results/Basespace" "
```
#### MiSeq data are saved at
```
s3://genomics-workflow-core/Results/Basespace/MiSeq/230308_TY-16Sv4_KH9HP/
```

#### MextSeq example
```
aws batch submit-job \
    --job-name nf-basespace \
    --job-queue priority-maf-pipelines \
    --job-definition nextflow-production \
    --container-overrides command="FischbachLab/nf-basespace, \
    "--seqtype", "NextSeq", \
    "--project","230310_AZ-WGS_HT52TBGXN", \
    "--output", "s3://genomics-workflow-core/Results/Basespace" "
```
####  NextSeq data are saved at
```
s3://genomics-workflow-core/Results/Basespace/NextSeq/230310_AZ-WGS_HT52TBGXN/
```
