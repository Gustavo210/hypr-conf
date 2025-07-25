#!/bin/bash
# Arquivo: ~/.config/waybar/scripts/npm-registry-toggle.sh
# Script para alternar o registry do npm/pnpm entre local e público

PUBLIC_NPM_REGISTRY="https://registry.npmjs.org/"
LOCAL_NPM_REGISTRY="http://$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n1):4873/" # Altere para o seu registry local, se diferente

# Função para obter o registry atual de um gerenciador de pacotes
get_current_registry() {
  local pm_command="$1"
  local registry=""
  if command -v "$pm_command" &>/dev/null; then
    registry=$("$pm_command" config get registry 2>/dev/null)
  fi
  echo "$registry"
}

# Função para definir o registry para um gerenciador de pacotes
set_registry() {
  local pm_command="$1"
  local new_registry="$2"
  if command -v "$pm_command" &>/dev/null; then
    "$pm_command" config set registry "$new_registry" &>/dev/null
  fi
}

# Lógica para alternar o registry
current_pnpm_registry=$(get_current_registry "pnpm")
current_npm_registry=$(get_current_registry "npm")

# Priorizar pnpm
if [ -n "$current_pnpm_registry" ] && [ "$current_pnpm_registry" != "undefined" ]; then
  if [ "$current_pnpm_registry" = "$PUBLIC_NPM_REGISTRY" ]; then
    set_registry "pnpm" "$LOCAL_NPM_REGISTRY"
  else
    set_registry "pnpm" "$PUBLIC_NPM_REGISTRY"
  fi
elif [ -n "$current_npm_registry" ] && [ "$current_npm_registry" != "undefined" ]; then
  if [ "$current_npm_registry" = "$PUBLIC_NPM_REGISTRY" ]; then
    set_registry "npm" "$LOCAL_NPM_REGISTRY"
  else
    set_registry "npm" "$PUBLIC_NPM_REGISTRY"
  fi
else
  # Se nenhum estiver configurado, definir para o público por padrão
  set_registry "npm" "$PUBLIC_NPM_REGISTRY"
  set_registry "pnpm" "$PUBLIC_NPM_REGISTRY"
fi