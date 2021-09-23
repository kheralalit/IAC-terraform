#! /bin/bash
sudo yum update -y
sudo amazon-linux-extras install epel -y
sudo yum install java-1.8* -y
sudo yum -y install wget
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum -y install jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo yum install python python-devel python-pip openssl ansible -y

