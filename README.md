# nf-basespace

Simple Nextflow pipeline for copying sequencing files from Illumina Basespace to aws s3 bucket by aws Batch

## Execution test

```
aws batch submit-job \
    --job-name nf-basespace \
    --job-queue priority-maf-pipelines \
    --job-definition nextflow-production \
    --container-overrides command="FischbachLab/nf-basespace, \
    "--project","230308_TY-16Sv4_KH9HP", \
    "--output", "s3://genomics-workflow-core/Results/Basespace" "
```
