#!/bin/sh
# Start of the Home Assistant app: options of /data/options.json, the first
# configuration, the broker of Home Assistant, then RustNVR as uid 1000.
set -eu

say() { echo "[rustnvr-haos] $*"; }

password=$(jq -r '.password // ""' /data/options.json)
if [ "${#password}" -lt 8 ]; then
    say "Mot de passe manquant ou trop court : onglet Configuration de l'app, au moins 8 caractères (compte « admin » de RustNVR)." >&2
    exit 1
fi

# Folders of RustNVR, its own (not recursive: what it writes is already its own).
mkdir -p /media/rustnvr /data/rustnvr
chown rustnvr:rustnvr /config /data /data/rustnvr /media/rustnvr

# First start: the configuration for Home Assistant, kept afterwards (cameras,
# storage and the rest are set in the interface, in /config/*.ui.toml).
if [ ! -f /config/config.toml ]; then
    cat > /config/config.toml <<'TOML'
# RustNVR in Home Assistant (made at the first start of the app, kept
# afterwards). All options: config.example.toml in the repository. Cameras,
# storage destinations, MQTT and AI are set in the interface.

[storage]
# The recordings in Home Assistant's media folder; another disk or a NAS
# (Settings → System → Storage → Network storage, « Media ») can be added
# in RustNVR's Paramètres → Stockage.
recordings_dir = "/media/rustnvr"
# Database, thumbnails, H.264 copies, exports (in the app's backups).
data_dir = "/data/rustnvr"

[web]
# HTTP: Home Assistant's ingress talks HTTP to the app. The port 8080 opened
# in the app's Network tab is also HTTP.
listen = "0.0.0.0:8080"
static_dir = "/usr/share/rustnvr/web"
username = "admin"
password_env = "RUSTNVR_WEB_PASSWORD"
# Home Assistant's supervisor, which forwards the ingress: failed logins
# count for the real browser, not for everyone.
trusted_proxies = ["172.30.32.2"]
TOML
    chown rustnvr:rustnvr /config/config.toml
    chmod 0600 /config/config.toml
    say "/config/config.toml créé (enregistrements dans /media/rustnvr)"
fi

# MQTT, from the Configuration tab of the app, written to mqtt.ui.toml at
# each start (it replaces RustNVR's Paramètres → MQTT). Without a broker
# address: the Mosquitto of Home Assistant (address and account from the
# supervisor). Its own client id and topic prefix (`rustnvr-ha` by default):
# with the id of another RustNVR on the same broker, Mosquitto throws one of
# them out at each connection of the other.
opt() { jq -r ".$1 // empty" /data/options.json; }
# A TOML string (JSON's quoting is valid TOML).
toml() { printf '%s' "$1" | jq -Rs .; }
mqtt_on=$(jq -r 'if .mqtt_enabled == false then "false" else "true" end' /data/options.json)
host=$(opt mqtt_host)
port=$(opt mqtt_port)
user=$(opt mqtt_username)
pass=$(opt mqtt_password)
from="Configuration de l'app"
if [ "${mqtt_on}" = true ] && [ -z "${host}" ]; then
    broker=""
    if [ -n "${SUPERVISOR_TOKEN:-}" ]; then
        broker=$(curl -fsS --max-time 5 -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/services/mqtt 2> /dev/null || true)
    fi
    field() { printf '%s' "${broker}" | jq -r ".data.$1 // empty" 2> /dev/null; }
    host=$(field host)
    port=$(field port)
    user=$(field username)
    pass=$(field password)
    from="Mosquitto de Home Assistant"
    if [ -z "${host}" ]; then
        mqtt_on=false
        say "MQTT : pas de broker indiqué ni de Mosquitto dans Home Assistant, MQTT coupé"
    fi
fi
case "${port}" in '' | *[!0-9]*) port=1883 ;; esac
client=$(opt mqtt_client_id)
prefix=$(opt mqtt_topic_prefix)
{
    echo "# MQTT of the Home Assistant app, written at each start from its"
    echo "# Configuration tab: change it there, not in RustNVR."
    echo "[mqtt]"
    echo "enabled = ${mqtt_on}"
    if [ "${mqtt_on}" = true ]; then
        echo "host = $(toml "${host}")"
        echo "port = ${port}"
        [ -n "${user}" ] && echo "username = $(toml "${user}")"
        [ -n "${pass}" ] && echo 'password_env = "RUSTNVR_MQTT_PASSWORD"'
        echo "client_id = $(toml "${client:-rustnvr-ha}")"
        echo "topic_prefix = $(toml "${prefix:-rustnvr-ha}")"
    fi
} > /config/mqtt.ui.toml
chown rustnvr:rustnvr /config/mqtt.ui.toml
chmod 0600 /config/mqtt.ui.toml
if [ "${mqtt_on}" = true ]; then
    say "MQTT : ${from} (${host}:${port}), client « ${client:-rustnvr-ha} », préfixe « ${prefix:-rustnvr-ha} »"
    if [ -n "${pass}" ]; then
        RUSTNVR_MQTT_PASSWORD=${pass}
        export RUSTNVR_MQTT_PASSWORD
    fi
elif [ "$(jq -r '.mqtt_enabled' /data/options.json)" = false ]; then
    say "MQTT coupé (Configuration de l'app)"
fi

RUSTNVR_WEB_PASSWORD=${password}
export RUSTNVR_WEB_PASSWORD
exec setpriv --reuid=rustnvr --regid=rustnvr --init-groups \
    rustnvr-entrypoint run -c /config/config.toml
