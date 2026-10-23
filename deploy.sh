#!/usr/bin/env bash
# Deploy the built site (branch hostinger-build) to Hostinger over SSH.
# Usage:  ./deploy.sh            # deploy
#         DRY_RUN=1 ./deploy.sh  # build the upload folder only, no SSH
# You are asked for the SSH password once per run (never stored here).
# To skip the password entirely: ssh-copy-id -p 65002 u118892403@195.35.44.226
set -euo pipefail

HOST=195.35.44.226
PORT=65002
SSH_USER=u118892403
REMOTE_DIR=domains/aadityaproperties.in/public_html
SITE=https://aadityaproperties.in

cd "$(dirname "$0")"

echo "1/4  Fetching latest build from GitHub (branch hostinger-build)..."
git fetch -q origin hostinger-build
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"; ssh -O exit -o ControlPath="$OUT.sock" "$SSH_USER@$HOST" 2>/dev/null || true' EXIT
git archive origin/hostinger-build | tar -x -C "$OUT"
rm -f "$OUT/.nojekyll"
echo "     $(find "$OUT" -type f | wc -l) files ready in $OUT"

if [ "${DRY_RUN:-0}" = 1 ]; then
  find "$OUT" -type f | sed "s|$OUT/||" | sort
  echo "DRY_RUN: stopping before upload."; exit 0
fi

# One SSH connection reused for every step, so the password is typed once.
SSH=(ssh -p "$PORT" -o ControlMaster=auto -o ControlPath="$OUT.sock" -o ControlPersist=120)

echo "2/4  Connecting to $HOST (enter your SSH password)..."
"${SSH[@]}" "$SSH_USER@$HOST" true

echo "3/4  Backing up WordPress (first deploy only) and uploading..."
"${SSH[@]}" "$SSH_USER@$HOST" bash -s <<EOF
set -e
cd ~/$REMOTE_DIR
if [ -f wp-config.php ]; then
  BK=~/old-wordpress-\$(date +%Y%m%d-%H%M%S)
  mkdir -p "\$BK"
  shopt -s dotglob nullglob
  mv ./* "\$BK"/
  echo "     WordPress moved to \$BK (outside public_html, not public)"
fi
EOF
# --chmod: mktemp dirs are 700; without this public_html becomes unreadable (403/404).
rsync -rlz --delete --chmod=D755,F644 -e "${SSH[*]}" "$OUT"/ "$SSH_USER@$HOST:$REMOTE_DIR/"
"${SSH[@]}" "$SSH_USER@$HOST" "chmod 755 ~/$REMOTE_DIR"

echo "4/4  Checking the live site..."
fail=0
for path in / /guides/ /about/ /contact/ /privacy-policy/ /terms/ /disclaimer/ \
            /editorial-policy/ /corrections/ /advertising-disclosure/ \
            /documents-required-before-buying-a-property/ /how-to-buy-your-first-home-in-india/ \
            /residential-vs-commercial-property-investment/ /top-real-estate-investment-tips-for-beginners/ \
            /sitemap.xml /robots.txt /ads.txt; do
  code=$(curl -s -o /dev/null -w '%{http_code}' -H 'Cache-Control: no-cache' "$SITE$path?v=$RANDOM")
  printf '     %-55s %s\n' "$path" "$code"
  [ "$code" = 200 ] || fail=1
done
if curl -s "$SITE/?v=$RANDOM" | grep -qiE 'lorem|realestate@example|salecraft'; then
  echo "     Old WordPress content still served: purge the CDN in hPanel (Websites > Performance > CDN > Purge cache)"; fail=1
fi
[ $fail = 0 ] && echo "Done: site is live." || { echo "Deployed, but some checks failed (see above). If pages show old content, purge the Hostinger CDN and re-run the check."; exit 1; }
