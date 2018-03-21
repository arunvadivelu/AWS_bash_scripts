
numargs=$#

if [ $numargs -ne 4 ]; then
    echo “wrong num of args”
exit
fi

USERNAME="${1,,}"
PASSWD=$2
FILEKEY=$3
FILEPATH=$4


SUFFIX="-arun-awstrials"
ALL_USER_BUCKET_NAME="allusersbucket-arun_awstrial"
USER_BUCKET_NAME=$USERNAME$SUFFIX
FILEKEY=${FILEKEY// /-}
S3_FPATH="s3://${ALL_USER_BUCKET_NAME}/${USERNAME}"
S3_DOWNLOADFILE="s3://${USER_BUCKET_NAME}/${FILEKEY}"

#echo "Checking All Users bucket exists..."

########Check if all buckets exist
S3_CHECK01=$(aws s3 ls "s3://${ALL_USER_BUCKET_NAME}" 2>&1)
  if [ $? != 0 ] 
  then
    NO_BUCKET_CHECK01=$(echo $S3_CHECK01 | grep -c 'NoSuchBucket')
    if [ $NO_BUCKET_CHECK01 = 1 ];then 
       echo "Bucket for managing credentials does not exist please create user account"
    else
        echo "Error checking S3 Bucket"
        exit 1
    fi
 else 
   echo "Bucket for managing credentials exists"
fi
#################### User Buckcet

S3_CHECK02=$(aws s3 ls "s3://${USER_BUCKET_NAME}" 2>&1)	
  if [ $? != 0 ] 
  then
    NO_BUCKET_CHECK02=$(echo $S3_CHECK02 | grep -c 'NoSuchBucket')
    if [ $NO_BUCKET_CHECK02 = 1 ];then 
       echo " Bucket for user upload does not exist.. please create a user acount"

    else
        echo "Error checking S3 Bucket"

        exit 1
    fi
 else 
   echo "User Bucket exists"
fi

########Check if User File Exist

newcount=`aws s3 ls $S3_DOWNLOADFILE | wc -l`
if [[ $newcount -gt 0 ]]; then
	echo "File with this keyname exist in S3.."
else 
	echo "FIle with this keyname doesnt exist.. please try again."

fi



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
		echo "Pass word matches..."

		if [ -f "$FILEPATH" ]; then	   
	    		echo "$FILEPATH found."
	    		aws s3 cp "${S3_DOWNLOADFILE}" "${FILEPATH}" 
        	else 
			echo "Directory with the name $FILEPATH not found..so will be created and downloaded"			
			mkdir -p ${FILEPATH}
			aws s3 cp "${S3_DOWNLOADFILE}" "${FILEPATH}"
	    		
		fi

	else 
	   	echo "password do not match"
	fi
	rm "./${USERNAME}"

else
       echo "User credentials does not exist.. Please create new...."

fi



