#!/usr/bin/env bash
set -euo pipefail

# Determine repository root
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "[ERROR] Not inside a Git repository." >&2
  exit 1
fi

cd "${REPO_ROOT}"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
DEFAULT_REMOTE="origin"

if ! git remote get-url "${DEFAULT_REMOTE}" >/dev/null 2>&1; then
  echo "[ERROR] Remote '${DEFAULT_REMOTE}' is not configured."
  echo "Please run: git remote add ${DEFAULT_REMOTE} <remote-url>" >&2
  exit 2
fi

echo "[INFO] Fetching latest changes from '${DEFAULT_REMOTE}'."
git fetch "${DEFAULT_REMOTE}"

echo "[INFO] Rebasing '${CURRENT_BRANCH}' onto '${DEFAULT_REMOTE}/${CURRENT_BRANCH}'."
if git show-ref --verify --quiet "refs/remotes/${DEFAULT_REMOTE}/${CURRENT_BRANCH}"; then
  git rebase "${DEFAULT_REMOTE}/${CURRENT_BRANCH}"
else
  echo "[WARN] Remote branch '${DEFAULT_REMOTE}/${CURRENT_BRANCH}' does not exist." >&2
  echo "[INFO] Consider checking out an existing branch or pushing the current branch." >&2
fi
