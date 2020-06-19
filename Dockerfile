FROM debian AS modsec-builder

RUN apt update && apt install -y \
      apt-utils autoconf \
      automake build-essential \
      git libcurl4-openssl-dev \
      libgeoip-dev liblmdb-dev \
      libpcre++-dev libtool \
      libxml2-dev libyajl-dev \
      pkgconf wget zlib1g-dev

WORKDIR /build

RUN git clone --depth 1 -b v3/master \
      --single-branch https://github.com/SpiderLabs/ModSecurity \
      && cd ModSecurity i \
      && git submodule init \
      && git submodule update \
      && ./build.sh \
      && ./configure \
      && make \
      && make install

RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git \
      && wget http://nginx.org/download/nginx-1.19.0.tar.gz \
      && tar zxvf nginx-1.19.0.tar.gz \
      && cd nginx-1.19.0 \
      && ./configure --with-compat --add-dynamic-module=../ModSecurity-nginx \
      && make modules 


FROM nginx/nginx-ingress:alpine

COPY --from=modsec-builder /build/nginx-1.19.0/objs/ngx_http_modsecurity_module.so /etc/nginx/modules

