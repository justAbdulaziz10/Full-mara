#!/usr/bin/env bash
set -euo pipefail

# Simple pre-commit secret scan using ripgrep (rg)
# Requires: rg (brew install ripgrep)

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

PATTERN='(sk|rk|pk|ghp|gho|hf|ya29|AIza)[A-Za-z0-9_\-]{10,}|eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}|serviceAccount.*\.json|credentials\.json|key\.pem|cert\.pem|openai|huggingface|supabase|revenuecat|stripe|paypal|twilio|smtp|apiKey|projectId|authDomain|storageBucket|messagingSenderId|appId'

# Optional allowlist file patterns (one regex per line) to ignore false positives
ALLOWLIST_FILE="scripts/secret_allowlist.txt"
if [ -f "$ALLOWLIST_FILE" ]; then
  # Build combined negative lookahead patterns (basic). We filter matches post-scan instead for simplicity.
  :
fi

# Scan staged files only
FILES=$(git diff --cached --name-only --diff-filter=ACMR)
if [ -z "$FILES" ]; then
  exit 0
fi

echo "Secret scan: checking staged files..."
MATCHES=$(echo "$FILES" | rg -nEI "$PATTERN" || true)

# Filter allowlist
if [ -f "$ALLOWLIST_FILE" ] && [ -n "$MATCHES" ]; then
  while IFS= read -r rule; do
    [ -z "$rule" ] && continue
    MATCHES=$(echo "$MATCHES" | rg -vE "$rule" || true)
  done < "$ALLOWLIST_FILE"
fi

if [ -n "$MATCHES" ]; then
  echo "\n[BLOCKED] Potential secrets detected in staged changes:"
  echo "$MATCHES" | while IFS= read -r line; do
    file_line=$(echo "$line" | cut -d: -f1,2)
    snippet=$(echo "$line" | cut -d: -f3-)
    # Mask any token-like value leaving last 4 chars
    masked=$(echo "$snippet" | perl -pe 's/([A-Za-z0-9_\-]{12,})/substr($1,0,4)."***".substr($1,-4)/ge')
    echo "  - $file_line: $masked"
  done
  echo "\nPlease remove/replace with environment variables before committing."
  echo "If false positive, add an allowlist pattern inside scripts/secret_scan.sh or commit with --no-verify (not recommended)."
  exit 1
fi

echo "Secret scan passed."
