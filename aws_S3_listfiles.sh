numargs=$#

if [ $numargs -ne 2 ]; then
    echo “wrong num of args”
exit
fi

USERNAME="${1,,}"
PASSWD=$2

SUFFIX="-arun-awstrials"
ALL_USER_BUCKET_NAME="allusersbucket-arun_awstrial"
USER_BUCKET_NAME=$USERNAME$SUFFIX
S3_FPATH="s3://${ALL_USER_BUCKET_NAME}/${USERNAME}"


########Check if all buckets exist
S3_CHECK01=$(aws s3 ls "s3://${ALL_USER_BUCKET_NAME}" 2>&1)
  if [ $? != 0 ] 
  then
    NO_BUCKET_CHECK01=$(echo $S3_CHECK01 | grep -c 'NoSuchBucket')
    if [ $NO_BUCKET_CHECK01 = 1 ];then 
       echo "All users Bucket does not exist please create user account"
    else
        echo "Error checking S3 Bucket"
        #echo "$S3_CHECK01"
        exit 1
    fi
 else 
   echo "Bucket for managing user credentials exists"
fi
#################### User Buckcet

echo "Checking if bucket for user upload exists..."
S3_CHECK02=$(aws s3 ls "s3://${USER_BUCKET_NAME}" 2>&1)	
  if [ $? != 0 ] 
  then
    NO_BUCKET_CHECK02=$(echo $S3_CHECK02 | grep -c 'NoSuchBucket')
    if [ $NO_BUCKET_CHECK02 = 1 ];then 
       echo "Bucket for user upload does not exist.. please create a user acount"

    else
        echo "Error checking S3 Bucket"
        exit 1
    fi
 else 
   echo "Bucket for user upload exists"
fi

########Check if User File Exist


count=`aws s3 ls $S3_FPATH | wc -l`
if [[ $count -gt 0 ]]; then
        echo "User credentials exists.. Password and EMail will be checked..."
	#copy the user credential to local path
	aws s3 cp ${S3_FPATH} "./${USERNAME}"
	
	while read -r LINE
	    do
    		name="$line"
		PASSWORD=`echo $LINE | cut -d \, -f 1`

	done < "./${USERNAME}"
	
	if [ "$PASSWORD" == "$PASSWD" ]; then
		echo "Password matches..."

		newcount=`aws s3 ls $USER_BUCKET_NAME | wc -l`
		if [[ $newcount -gt 0 ]]; then
			echo "Files int eh S3 User bucket:"
			aws s3 ls ${USER_BUCKET_NAME} --recursive
		else 
		echo "No files exist in this bucket"

		fi

	else 
	   	echo "password do not match"
	fi
	rm "./${USERNAME}"

else
       echo "User credentials does not exist.. Please create new...."

fi



