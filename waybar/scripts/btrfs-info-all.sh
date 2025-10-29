#!/bin/bash
set -euo pipefail

# ===== CAMINHOS ABSOLUTOS =====
MOUNT_BIN="/usr/bin/mount"
DF_BIN="/usr/bin/df"
BTRFS_BIN="/usr/bin/btrfs"
AWK_BIN="/usr/bin/awk"
GREP_BIN="/usr/bin/grep"
SORT_BIN="/usr/bin/sort"
HEAD_BIN="/usr/bin/head"
TAIL_BIN="/usr/bin/tail"
BC_BIN="/usr/bin/bc"
SED_BIN="/usr/bin/sed"
YAD_BIN="/usr/bin/yad"
ECHO_BIN="/usr/bin/echo"
CAT_BIN="/usr/bin/cat"
TR_BIN="/usr/bin/tr"
PRINTF_BIN="/usr/bin/printf"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

STATE_FILE="/tmp/waybar_btrfs_all_state"
MODE="${1:---display}"

# ===== COLETA DADOS DE TODOS OS POOLS =====
collect_all_pools() {
    local DEVICES=$("$MOUNT_BIN" -t btrfs 2>/dev/null | \
        "$AWK_BIN" '{print $1}' | \
        "$GREP_BIN" -E '^/dev' | \
        "$SORT_BIN" -u)
    
    if [ -z "$DEVICES" ]; then
        "$ECHO_BIN" "{\"text\": \"BTRFS: Nenhum pool\", \"class\": \"btrfs-error\"}"
        exit 0
    fi
    
    local POOL_COUNT=0
    local TOTAL_USED=0
    local TOTAL_SIZE=0
    local MAX_PERCENT=0
    local POOLS_INFO=""
    
    while IFS= read -r DEVICE; do
        # Encontra ponto de montagem
        local MOUNT_POINT=$("$MOUNT_BIN" 2>/dev/null | \
            "$GREP_BIN" "^$DEVICE " | \
            "$AWK_BIN" '{print $3}' | \
            "$HEAD_BIN" -n 1)
        
        if [ -z "$MOUNT_POINT" ]; then
            continue
        fi
        
        # Obtém dados do df
        local DF_OUTPUT=$("$DF_BIN" -k --output=size,used,pcent "$MOUNT_POINT" 2>/dev/null | \
            "$TAIL_BIN" -n 1)
        
        if [ -z "$DF_OUTPUT" ]; then
            continue
        fi
        
        local TOTAL_KB=$("$ECHO_BIN" "$DF_OUTPUT" | "$AWK_BIN" '{print $1}' | "$TR_BIN" -cd '[:digit:]')
        local USED_KB=$("$ECHO_BIN" "$DF_OUTPUT" | "$AWK_BIN" '{print $2}' | "$TR_BIN" -cd '[:digit:]')
        local PERCENT=$("$ECHO_BIN" "$DF_OUTPUT" | "$AWK_BIN" '{print $3}' | "$TR_BIN" -d '%' | "$TR_BIN" -cd '[:digit:]')
        
        TOTAL_KB=${TOTAL_KB:-0}
        USED_KB=${USED_KB:-0}
        PERCENT=${PERCENT:-0}
        
        POOL_COUNT=$((POOL_COUNT + 1))
        TOTAL_SIZE=$((TOTAL_SIZE + TOTAL_KB))
        TOTAL_USED=$((TOTAL_USED + USED_KB))
        
        if [ "$PERCENT" -gt "$MAX_PERCENT" ]; then
            MAX_PERCENT=$PERCENT
        fi
        
        local USED_GIB=$("$ECHO_BIN" "scale=1; $USED_KB / 1048576" | "$BC_BIN" 2>/dev/null || "$ECHO_BIN" "0.0")
        local TOTAL_GIB=$("$ECHO_BIN" "scale=1; $TOTAL_KB / 1048576" | "$BC_BIN" 2>/dev/null || "$ECHO_BIN" "0.0")
        
        POOLS_INFO+="$MOUNT_POINT: ${USED_GIB}G/${TOTAL_GIB}G (${PERCENT}%)\n"
        
    done <<< "$DEVICES"
    
    if [ "$POOL_COUNT" -eq 0 ]; then
        "$ECHO_BIN" "{\"text\": \"BTRFS: Sem dados\", \"class\": \"btrfs-error\"}"
        exit 0
    fi
    
    # Calcula totais
    local TOTAL_USED_GIB=$("$ECHO_BIN" "scale=1; $TOTAL_USED / 1048576" | "$BC_BIN" 2>/dev/null || "$ECHO_BIN" "0.0")
    local TOTAL_SIZE_GIB=$("$ECHO_BIN" "scale=1; $TOTAL_SIZE / 1048576" | "$BC_BIN" 2>/dev/null || "$ECHO_BIN" "0.0")
    
    # Define classe
    local CLASS="btrfs-normal"
    if [ "$MAX_PERCENT" -ge 90 ]; then
        CLASS="btrfs-critical"
    elif [ "$MAX_PERCENT" -ge 75 ]; then
        CLASS="btrfs-warning"
    fi
    
    # Modo de exibição
    local CURRENT_STATE=$("$CAT_BIN" "$STATE_FILE" 2>/dev/null || "$ECHO_BIN" "summary")
    
    local TEXT
    if [ "$CURRENT_STATE" = "detailed" ]; then
        TEXT="🗄️ $POOL_COUNT pools: ${TOTAL_USED_GIB}G/${TOTAL_SIZE_GIB}G (max ${MAX_PERCENT}%)"
    else
        TEXT="🗄️ ${TOTAL_USED_GIB}G/${TOTAL_SIZE_GIB}G (${MAX_PERCENT}%)"
    fi
    
    local TOOLTIP=$("$ECHO_BIN" -e "Pools BTRFS:\n$POOLS_INFO\nClique (L) detalhes / (R) alternar")
    
    "$PRINTF_BIN" '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' \
        "$TEXT" "$TOOLTIP" "$CLASS" | "$TR_BIN" -d '[:cntrl:]'
}

