# weewx-docker

Extended version of Felddy's Docker image https://github.com/felddy/weewx-docker. This repository adds some Weewx's extensions to a new Docker image based on https://hub.docker.com/r/felddy/weewx.

## Extensions

1. Skin NeoWX Material
   https://neoground.com/projects/neowx-material?lang=en

1. [Windy](https://www.windy.com/) API sender
   https://github.com/matthewwall/weewx-windy

1. [Android mobile application](https://play.google.com/store/apps/details?id=com.odiousapps.weewxweather) data-exporter
   https://github.com/evilbunny2008/weeWXWeatherApp

## Kubernetes deployment

This repository also contains a template `k8s-deployment.yml` for running in Kubernetes environment (in my case [k3s.io](https://k3s.io/) running on a Raspberry Pi with the hostPath and nodePort all-range enabled `--kube-apiserver-arg service-node-port-range=1-65535`).

Goals:

- create StatefulSet with 2 containers - Weewx and Caddy webserver/proxy
- `mountPath: /data` where weewx.conf and weewx.sdb are expected
- `mountPath: /data` with `subPath: public_html` where static website data are generated and this is served by Caddy
- Weewx's Interceptor API port is internally served on the port 8088 that is exposed on a host on same port
- Caddy webserver runs internally on the port 80 that is exposed on a host on the port 8080