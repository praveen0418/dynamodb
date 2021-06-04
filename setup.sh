#!/bin/bash

. ./constant

echo componentName $componentName
echo partName $partName

. ./config

helpFunction()
{
   echo ""
   echo "Usage: $0 -p aws-profile -e environment"
   echo "\t-p AWS profile set of credentials"
   echo "\t-e environment name e.g. dev | staging | prod"
   echo "\t-r AWS Region"
   exit 1 # Exit script after printing help
}

while getopts "p:e:r:" opt
do
   case "$opt" in
      p ) profileParameter="$OPTARG" ;;
      e	) environment="$OPTARG" ;;
      r ) awsRegion="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

profileParameterOpt=" --profile $profileParameter"
awsProfileParameterOpt=" --aws-profile $profileParameter"

validateEnvironmentVariables()
{
    if [ -z "$profileParameter" ]
    then
        echo missing profileParameter
        profileParameterOpt=""
        awsProfileParameterOpt=""
    fi
    if [ -z "$environment" ]
    then
        echo missing environment
        helpFunction
    fi
    if [ -z "$awsRegion" ]
    then
        echo missing awsRegion
        helpFunction
    fi
}

validateEnvironmentVariables

echo -----------------------------------------------------------------------
echo Running $componentName-$partName-iac setup.sh for $environment
echo -----------------------------------------------------------------------

AwsbackupdynamodbCloudFormationStackName="$environment"-"$componentName"-"$partName"-iac-dynamodb

echo Deploy DynamoDB CloudFormation template



aws cloudformation deploy --template-file dynamodb-backup.yaml \
--stack-name "$AwsbackupdynamodbCloudFormationStackName" \
--parameter-overrides file://parameters/$environment/dynamodb-backup.json \
--capabilities CAPABILITY_NAMED_IAM \
--no-fail-on-empty-changeset \
--region $awsRegion $profileParameterOpt 

