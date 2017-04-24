FROM alpine

RUN apk --update add --no-cache curl git sed tar

WORKDIR /var/www/html

RUN curl -L https://api.github.com/repos/Automattic/vip-go-skeleton/tarball | tar xz --strip=1

RUN git clone https://github.com/Automattic/vip-go-mu-plugins.git /var/www/html/mu-plugins

RUN sed -i -e "s|git@\([^:]*\):|https://\1/|" /var/www/html/mu-plugins/.gitmodules

RUN ls .

WORKDIR /var/www/html/mu-plugins

RUN git submodule update --init --recursive

RUN find /var/www/html/mu-plugins -type d -name '.git' | xargs rm -rf



CMD /bin/true



