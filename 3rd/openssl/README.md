这里面编译好的windows版，而linux版本请自己安装  
安装

1.
wget https://codeload.github.com/openssl/openssl/tar.gz/OpenSSL_1_1_1-pre3.tar.gz

2.
tar -xvzf OpenSSL_1_1_1-pre3.tar.gz

./config --prefix=/usr/local/openssl

./config -t

make

make install

which openssl

openssl version