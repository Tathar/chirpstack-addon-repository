ARG BUILD_FROM
FROM $BUILD_FROM


RUN \
	apt update \
	&& apt upgrade -y \
	&& apt install -y patch sudo redis-server redis-tools postgresql \
	&& apt install -y gnupg \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1CE2AFD36DBCCA00 \
	&& echo "deb https://artifacts.chirpstack.io/packages/4.x/deb stable main" | tee /etc/apt/sources.list.d/chirpstack.list \
	&& apt update \
	&& apt install -y chirpstack chirpstack-gateway-bridge \
    && sed -i "s|^data_directory =.*$|data_directory = '/data/database/'|g" /etc/postgresql/13/main/postgresql.conf \
	&& apt-get clean \
    && rm -fr \
        /tmp/* \
        /var/cache/* \
        /var/lib/apt/lists/* \
        /var/log/*.log \
        /var/log/apt

# Copy rootfs
COPY rootfs /
RUN chmod a+x /run.sh
WORKDIR /
CMD [ "/run.sh" ]