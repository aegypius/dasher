FROM node:carbon as build
RUN apt-get update && apt-get -y install libpcap-dev
WORKDIR /app/
COPY package.json package-lock.json /app/
RUN npm install
COPY . /app/
RUN echo '{\
  "buttons": [\
    {\
      "name": "{{ default .Env.BUTTON_NAME "Dash Button" }}",\
      "address": "{{ .Env.BUTTON_HW_ADDRESS }}",\
      "timeout": {{ default .Env.BUTTON_TIMEOUT "5000" }},\
      "protocol": "{{ default .Env.BUTTON_PROTOCOL "arp" }}",\
      "url": "{{ .Env.BUTTON_URL }}",\
      "method": "{{ default .Env.BUTTON_METHOD "GET" }}"\
    }\
  ]\
}' > /app/config/config.json.tmpl
ENV DOCKERIZE_VERSION v0.6.1
ADD https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz /tmp/dockerize.tar.gz
RUN tar -xzf /tmp/dockerize.tar.gz dockerize && chmod +x dockerize

FROM node:carbon-slim
WORKDIR /app/ 
COPY --from=build /usr/lib/x86_64-linux-gnu/libpcap.so* /usr/lib/x86_64-linux-gnu/
COPY --from=build /app/ /app/
ENTRYPOINT ["/app/dockerize", "-template", "/app/config/config.json.tmpl:/app/config/config.json"]
CMD npm start
