FROM centos:centos7.9.2009
MAINTAINER doijanky
ENV TZ=Asia/Shanghai
RUN yum update -y
RUN yum install -y bash curl unzip gettext epel-release yum-utils gcc gcc-c++ automake pcre pcre-devel zlip zlib-devel openssl openssl-devel
RUN mkdir -p /etc/BW_FBAE/SH/Install
RUN mkdir -p /etc/BW_FBAE/Page/Web_Page/HomePage
RUN mkdir -p /etc/BW_FBAE/Config/Core_Server
RUN mkdir -p /etc/BW_FBAE/Server/Core_Server
RUN mkdir /etc/BW_FBAE/Server/Web_Server
RUN mkdir /etc/BW_FBAE/Temp
RUN mkdir -p /etc/BW_FBAE/Temp/Server/Web_Server
RUN curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL tengine.taobao.org/download/tengine-2.3.3.tar.gz -o /etc/BW_FBAE/Temp/Server/Web_Server/tengine-2.3.3.tar.gz
RUN tar -xzvf /etc/BW_FBAE/Temp/Server/Web_Server/tengine-2.3.3.tar.gz -C /etc/BW_FBAE/Temp/Server/Web_Server/
WORKDIR /etc/BW_FBAE/Temp/Server/Web_Server/tengine-2.3.3
RUN /etc/BW_FBAE/Temp/Server/Web_Server/tengine-2.3.3/configure --prefix=/etc/BW_FBAE/Server/Web_Server --add-module=/etc/BW_FBAE/Temp/Server/Web_Server/tengine-2.3.3/modules/ngx_http_upstream_check_module --with-stream --with-stream_ssl_module
RUN make && make install
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ENV LANG=en_US.UTF-8
WORKDIR /etc/BW_FBAE/Server/Web_Server
RUN mkdir -p /etc/BW_FBAE/Server/Web_Server/conf/conf.d
RUN mkdir -p /etc/BW_FBAE/Server/Web_Server/conf/stream.d
RUN rm -rf /etc/BW_FBAE/Temp/*
COPY Page/Web_Page/HomePage /etc/BW_FBAE/Page/Web_Page/HomePage
COPY SH/Install/BW_FBAE_Install.sh /etc/BW_FBAE/SH/Install/BW_FBAE_Install.sh
RUN chmod +x /etc/BW_FBAE/SH/Install/BW_FBAE_Install.sh
ENTRYPOINT ["sh", "/etc/BW_FBAE/SH/Install/BW_FBAE_Install.sh"]