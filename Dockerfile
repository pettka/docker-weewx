# https://uninterrupted.tech/blog/creating-docker-images-that-can-run-on-different-platforms-including-raspberry-pi/
# docker buildx create --driver=docker-container --name=multi --use
# docker buildx build --platform linux/amd64,linux/arm64 --push -t pettka/weewx:4.5.1 .

FROM alpine as downloader

WORKDIR /download
# RUN apk add wget
RUN apk add wget \
    && wget -O neowx-material-latest.zip https://neoground.com/neowx-material/download/latest \
    && wget -O weewx-windy.zip https://github.com/matthewwall/weewx-windy/archive/master.zip \
    && wget -O inigo-metric.tar.gz https://github.com/evilbunny2008/weeWXWeatherApp/releases/download/1.0.3/inigo-metric.tar.gz \
    && wget -O inigo-settings.txt https://github.com/evilbunny2008/weeWXWeatherApp/releases/download/1.0.3/inigo-settings.txt


FROM felddy/weewx:4.5.1

expose 8088

COPY --from=downloader /download /download

# https://github.com/CheetahTemplate3/cheetah3/issues/7#issuecomment-450046009
ENV CHEETAH_C_EXTENSIONS_REQUIRED=1
RUN apt update && apt -y install \
    rsync \
    openssh-client \
    # https://groups.google.com/g/weewx-user/c/qAF7Fn7D3h8/m/jEsNZGGWUp4J
    gcc \
    # python3-cheetah
    && pip3 install Cheetah3 \
    pyephem \
    Image \ 
    # Pillow
    # https://stackoverflow.com/a/76620194 https://github.com/python-pillow/Pillow/issues/7149
    Pillow==9.4.0
    # python3-dev python3-pip && pip3 install pyephem 
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

VOLUME /data/public_html
RUN mkdir -p /data/public_html \
    && ./bin/wee_extension --install /download/inigo-metric.tar.gz \
    && ./bin/wee_extension --install /download/neowx-material-latest.zip \
    && ./bin/wee_extension --install /download/weewx-windy.zip \
    && cp /download/inigo-settings.txt /data/public_html/. \
    && rm -rf /download

