FROM openresty/openresty:1.27.1.2-noble

# Fetch from luarocks, and set git options if required
RUN apt-get update && apt-get install git -y
RUN git config --global url."https://".insteadOf git:// && \
    git config --global advice.detachedHead false && \
    luarocks install lua-resty-oauth-proxy   1.3.0 && \
    luarocks install lua-resty-phantom-token 2.0.1
