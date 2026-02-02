#!/bin/bash
# lib/cli/parser.sh - Parsing des arguments CLI

# Parse les arguments de la ligne de commande
# Usage: pf_parse_args "$@"
# Modifie: PF_FILE, PF_LANG, PF_LANG_SET, PF_OUTPUT_MODE, PF_OUTPUT_SET
pf_parse_args() {
    PF_LANG=""
    PF_LANG_SET=0
    PF_FILE=""
    PF_OUTPUT_MODE=""
    PF_OUTPUT_SET=0

    while [ $# -gt 0 ]; do
        case "$1" in
            --en) PF_LANG="EN"; PF_LANG_SET=1 ;;
            --fr) PF_LANG="FR"; PF_LANG_SET=1 ;;
            -h|--help) pf_usage; exit 0 ;;
            --) shift; [ -z "$1" ] || PF_FILE=$1; break ;;
            -*)
                echo -e "${PF_RED}Error:${PF_NC} Unknown option: $1"
                pf_usage
                exit 1
                ;;
            *)
                if [ -z "$PF_FILE" ]; then
                    PF_FILE=$1
                else
                    echo -e "${PF_RED}Error:${PF_NC} Multiple files provided. Use a single PDF."
                    pf_usage
                    exit 1
                fi
                ;;
        esac
        shift
    done

    export PF_FILE PF_LANG PF_LANG_SET PF_OUTPUT_MODE PF_OUTPUT_SET
}

# Valide que le fichier existe
# Usage: pf_validate_file
pf_validate_file() {
    if [ -z "$PF_FILE" ]; then
        pf_usage
        exit 1
    fi

    if [ ! -f "$PF_FILE" ]; then
        echo -e "${PF_RED}Error:${PF_NC} File '$PF_FILE' not found."
        exit 1
    fi
}
