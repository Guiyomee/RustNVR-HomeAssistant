# RustNVR · apps Home Assistant

Les apps Home Assistant de [RustNVR](https://github.com/Guiyomee/RustNVR),
l'enregistreur vidéo léger pour caméras RTSP.

| App | Pour qui |
| --- | --- |
| **[RustNVR](rustnvr/)** (BETA) | RustNVR tourne **dans** Home Assistant OS (mini-PC, NUC, VM, Raspberry Pi 4 ou 5). Interface dans la barre latérale, enregistrements dans Médias, MQTT branché sur Mosquitto. |
| **[RustNVR Proxy](rustnvr-proxy/)** | RustNVR tourne **ailleurs** (Docker, Proxmox, Debian) : l'app affiche son interface dans la barre latérale. |

## Installer

Paramètres → **Apps** → **Magasin d'apps** → ⋮ → **Dépôts**, ajoutez :

```
https://github.com/Guiyomee/RustNVR-HomeAssistant
```

puis installez l'app voulue. Guide complet :
[wiki de RustNVR](https://github.com/Guiyomee/RustNVR/wiki/FR-Home-Assistant).

---

*English:* Home Assistant apps for [RustNVR](https://github.com/Guiyomee/RustNVR).
**RustNVR** (beta) runs RustNVR inside Home Assistant OS; **RustNVR Proxy** shows
the interface of a RustNVR running elsewhere. Add this repository in
Settings → Apps → App store → ⋮ → Repositories. Guide:
[wiki](https://github.com/Guiyomee/RustNVR/wiki/EN-Home-Assistant).

Aide et retours : [Discord](https://discord.gg/6aDKTM6pXY) (salon « aide ») ou
[issues](https://github.com/Guiyomee/RustNVR-HomeAssistant/issues) ·
*help: Discord or issues, English welcome.*

Licence : [PolyForm Noncommercial 1.0.0](LICENSE), comme RustNVR.
