FROM kong:3.7.0-ubuntu

# Fetch from luarocks, and set git options if required
USER root
RUN git config --global url."https://".insteadOf git:// && \
    git config --global advice.detachedHead false && \
    luarocks install kong-oauth-proxy   1.3.0 && \
    luarocks install kong-phantom-token 2.0.1

USER kong
