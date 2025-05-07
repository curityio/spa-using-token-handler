FROM nginx:1.27.4-alpine

# Download the built modules from Curity GitHub repo
RUN curl -s -L 'https://github.com/curityio/nginx_phantom_token_module/releases/download/2.0.0/alpine.ngx_curity_http_phantom_token_module_1.27.4.so' > /usr/lib/nginx/modules/ngx_curity_http_phantom_token_module.so
RUN curl -s -L 'https://github.com/curityio/nginx_oauth_proxy_module/releases/download/1.6.0/alpine.ngx_curity_http_oauth_proxy_module_1.27.4.so'     > /usr/lib/nginx/modules/ngx_curity_http_oauth_proxy_module.so
