#!/usr/bin/with-contenv bashio

mqtt_server="tcp://127.0.0.1:1883"
if bashio::config.has_value "mqtt_server"; then
    mqtt_server=$(bashio::config "mqtt_server")
    echo ${mqtt_server}
fi

bashio::log.info "Starting postgresql..."
if [ ! -d "/data/database" ]; then
  mv /var/lib/postgresql/13/main /data/database
#  mkdir /data/database
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
sed "s|^    server=.*$|    server=\"${mqtt_server}\"|g" /etc/chirpstack-gateway-bridge/chirpstack-gateway-bridge.toml
service chirpstack-gateway-bridge start

bashio::log.info "Starting chirpstack..."
sed "s|^    server=.*$|    server=\"${mqtt_server}\"|g" /etc/chirpstack/*.toml

/usr/bin/chirpstack -c /etc/chirpstack/