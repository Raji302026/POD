#!/usr/bin/env bash
# Installs pinned lab tools (kind, kubectl, helm) and verifies checksums.
# Safe to re-run: a tool that already has the pinned version is skipped.
# Override the install folder with: BIN_DIR=/some/folder ./scripts/install-lab-tools.sh
set -euo pipefail

KIND_VERSION="v0.33.0"
KUBECTL_VERSION="v1.37.2"
HELM_VERSION="v4.3.1"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$BIN_DIR" 2>/dev/null || true
SUDO=""
if [ ! -w "$BIN_DIR" ]; then SUDO="sudo"; fi

download() { curl -fsSL -o "$2" "$1"; }

install_kind() {
  if [ -x "$BIN_DIR/kind" ] && "$BIN_DIR/kind" version | grep -q "$KIND_VERSION"; then
    echo "kind $KIND_VERSION already installed"; return
  fi
  local base="https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}"
  download "$base/kind-linux-amd64" "$TMP_DIR/kind-linux-amd64"
  download "$base/kind-linux-amd64.sha256sum" "$TMP_DIR/kind-linux-amd64.sha256sum"
  (cd "$TMP_DIR" && sha256sum -c kind-linux-amd64.sha256sum)
  $SUDO install -m 0755 "$TMP_DIR/kind-linux-amd64" "$BIN_DIR/kind"
  echo "kind $KIND_VERSION installed"
}

install_kubectl() {
  if [ -x "$BIN_DIR/kubectl" ] && "$BIN_DIR/kubectl" version --client 2>/dev/null | grep -q "$KUBECTL_VERSION"; then
    echo "kubectl $KUBECTL_VERSION already installed"; return
  fi
  local base="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64"
  download "$base/kubectl" "$TMP_DIR/kubectl"
  download "$base/kubectl.sha256" "$TMP_DIR/kubectl.sha256"
  echo "$(cat "$TMP_DIR/kubectl.sha256")  kubectl" > "$TMP_DIR/kubectl.check"
  (cd "$TMP_DIR" && sha256sum -c kubectl.check)
  $SUDO install -m 0755 "$TMP_DIR/kubectl" "$BIN_DIR/kubectl"
  echo "kubectl $KUBECTL_VERSION installed"
}

install_helm() {
  if [ -x "$BIN_DIR/helm" ] && "$BIN_DIR/helm" version --short | grep -q "$HELM_VERSION"; then
    echo "helm $HELM_VERSION already installed"; return
  fi
  local file="helm-${HELM_VERSION}-linux-amd64.tar.gz"
  local base="https://get.helm.sh"
  download "$base/$file" "$TMP_DIR/$file"
  download "$base/$file.sha256sum" "$TMP_DIR/$file.sha256sum"
  (cd "$TMP_DIR" && sha256sum -c "$file.sha256sum")
  tar -xzf "$TMP_DIR/$file" -C "$TMP_DIR"
  $SUDO install -m 0755 "$TMP_DIR/linux-amd64/helm" "$BIN_DIR/helm"
  echo "helm $HELM_VERSION installed"
}

install_kind
install_kubectl
install_helm
echo "Done. Tools are in $BIN_DIR"
