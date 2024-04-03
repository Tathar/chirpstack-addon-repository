#!/usr/bin/with-contenv bashio

mqtt_server="tcp://127.0.0.1:1883"
if bashio::config.has_value "mqtt_server"; then
    mqtt_server=$(bashio::config "mqtt_server")
fi

region="eu868"
if bashio::config.has_value "region_gateway"; then
    region=$(bashio::config "region_gateway")
    echo ${region}
fi

secret="eTtWjTbT03lVof0JhdMANp3JKUXoSxTayHr6mDk9pzE="
if bashio::config.has_value "secret"; then
    secret=$(bashio::config "secret")
    echo ${secret}
fi

bashio::log.info "Starting postgresql..."
if [ ! -d "/data/database" ]; then
  mv /var/lib/postgresql/13/main /data/database
  chown -R postgres:postgres /data/database
  service postgresql start
  sudo -u postgres psql -c "create role chirpstack with login password 'chirpstack';"
  sudo -u postgres psql -c "create database chirpstack with owner chirpstack;"
  sudo -u postgres psql -d chirpstack -c "create extension pg_trgm;"
else
  service postgresql start
fi

bashio::log.info "Starting redis-server..."
service redis-server start

bashio::log.info "Starting chirpstack-gateway-bridge..."
sed -i "s|__server__|${mqtt_server}|g" /diff/chirpstack-gateway-bridge.diff
sed -i "s|__region__|${region}|g" /diff/chirpstack-gateway-bridge.diff
patch /etc/chirpstack-gateway-bridge/chirpstack-gateway-bridge.toml /diff/chirpstack-gateway-bridge.diff
service chirpstack-gateway-bridge start

bashio::log.info "Starting chirpstack..."
sed -i "s|__server__|${mqtt_server}|g" /diff/chirpstack.diff
sed -i "s|__secret__|${secret}|g" /diff/chirpstack.diff
sed -i "s|__region__|${region}|g" /diff/chirpstack.diff
patch -d /etc/chirpstack/ -i /diff/chirpstack.diff

/usr/bin/chirpstack -c /etc/chirpstack/
