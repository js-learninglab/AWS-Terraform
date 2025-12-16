#! /bin/bash
#sudo amazon-linux-extras install -y nginx1
sudo dnf install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

sleep 10 

# download files from S3
aws s3 cp s3://${s3_bucket_name}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${s3_bucket_name}/website/JS_learningLab.png /home/ec2-user/JS_learningLab.png

# configure nginx to serve custom webpage
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/JS_learningLab.png /usr/share/nginx/html/JS_learningLab.png

sudo systemctl restart nginx