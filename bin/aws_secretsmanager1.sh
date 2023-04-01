#!/usr/bin/env bash

se=${1}

export AWS_DEFAULT_REGION=us-west-2
aws secretsmanager get-secret-value --secret-id ${se} | jq -r .SecretString | jq -r .BASESPACE_API_SERVER | tr -d '\n'
