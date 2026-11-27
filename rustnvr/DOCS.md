# RustNVR

**BETA** : première version publique de cette app ; dites-nous ce qui ne va
pas ([Discord](https://discord.gg/6aDKTM6pXY), issues du dépôt ou forum HACF).

RustNVR tourne dans Home Assistant et son interface s'ouvre dans la barre
latérale (panneau « RustNVR »). Les vidéos sont enregistrées telles que la
caméra les envoie, sans réencodage : peu de processeur, même sur un mini-PC.

Pour un mini-PC, un NUC ou une VM (x86-64), et un Raspberry Pi 4 ou 5 (ARM
64 bits). Sur un Raspberry Pi, enregistrez sur un disque USB ou un NAS
plutôt que sur la carte SD, et prenez un petit modèle de reconnaissance
d'objets (YOLOX-nano ou YOLOX-s).

Si RustNVR tourne déjà sur une autre machine (Docker, Proxmox), n'installez
pas cette app : l'app **RustNVR Proxy** affiche son interface dans Home
Assistant.

## Démarrer

1. Onglet **Configuration** : choisissez le mot de passe du compte
   **admin** de RustNVR (8 caractères au moins), puis enregistrez.
2. Démarrez l'app et cochez **Afficher dans la barre latérale**.
3. Ouvrez le panneau **RustNVR**, connectez-vous avec `admin` et ce mot de
   passe, puis ajoutez vos caméras (Caméras → Ajouter, ou « Rechercher sur
   le réseau »).

Chaque personne qui ouvre le panneau se connecte à RustNVR avec son propre
compte : créez des comptes « lecteur » (Paramètres → Comptes) pour ceux qui
doivent seulement regarder.

## Où vont les fichiers

| Quoi | Où |
| --- | --- |
| Enregistrements | `/media/rustnvr` (dossier « Médias » de Home Assistant) |
| Base de données, vignettes, extraits | dans l'app (`/data/rustnvr`, compris dans les sauvegardes de l'app) |
| Configuration (`config.toml`, réglages faits dans l'interface) | le dossier de l'app, `/addon_configs/<…>_rustnvr` |

Les enregistrements ne sont **pas** dans les sauvegardes de Home Assistant
(ils sont dans `/media`). Pour enregistrer sur un NAS : ajoutez-le dans
Home Assistant (Paramètres → Système → Stockage → Stockage réseau, usage
« Médias »), puis choisissez son dossier `/media/<nom>` comme destination
dans RustNVR (Paramètres → Stockage).

## MQTT

Réglé dans l'onglet **Configuration** de l'app (pas dans Paramètres → MQTT
de RustNVR : l'app le réécrit à chaque démarrage).

| Option | Valeur |
| --- | --- |
| `mqtt_enabled` | MQTT activé (par défaut) ou coupé. |
| `mqtt_host` | Vide : le **Mosquitto de Home Assistant**, avec son compte donné automatiquement. Sinon, l'adresse d'un autre broker. |
| `mqtt_port`, `mqtt_username`, `mqtt_password` | Pour un autre broker seulement. |
| `mqtt_client_id` | `rustnvr-ha` par défaut. Unique sur le broker : un autre RustNVR utilise en général `rustnvr`, et deux clients au même identifiant s'éjectent sans arrêt. |
| `mqtt_topic_prefix` | `rustnvr-ha` par défaut : les sujets `rustnvr-ha/<caméra>/…`, à part de ceux d'un autre RustNVR. |

Capteurs, détections et boutons des caméras arrivent dans Home Assistant par
la découverte MQTT.

## Réseau

- L'interface passe par Home Assistant (ingress) : aucun port à ouvrir.
- Onglet **Réseau** de l'app : le port **8080** ouvre aussi l'interface
  directement (`http://<home-assistant>:8080`, en HTTP, non chiffré), et
  le port **8554** la republication RTSP des caméras si elle est activée
  dans RustNVR (Paramètres → Réseau).
- La découverte ONVIF (multicast) ne passe pas depuis l'app : si une caméra
  n'apparaît pas dans « Rechercher sur le réseau », donnez son adresse à la
  main.

## Mises à jour

La version de l'app suit celle de RustNVR. La mise à jour garde la
configuration, les comptes et les enregistrements.
