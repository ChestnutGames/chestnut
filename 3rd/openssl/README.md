# windows版已经编译好
# linux版请自己安装  
## 步骤如下

* 1 下载资源 wget https://codeload.github.com/openssl/openssl/tar.gz/OpenSSL_1_1_1-pre3.tar.gz
* 2 解压 tar -xvzf OpenSSL_1_1_1-pre3.tar.gz
* 3 mkdir /usr/local/openssl
* 4 ./config --prefix=/usr/local/openssl
* 5 ./config -t
* 6 make && make install
* 7 可以去/usr/local/openssl查看安装了些什么
* 8 cd /usr/local
* 9 ldd /usr/local/openssl/bin/openssl
* 10 which openssl
* 11 openssl version
