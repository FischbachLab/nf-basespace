#!/usr/bin/env bash

to=${1}

export AWS_DEFAULT_REGION=us-west-2
aws secretsmanager get-secret-value --secret-id ${to} | jq -r .SecretString | jq -r .BASESPACE_API_TOKEN | tr -d '\n'
