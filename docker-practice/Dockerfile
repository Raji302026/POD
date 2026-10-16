FROM nginxinc/nginx-unprivileged:1.31-alpine
USER root
RUN apk upgrade --no-cache
COPY --chown=nginx:nginx index.html /usr/share/nginx/html/index.html
USER nginx
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1
