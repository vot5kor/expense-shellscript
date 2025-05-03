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
dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Nodejs20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Nodejs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "Creating expense user"
else
    echo -e "User already exists .... $Y SKIPPING $N"
fi
# -p: if not exist creating else no error
mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating app Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Download the application code"

cd /app
VALIDATE $? "Goto app directoty"

rm -rf /app/*
VALIDATE $? "removing all files in app directory"

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? " Unzip the backend "

npm install &>>$LOG_FILE_NAME
VALIDATE $? " Installing Dependencies "
#We need to setup a new service in systemd so systemctl can manage this service
#Setup SystemD Expense Backend Service
#vim /etc/systemd/system/backend.service
#cp backend.service /etc/systemd/system/backend.service
cp /home/ec2-user/expense-shellscript/backend.service /etc/systemd/system/backend.service

#Prepare MYSQL Schema
dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MYSQL Client"


mysql -h mysql.tuktukride.online -u root -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting up transactions schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Demoan Reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Backend"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "re-start Backend"


