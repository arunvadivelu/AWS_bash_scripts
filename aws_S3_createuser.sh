# arun pwd email
numargs=$#
if [ $numargs -ne 3 ]; then
	echo “wrong num of args”
exit
fi
USERNAME="${1,,}"
PASSWD=$2
EMAIL=$3
SUFFIX="-arun-awstrials"
ALL_USER_BUCKET_NAME="allusersbucket-arun_awstrial"
echo "Checking common Bucket for manging User credentials..."
USER_BUCKET_NAME=$USERNAME$SUFFIX

########Check if all buckets exist
S3_CHECK01=$(aws s3 ls "s3://${ALL_USER_BUCKET_NAME}" 2>&1)
  if [ $? != 0 ] 
  then
    NO_BUCKET_CHECK01=$(echo $S3_CHECK01 | grep -c 'NoSuchBucket')
    if [ $NO_BUCKET_CHECK01 = 1 ];then 
       echo "Common Bucket for manging User credentials does not exist"
       aws s3 mb "s3://${ALL_USER_BUCKET_NAME}"
       echo "Common Bucket for manging User credentials succesfully created"
    else
        echo "Error checking S3 Bucket"
        exit 1
    fi
 else 
   echo "Common Bucket for manging User credentials exists"
fi
#################### User Buckcet


S3_CHECK02=$(aws s3 ls "s3://${USER_BUCKET_NAME}" 2>&1)	
  if [ $? != 0 ] 
  then
    NO_BUCKET_CHECK02=$(echo $S3_CHECK02 | grep -c 'NoSuchBucket')
    if [ $NO_BUCKET_CHECK02 = 1 ];then 
       echo "Bucket for user upload does not exist"
       aws s3 mb "s3://${USER_BUCKET_NAME}"
       echo "Bucket for user upload succesfully created"
    else
        echo "Error checking S3 Bucket"
        exit 1
    fi
 else 
   echo "Bucket for user uploads exists"
fi

########Check if User File Exist

FPATH="s3://${ALL_USER_BUCKET_NAME}/${USERNAME}"
count=`aws s3 ls $FPATH | wc -l`

if [[ $count -gt 0 ]]; then
        echo "user credential file exists.. Password and EMail will be updated..."
	cat >".//${USERNAME}"<< EOF
$PASSWD,$EMAIL
EOF

	aws s3 cp ".//${USERNAME}" "s3://${ALL_USER_BUCKET_NAME}/"
else
        echo "user credentials file does not exist.. will be created new...."
	
	
	cat >".//${USERNAME}"<< EOF
$PASSWD,$EMAIL
EOF

	aws s3 cp ".//${USERNAME}" "s3://${ALL_USER_BUCKET_NAME}/"
	
fi
rm ".//${USERNAME}"


#########################




