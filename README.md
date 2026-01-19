# ADMIN78

## Application pro - rapport Excel

Cette application genere un rapport Excel (XLSX) de durcissement avec des indicateurs, un tableau de suivi et un graphique.

### Prerequis
- Python 3.10+
- Dependances:
  - `pip install -r requirements.txt`

### Utilisation
- Generer un rapport avec donnees d'exemple:
  - `python app/main.py --with-sample`
- Generer un rapport dans un dossier specifique:
  - `python app/main.py --with-sample --output ./reports/rapport_durcissement.xlsx`

Le fichier genere contient:
- Une synthese (date, nombre de controles, score moyen).
- Un tableau par service (score, responsable, statut).
- Un graphique en barres des scores.

### Extensions VS Code recommandees
- Python (ms-python.python) - support Python, debug, linting.
- Pylance (ms-python.vscode-pylance) - analyse statique et autocompletion.
- EditorConfig (editorconfig.editorconfig) - conventions de formatage partagees.
- Markdown All in One (yzhang.markdown-all-in-one) - aide a la redaction Markdown.
- ShellCheck (timonwong.shellcheck) - validation des scripts bash.

## Durcissement Ubuntu Server et Desktop

Ce guide fournit un socle de durcissement pour Ubuntu Server et Ubuntu Desktop. Adaptez chaque mesure a votre contexte (services, acces, conformite).

### Script d’aide

Un script de base est disponible pour automatiser une partie des actions (mode dry-run par defaut):

- `./scripts/hardening_ubuntu.sh --server`
- `./scripts/hardening_ubuntu.sh --apply --server`
- `./scripts/hardening_ubuntu.sh --desktop`

### 1) Mises a jour et gestion des correctifs
- Activer les depots officiels et appliquer les mises a jour de securite regulierement.
- Installer les mises a jour automatiques:
  - `sudo apt install unattended-upgrades`
  - `sudo dpkg-reconfigure --priority=low unattended-upgrades`
- Verifier l'etat:
  - `sudo systemctl status unattended-upgrades`

### 2) Comptes, privileges et authentification
- Desactiver le compte root en SSH (voir section SSH).
- Utiliser des comptes nominatifs et la montee de privileges via `sudo`.
- Appliquer une politique de mots de passe (longueur, complexite, rotation raisonnable).
- Activer l’authentification multi-facteurs (ex: PAM + Google Authenticator) si possible.

### 3) SSH (serveur uniquement)
- Modifier la configuration dans `/etc/ssh/sshd_config`:
  - `PermitRootLogin no`
  - `PasswordAuthentication no` (preferer les cles)
  - `AllowUsers <liste_utilisateurs>`
- Redemarrer le service:
  - `sudo systemctl restart ssh`
- Generer des cles robustes (ex: ed25519) et proteger la cle privee.

### 4) Pare-feu et filtrage reseau
- Activer UFW:
  - `sudo ufw default deny incoming`
  - `sudo ufw default allow outgoing`
  - `sudo ufw allow OpenSSH`
  - `sudo ufw enable`
- Sur Desktop, n’ouvrir que les ports necessaires aux applications.

### 5) Services et surface d’attaque
- Desinstaller/arreter les services inutiles:
  - `sudo systemctl list-unit-files --type=service`
- Verifier les ports ouverts:
  - `ss -tulpen`
- Limiter les services exposes a Internet.

### 6) Durcissement du noyau et sysctl
- Appliquer des parametres sysctl (ex: `/etc/sysctl.d/99-hardening.conf`):
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

### 7) Securite applicative (Desktop)
- Installer uniquement des logiciels necessaires.
- Desactiver l’execution automatique (autorun) des supports amovibles.
- Utiliser un navigateur a jour avec un bloqueur de scripts et de pubs si besoin.

### 8) Journalisation et supervision
- Activer et surveiller les logs:
  - `journalctl -p warning -b`
- Installer un outil de securite (ex: `auditd`, `fail2ban`).
- Centraliser les logs si possible.

### 9) Chiffrement
- Chiffrer le disque (LUKS) lors de l’installation.
- Sur Desktop, chiffrer les dossiers sensibles ou utiliser le chiffrement complet.

### 10) Sauvegardes
- Mettre en place des sauvegardes regulieres (regle 3-2-1).
- Tester la restauration.

### 11) Conformite et verification
- Auditer l’hote avec des outils comme `lynis`:
  - `sudo apt install lynis`
  - `sudo lynis audit system`

### 12) Bonnes pratiques supplementaires
- Segmenter le reseau et limiter l’acces administratif.
- Appliquer le principe du moindre privilege.
- Documenter les changements et conserver un inventaire.

## Avertissement
Ce guide fournit une base generale. Verifiez la compatibilite avec vos applications, et validez chaque modification en environnement de test avant la production.
