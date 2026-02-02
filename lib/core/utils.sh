#!/bin/bash
# lib/core/utils.sh - Fonctions utilitaires

# Vérifie si une commande existe
# Usage: pf_have_cmd "exiftool"
pf_have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# Échappe les caractères HTML
# Usage: echo "text" | pf_html_escape
pf_html_escape() {
    sed -e 's/&/\&amp;/g' \
        -e 's/</\&lt;/g' \
        -e 's/>/\&gt;/g' \
        -e 's/"/\&quot;/g' \
        -e "s/'/\&#39;/g"
}

# Infère la plateforme à partir d'une chaîne (metadata)
# Usage: pf_infer_platform "Microsoft Word for Windows"
pf_infer_platform() {
    local s
    s=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
    if [[ $s == *windows* || $s == *win32* || $s == *win64* ]]; then
        echo "Windows"
    elif [[ $s == *mac* || $s == *os\ x* || $s == *darwin* ]]; then
        echo "macOS"
    elif [[ $s == *linux* || $s == *ubuntu* || $s == *debian* ]]; then
        echo "Linux"
    else
        echo ""
    fi
}

# Affiche l'en-tête du script
# Usage: pf_print_header
pf_print_header() {
    local width=62
    local title="$T_LAB"
    local version="Version $PF_APP_VERSION"
    local title_pad=$(( (width - ${#title}) / 2 ))
    local version_pad=$(( (width - ${#version}) / 2 ))

    echo ""
    echo -e "${PF_GREEN}╔══════════════════════════════════════════════════════════════╗${PF_NC}"
    echo -e "${PF_GREEN}║${PF_NC}$(printf '%*s' $title_pad '')${PF_CYAN}${title}${PF_NC}$(printf '%*s' $((width - title_pad - ${#title})) '')${PF_GREEN}║${PF_NC}"
    echo -e "${PF_GREEN}║${PF_NC}$(printf '%*s' $version_pad '')${PF_PURPLE}${version}${PF_NC}$(printf '%*s' $((width - version_pad - ${#version})) '')${PF_GREEN}║${PF_NC}"
    echo -e "${PF_GREEN}╚══════════════════════════════════════════════════════════════╝${PF_NC}"
    echo ""
    echo -e "${PF_GREEN}┌─ File ────────────────────────────────────────────────────────┐${PF_NC}"
    echo -e "${PF_GREEN}│${PF_NC}  ${PF_YELLOW}${PF_FILE}${PF_NC}"
    echo -e "${PF_GREEN}│${PF_NC}  SHA-256: ${PF_CYAN}${PF_GLOBAL_HASH:0:48}...${PF_NC}"
    echo -e "${PF_GREEN}│${PF_NC}  Output:  ${PF_BLUE}${PF_LAB_DIR}${PF_NC}"
    echo -e "${PF_GREEN}└───────────────────────────────────────────────────────────────┘${PF_NC}"
    echo ""
}

# Affiche un titre de section
# Usage: pf_print_section "Section Title"
pf_print_section() {
    echo -e "\n${PF_GREEN}:: $1${PF_NC}"
}

# Affiche l'usage du script
# Usage: pf_usage
pf_usage() {
    echo -e "${PF_BLUE}Usage:${PF_NC} $0 [file.pdf] [--en|--fr]"
}
