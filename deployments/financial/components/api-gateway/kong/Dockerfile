FROM kong:3.9-ubuntu

USER root
RUN apt-get update
RUN apt-get install -y git unzip wget

RUN git config --global url."https://".insteadOf git:// && \
    git config --global advice.detachedHead false && \
    luarocks install kong-oauth-proxy   1.3.0 && \
    luarocks install kong-phantom-token 2.0.1

USER kong
