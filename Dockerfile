FROM lsiobase/alpine:3.7

# set maintainer and version labels
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	boost-dev \
	bzip2-dev \
	clang \
	cmake \
	curl \
	g++ \
	gcc \
	geoip-dev \
	git \
	libstdc++ \
	make \
	miniupnpc-dev \
	nodejs \
	openssl \
	openssl-dev \
	pkgconfig \
	python-dev \
	tar \
	zlib-dev && \
 apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	leveldb-dev \
	libtbb-dev && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	boost \
	geoip \
	libbz2 \
	miniupnpc && \
 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	leveldb \
	libtbb && \
 echo "**** compile websocketpp ****" && \
 git clone git://github.com/zaphoyd/websocketpp.git /tmp/websocket && \
 cd /tmp/websocket && \
 cmake \
	-DCMAKE_INSTALL_PREFIX:PATH=/usr . && \
 make install && \
 echo "**** compile airdcpp ****" && \
 git clone https://github.com/airdcpp-web/airdcpp-webclient.git /tmp/airdcpp && \
 git -C /tmp/airdcpp checkout $(git -C /tmp/airdcpp describe --tags --candidates=1 --abbrev=0) && \
 cd /tmp/airdcpp && \
 cmake \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX:PATH=/usr . && \
 make && \
 set +ex && \
 make install && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/* && \
 find /root -name . -o -prune -exec rm -rf -- {} + && \
 mkdir -p \
	/root

# environment variables
ENV HOME="/config"

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 5600 5601
VOLUME /config
