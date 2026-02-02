#!/bin/bash
# lib/cli/prompts.sh - Prompts interactifs

# Demande la langue si non spécifiée
# Usage: pf_prompt_language
pf_prompt_language() {
    if [ "$PF_LANG_SET" -eq 0 ]; then
        if [ -t 0 ]; then
            echo -e "${PF_BLUE}Choose language / Choisir la langue:${PF_NC}"
            echo "  1) Français"
            echo "  2) English"
            read -p "Select [1-2] (default: 1): " -r LANG_CHOICE
            case "$LANG_CHOICE" in
                2) PF_LANG="EN" ;;
                1|"") PF_LANG="FR" ;;
                *) PF_LANG="FR" ;;
            esac
        else
            PF_LANG="FR"
        fi
        export PF_LANG
    fi
}

# Exécute tous les prompts nécessaires
# Usage: pf_run_prompts
pf_run_prompts() {
    pf_prompt_language
    pf_load_language "$PF_LANG"
    PF_WANT_HTML_OUTPUT=1
    export PF_WANT_HTML_OUTPUT
}
