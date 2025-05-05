#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
FILE_NAME=$(echo $0 | cut -d "." -f1  )
echo "test: $FILE_NAME"
TIMESTAMP=$(date  +%Y-%m-%d:%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$FILE_NAME-$TIMESTAMP.log"
echo "test: $LOG_FILE_NAME" &>>$LOG_FILE_NAME


VALIDATE()
{
             if [ $1 -ne 0 ]
                then # not Installed
                echo -e "$2 ... $R FAILURE $N"
                exit 1
                else
                 echo -e "$2 ... $G SUCCESS $N"
            fi
}
CHECK_ROOT(){
if [ $USERID -ne 0 ]
then
    echo "ERROR:: You must have sudo access to execute this script"
    echo "test: $USERID"
    exit 1 #other than 0
fi
}

mkdir -p $LOGS_FOLDER 
VALIDATE $? "creating expense-logs folder "

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT
dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Install Nginx server"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enable Nginx server"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "Start Nginx server"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Removing the existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Download the latest code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "Moving to HTML directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Unzipping the frontend code"

systemctl enable nginx >>$LOG_FILE_NAME
VALIDATE $? "Enable Nginx"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "re-start the Nginx server"