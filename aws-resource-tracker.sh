#!/bin/bash


###########
#Author : Sarnali
#Date : 9th Oct
#
#Version : v1
#
#This script will report the Aws resource usage

######
set -x

#Aws s3
#Aws EC2
#Aws Lambda
#Aws IAM Users

#start a new report file each time the script runs
echo "AWS Resource Tracker - $(date)" > resourceTracker

#list s3 buckets
echo "Print list of s3 buckets" >> resourceTracker
aws s3 ls >> resourceTracker

#list EC2 Instances
echo "Print list of ec2 instances" >> resourceTracker
aws ec2 describe-instances | jq -r '.Reservations[].Instances[].InstanceId' >> resourceTracker

#list lambda
echo "Print list of lambda functions" >> resourceTracker
aws lambda list-functions >> resourceTracker

#list IAM Users
echo "Print list of iam users" >> resourceTracker
aws iam list-users >> resourceTracker

