// ...existing code...
#!/bin/bash
sudo amazon-linux-extras install -y nginx1
sudo yum install -y awscli
sudo systemctl enable nginx
sudo systemctl start nginx

# fetch logo from S3 (requires instance role with s3:GetObject)
aws s3 cp "s3://${bucket}/${key}" /usr/share/nginx/html/JS learninglab.png
sudo chmod 644 /usr/share/nginx/html/logo.png

sudo rm /usr/share/nginx/html/index.html
sudo cat > /usr/share/nginx/html/index.html << 'WEBSITE'
<html>
<head>
    <title>JS Learninglab title</title>
</head>
<body style="background-color:#1F778D">
    <p style="text-align: center;">
        <span style="color:#FFFFFF;">
            <span style="font-size:100px;">Welcome to the JS learninglab website! Have a &#127790;</span>
        </span>
    </p>
    <div style="text-align:center; margin-top:20px;">
      <img src="logo.png" alt="logo" style="max-width:60%; height:auto;">
    </div>
</body>
</html>
WEBSITE
// ...existing code...
WEBSITE