#!/bin/bash
# lib/i18n/loader.sh - Chargeur de traductions

# Charge les traductions pour une langue donnée
# Usage: pf_load_language "FR" ou pf_load_language "EN"
pf_load_language() {
    local lang="${1:-FR}"
    local lang_lower
    lang_lower=$(printf '%s' "$lang" | tr '[:upper:]' '[:lower:]')
    local lang_file="${PF_SCRIPT_DIR}/lib/i18n/${lang_lower}.sh"

    if [[ -f "$lang_file" ]]; then
        source "$lang_file"
        case "$lang_lower" in
            fr) pf_init_translations_fr ;;
            en) pf_init_translations_en ;;
            *)
                echo -e "${PF_YELLOW}Warning:${PF_NC} Unknown language: $lang, falling back to English"
                source "${PF_SCRIPT_DIR}/lib/i18n/en.sh"
                pf_init_translations_en
                ;;
        esac
    else
        echo -e "${PF_RED}Error:${PF_NC} Language file not found: $lang_file"
        echo "Falling back to English..."
        source "${PF_SCRIPT_DIR}/lib/i18n/en.sh"
        pf_init_translations_en
    fi

    export PF_LANG="$lang"
}
