mysql -uroot -proot -h127.0.0.1 -e "drop database if exists race"
mysql -uroot -proot -h127.0.0.1 -e "CREATE DATABASE race DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"
mysql -uroot -proot -h127.0.0.1 -D race < ./create_db.sql

pause