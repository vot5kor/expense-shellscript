#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
FILE_NAME=$(echo $0 | cut -d "." -f1  )
echo "test: FILE_NAME"
TIMESTAMP=$(date  +%Y-%m-%d:%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$FILE_NAME-$TIMESTAMP.log"
echo "test: $LOG_FILE_NAME" &>>$LOG_FILE_NAME
echo "test: $1"
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

echo "test: $USERID"
CHECK_ROOT(){
if [ $USERID -ne 0 ]
then
    echo "ERROR:: You must have sudo access to execute this script"
    echo "test: $USERID"
    exit 1 #other than 0
fi
}

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabling mysql server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Start mysql server"

mysql -h mysql.tuktukride.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    echo "mysql root password not setup" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE_NAME
    VALIDATE $? "Setting root password"
else
    echo -e "mysql root password already setup .... $Y SKIPPING $N"
fi







