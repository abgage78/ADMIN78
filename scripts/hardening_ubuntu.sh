#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: hardening_ubuntu.sh [--apply] [--server|--desktop]

Options:
  --apply     Execute changes (default is dry-run; commands are printed only).
  --server    Apply server-oriented steps (SSH hardening, UFW OpenSSH).
  --desktop   Apply desktop-oriented steps (no SSH changes by default).
  -h, --help  Show this help message.

Examples:
  ./hardening_ubuntu.sh --server
  ./hardening_ubuntu.sh --apply --server
USAGE
}

APPLY=false
PROFILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      APPLY=true
      shift
      ;;
    --server)
      PROFILE="server"
      shift
      ;;
    --desktop)
      PROFILE="desktop"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

do_cmd() {
  local cmd="$1"
  if [[ "$APPLY" == true ]]; then
    echo "> $cmd"
    eval "$cmd"
  else
    echo "[dry-run] $cmd"
  fi
}

if [[ -z "$PROFILE" ]]; then
  echo "Error: choose --server or --desktop." >&2
  usage
  exit 1
fi

echo "Profile: $PROFILE"
if [[ "$APPLY" == false ]]; then
  echo "Mode: dry-run (use --apply to execute)"
fi

# 1) Updates and patching

do_cmd "sudo apt update"
do_cmd "sudo apt install -y unattended-upgrades"
do_cmd "sudo dpkg-reconfigure --priority=low unattended-upgrades"

dpkr_status="sudo systemctl status unattended-upgrades"
if [[ "$APPLY" == true ]]; then
  $dpkr_status || true
else
  echo "[dry-run] $dpkr_status"
fi

# 2) Firewall (UFW)

do_cmd "sudo ufw default deny incoming"
do_cmd "sudo ufw default allow outgoing"
if [[ "$PROFILE" == "server" ]]; then
  do_cmd "sudo ufw allow OpenSSH"
fi
do_cmd "sudo ufw --force enable"

# 3) Services and ports

do_cmd "sudo systemctl list-unit-files --type=service"

echo "[info] Review open ports with: ss -tulpen"

# 4) Sysctl hardening

SYSCTL_FILE="/etc/sysctl.d/99-hardening.conf"
SYSCTL_CONTENT=$(cat <<'SYSCTL'
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
SYSCTL
)

if [[ "$APPLY" == true ]]; then
  echo "Writing $SYSCTL_FILE"
  echo "$SYSCTL_CONTENT" | sudo tee "$SYSCTL_FILE" >/dev/null
  do_cmd "sudo sysctl --system"
else
  echo "[dry-run] Write sysctl config to $SYSCTL_FILE:"
  echo "$SYSCTL_CONTENT" | sed 's/^/[dry-run] /'
  echo "[dry-run] sudo sysctl --system"
fi

# 5) SSH hardening (server profile only)
if [[ "$PROFILE" == "server" ]]; then
  echo "[info] Review /etc/ssh/sshd_config for:"
  echo "  PermitRootLogin no"
  echo "  PasswordAuthentication no"
  echo "  AllowUsers <liste_utilisateurs>"
  echo "[info] Restart SSH with: sudo systemctl restart ssh"
fi

# 6) Auditing tools

do_cmd "sudo apt install -y auditd fail2ban lynis"

if [[ "$APPLY" == true ]]; then
  echo "[info] Run audit with: sudo lynis audit system"
else
  echo "[dry-run] sudo lynis audit system"
fi

echo "Done. Review outputs and validate changes before production."