# ===== ALTERNAR EXIBIÇÃO =====
toggle_display() {
    local CURRENT=$("$CAT_BIN" "$STATE_FILE" 2>/dev/null || "$ECHO_BIN" "summary")
    
    if [ "$CURRENT" = "summary" ]; then
        "$ECHO_BIN" "detailed" > "$STATE_FILE"
    else
        "$ECHO_BIN" "summary" > "$STATE_FILE"
    fi
    
    pkill -RTMIN+8 waybar 2>/dev/null || true
}

# ===== MENU DETALHADO =====
show_menu() {
    local DEVICES=$("$MOUNT_BIN" -t btrfs 2>/dev/null | \
        "$AWK_BIN" '{print $1}' | \
        "$GREP_BIN" -E '^/dev' | \
        "$SORT_BIN" -u)
    
    # Usaremos uma variável temporária para armazenar o conteúdo
    local CONTENT=""
    
    while IFS= read -r DEVICE; do
        local MOUNT_POINT=$("$MOUNT_BIN" 2>/dev/null | \
            "$GREP_BIN" "^$DEVICE " | \
            "$AWK_BIN" '{print $3}' | \
            "$HEAD_BIN" -n 1)
        
        if [ -n "$MOUNT_POINT" ]; then
            # 1. Coleta dados (mantidos para garantir que as variáveis existam)
            local DF_OUTPUT=$("$DF_BIN" -k --output=size,used,avail,pcent "$MOUNT_POINT" 2>/dev/null | "$TAIL_BIN" -n 1)
            
            local TOTAL_KB=$("$ECHO_BIN" "$DF_OUTPUT" | "$AWK_BIN" '{print $1}' | "$TR_BIN" -cd '[:digit:]')
            local USED_KB=$("$ECHO_BIN" "$DF_OUTPUT" | "$AWK_BIN" '{print $2}' | "$TR_BIN" -cd '[:digit:]')
            local AVAIL_KB=$("$ECHO_BIN" "$DF_OUTPUT" | "$AWK_BIN" '{print $3}' | "$TR_BIN" -cd '[:digit:]')
            local PERCENT=$("$ECHO_BIN" "$DF_OUTPUT" | "$AWK_BIN" '{print $4}' | "$TR_BIN" -d '%' | "$TR_BIN" -cd '[:digit:]')
            
            TOTAL_KB=${TOTAL_KB:-0}
            USED_KB=${USED_KB:-0}
            AVAIL_KB=${AVAIL_KB:-0}
            PERCENT=${PERCENT:-0}

            # 2. Converte para GiB
            local TOTAL_GIB=$("$ECHO_BIN" "scale=2; $TOTAL_KB / 1048576" | "$BC_BIN" 2>/dev/null || "$ECHO_BIN" "0.00")
            local USED_GIB=$("$ECHO_BIN" "scale=2; $USED_KB / 1048576" | "$BC_BIN" 2>/dev/null || "$ECHO_BIN" "0.00")
            local AVAIL_GIB=$("$ECHO_BIN" "scale=2; $AVAIL_KB / 1048576" | "$BC_BIN" 2>/dev/null || "$ECHO_BIN" "0.00")
            
            # 3. Coleta dados BTRFS
            local BTRFS_USAGE=$("$BTRFS_BIN" filesystem usage "$MOUNT_POINT" 2>/dev/null | "$GREP_BIN" -E 'Data|Metadata')
            local DATA_ALLOC=$("$ECHO_BIN" "$BTRFS_USAGE" | "$GREP_BIN" "Data," | "$AWK_BIN" '{print $5 "/" $3}' | "$HEAD_BIN" -n 1)
            local META_ALLOC=$("$ECHO_BIN" "$BTRFS_USAGE" | "$GREP_BIN" "Metadata," | "$AWK_BIN" '{print $5 "/" $3}' | "$HEAD_BIN" -n 1)
            DATA_ALLOC=${DATA_ALLOC:-"N/A"}
            META_ALLOC=${META_ALLOC:-"N/A"}

            # 4. Define ICON e Emojis de Progresso
            local ICON="🟢"
            local PROGRESS_EMOJI="🟩"
            if [ "$PERCENT" -ge 90 ]; then
                ICON="🔴"
                PROGRESS_EMOJI="🟥"
            elif [ "$PERCENT" -ge 75 ]; then
                ICON="🟡"
                PROGRESS_EMOJI="🟧"
            fi
            
            local BAR_WIDTH=10
            local FILLED=$(( (PERCENT * BAR_WIDTH) / 100 ))
            local EMPTY=$(( BAR_WIDTH - FILLED ))
            local PROGRESS_BAR_EMOJIS=""
            for ((i=0; i<FILLED; i++)); do PROGRESS_BAR_EMOJIS+="$PROGRESS_EMOJI"; done
            for ((i=0; i<EMPTY; i++)); do PROGRESS_BAR_EMOJIS+="⬜"; done
            
            local SUBVOL_COUNT=$("$BTRFS_BIN" subvolume list "$MOUNT_POINT" 2>/dev/null | wc -l || "$ECHO_BIN" "0")
            
            # 5. Constrói o conteúdo: Removemos <big> e <i>. Usamos apenas <b>.
            CONTENT+="\n<b>$ICON Pool: $MOUNT_POINT</b> (<small>$DEVICE</small>)\n"
            CONTENT+="  - Usage (DF): <b>$PROGRESS_BAR_EMOJIS ${PERCENT}%</b>\n"
            CONTENT+="  - Space (DF): ${USED_GIB} GiB used / ${TOTAL_GIB} GiB total\n"
            CONTENT+="  - 🧱 <b>BTRFS Data:</b> Used <b>$DATA_ALLOC</b>\n"
            CONTENT+="  - 🧠 <b>BTRFS Metadata:</b> Used <b>$META_ALLOC</b>\n"
            CONTENT+="  - Available (DF): ${AVAIL_GIB} GiB free\n"
            CONTENT+="  - Subvolumes: $SUBVOL_COUNT\n"
            CONTENT+="--------------------------------------------------------\n"

        fi
    done <<< "$DEVICES"
    
    # Adiciona a dica sem a tag <i>
    CONTENT+="\n💡 Dica: Data e Metadata mostram a alocação interna do BTRFS."

    # >>> CHAMADA YAD CORRIGIDA <<<
    # Passamos o conteúdo diretamente para --text e removemos --text-info
    # Também garantimos que --markup venha logo no início.
    "$YAD_BIN" --markup \
        --text="$CONTENT" \
        --title="BTRFS Pools Status" \
        --width=550 --height=450 \
        --center \
        --wrap --justify=left \
        --button="OK:0" \
        --fontname="Fira Sans Semibold 11" 2>/dev/null || true
}

# ===== EXECUÇÃO =====
case "$MODE" in
    --menu)
        show_menu
        ;;
    --toggle)
        toggle_display
        ;;
    --display|*)
        collect_all_pools
        ;;
esac