mysql -uroot -p123456 -h127.0.0.1 -e "DROP DATABASE IF EXISTS dezhou;"
mysql -uroot -p123456 -h127.0.0.1 -e "CREATE DATABASE dezhou DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -uroot -p123456 -h127.0.0.1 -D dezhou < ./create_db.sql

pause