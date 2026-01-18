# ADMIN78

## Durcissement Ubuntu Server et Desktop

Ce guide fournit un socle de durcissement pour Ubuntu Server et Ubuntu Desktop. Adaptez chaque mesure à votre contexte (services, accès, conformité).

### 1) Mises à jour et gestion des correctifs
- Activer les dépôts officiels et appliquer les mises à jour de sécurité régulièrement.
- Installer les mises à jour automatiques:
  - `sudo apt install unattended-upgrades`
  - `sudo dpkg-reconfigure --priority=low unattended-upgrades`
- Vérifier l’état:
  - `sudo systemctl status unattended-upgrades`

### 2) Comptes, privilèges et authentification
- Désactiver le compte root en SSH (voir section SSH).
- Utiliser des comptes nominatifs et la montée de privilèges via `sudo`.
- Appliquer une politique de mots de passe (longueur, complexité, rotation raisonnable).
- Activer l’authentification multi-facteurs (ex: PAM + Google Authenticator) si possible.

### 3) SSH (serveur uniquement)
- Modifier la configuration dans `/etc/ssh/sshd_config`:
  - `PermitRootLogin no`
  - `PasswordAuthentication no` (préférer les clés)
  - `AllowUsers <liste_utilisateurs>`
- Redémarrer le service:
  - `sudo systemctl restart ssh`
- Générer des clés robustes (ex: ed25519) et protéger la clé privée.

### 4) Pare-feu et filtrage réseau
- Activer UFW:
  - `sudo ufw default deny incoming`
  - `sudo ufw default allow outgoing`
  - `sudo ufw allow OpenSSH`
  - `sudo ufw enable`
- Sur Desktop, n’ouvrir que les ports nécessaires aux applications.

### 5) Services et surface d’attaque
- Désinstaller/arrêter les services inutiles:
  - `sudo systemctl list-unit-files --type=service`
- Vérifier les ports ouverts:
  - `ss -tulpen`
- Limiter les services exposés à Internet.

### 6) Durcissement du noyau et sysctl
- Appliquer des paramètres sysctl (ex: `/etc/sysctl.d/99-hardening.conf`):
  - `net.ipv4.conf.all.rp_filter = 1`
  - `net.ipv4.conf.default.rp_filter = 1`
  - `net.ipv4.conf.all.accept_redirects = 0`
  - `net.ipv4.conf.default.accept_redirects = 0`
  - `net.ipv4.conf.all.send_redirects = 0`
  - `net.ipv4.conf.default.send_redirects = 0`
  - `net.ipv4.conf.all.accept_source_route = 0`
  - `net.ipv4.conf.default.accept_source_route = 0`
- Charger la configuration:
  - `sudo sysctl --system`

### 7) Sécurité applicative (Desktop)
- Installer uniquement des logiciels nécessaires.
- Désactiver l’exécution automatique (autorun) des supports amovibles.
- Utiliser un navigateur à jour avec un bloqueur de scripts et de pubs si besoin.

### 8) Journalisation et supervision
- Activer et surveiller les logs:
  - `journalctl -p warning -b`
- Installer un outil de sécurité (ex: `auditd`, `fail2ban`).
- Centraliser les logs si possible.

### 9) Chiffrement
- Chiffrer le disque (LUKS) lors de l’installation.
- Sur Desktop, chiffrer les dossiers sensibles ou utiliser le chiffrement complet.

### 10) Sauvegardes
- Mettre en place des sauvegardes régulières (règle 3-2-1).
- Tester la restauration.

### 11) Conformité et vérification
- Auditer l’hôte avec des outils comme `lynis`:
  - `sudo apt install lynis`
  - `sudo lynis audit system`

### 12) Bonnes pratiques supplémentaires
- Segmenter le réseau et limiter l’accès administratif.
- Appliquer le principe du moindre privilège.
- Documenter les changements et conserver un inventaire.

## Avertissement
Ce guide fournit une base générale. Vérifiez la compatibilité avec vos applications, et validez chaque modification en environnement de test avant la production.
