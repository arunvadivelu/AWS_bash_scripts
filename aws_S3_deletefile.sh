# arun pwd email
numargs=$#

if [ $numargs -ne 3 ]; then
    echo “wrong num of args”
exit
fi

USERNAME="${1,,}"
PASSWD=$2
FILEKEY=$3


SUFFIX="-arun-awstrials"
ALL_USER_BUCKET_NAME="allusersbucket-arun_awstrial"
USER_BUCKET_NAME=$USERNAME$SUFFIX
FILEKEY=${FILEKEY// /-}
S3_FPATH="s3://${ALL_USER_BUCKET_NAME}/${USERNAME}"
S3_FILE="s3://${USER_BUCKET_NAME}/${FILEKEY}"


########Check if all buckets exist

S3_CHECK01=$(aws s3 ls "s3://${ALL_USER_BUCKET_NAME}" 2>&1)
  if [ $? != 0 ] 
  then
    NO_BUCKET_CHECK01=$(echo $S3_CHECK01 | grep -c 'NoSuchBucket')
    if [ $NO_BUCKET_CHECK01 = 1 ];then 
       echo "Bucket for user credentials does not exist please create user account"

    else
        echo "Error checking S3 Bucket"

        exit 1
    fi
 else 
   echo "Bucket for user credentials exists"
fi
#################### User Buckcet

echo "Checking if bucket for user upload exists..."

S3_CHECK02=$(aws s3 ls "s3://${USER_BUCKET_NAME}" 2>&1)	
  if [ $? != 0 ] 
  then
    NO_BUCKET_CHECK02=$(echo $S3_CHECK02 | grep -c 'NoSuchBucket')
    if [ $NO_BUCKET_CHECK02 = 1 ];then 
       echo "bucket for user upload does not exist.. please create a user acount"

    else
        echo "Error checking S3 Bucket"
 
        exit 1
    fi
 else 
   echo "Bucket for user upload exist"
fi

########Check if User File Exist


count=`aws s3 ls $S3_FPATH | wc -l`
if [[ $count -gt 0 ]]; then
        echo "User credentials exists.. Password and EMail will be checked..."
	aws s3 cp ${S3_FPATH} "./${USERNAME}"
	
	while read -r LINE
	    do
    		name="$line"
		PASSWORD=`echo $LINE | cut -d \, -f 1`

	done < "./${USERNAME}"
	
	if [ "$PASSWORD" == "$PASSWD" ]; then
		echo "Password matches..."

		newcount=`aws s3 ls $S3_FILE | wc -l`
		if [[ $newcount -gt 0 ]]; then
			echo "File with this keyname exist in S3 will be deleted."
			aws s3 rm $S3_FILE
			
		else 
			echo "File with this key name doesnt exist in S3."

fi

	else 
	   	echo "password do not match"
	fi
	rm "./${USERNAME}"

else
       echo "User credentials does not exist.. Please create new...."

fi




