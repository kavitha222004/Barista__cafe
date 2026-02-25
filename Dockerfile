FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY app/ /usr/share/nginx/html/

RUN chown -R nginx:nginx /usr/share/nginx/html

USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
