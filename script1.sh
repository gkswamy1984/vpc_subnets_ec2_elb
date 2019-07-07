#!/bin/sh
set -x
yum update
yum install -y httpd
service httpd start
chkonfig httpd on
echo "<html><h1>Hello from server1</h2></html>" > /var/www/html/index.html

