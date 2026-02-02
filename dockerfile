FROM nginx:alpine

COPY website/index.html /usr/share/nginx/html/
COPY website/JS_learningLab.png /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]