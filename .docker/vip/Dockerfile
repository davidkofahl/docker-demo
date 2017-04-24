FROM alpine

RUN apk add --no-cache git sed

RUN git clone https://github.com/Automattic/vip-go-mu-plugins.git /var/www/html

RUN sed -i -e "s|git@\([^:]*\):|https://\1/|" /var/www/html/.gitmodules

RUN cd /var/www/html \
  && git submodule update --init --recursive

RUN find /var/www/html -type d -name '.git' | xargs rm -rf

CMD /bin/true


