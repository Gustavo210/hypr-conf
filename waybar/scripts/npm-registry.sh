#!/bin/bash
# Arquivo: ~/.config/waybar/scripts/npm-registry.sh
# Script melhorado para exibir o registry atual do npm/pnpm

# Função para extrair e formatar o registry completo
extract_registry_name() {
  local url="$1"
  if [ -z "$url" ] || [ "$url" = "undefined" ]; then
    echo "none"
    return
  fi

  # Remove protocolo e barra final
  local clean_url=$(echo "$url" | sed 's|https\?://||' | sed 's|/$||')
  echo "$clean_url"
}

# Verificar pnpm primeiro (prioridade)
if command -v pnpm &>/dev/null; then
  pnpm_registry=$(pnpm config get registry 2>/dev/null)
  if [ -n "$pnpm_registry" ] && [ "$pnpm_registry" != "undefined" ]; then
    result=$(extract_registry_name "$pnpm_registry")
    echo "$result"
    exit 0
  fi
fi

# Se pnpm não estiver disponível ou não tiver registry, usar npm
if command -v npm &>/dev/null; then
  npm_registry=$(npm config get registry 2>/dev/null)
  if [ -n "$npm_registry" ] && [ "$npm_registry" != "undefined" ]; then
    result=$(extract_registry_name "$npm_registry")
    echo "$result"
    exit 0
  fi
fi

# Se nenhum estiver disponível
echo "none"
