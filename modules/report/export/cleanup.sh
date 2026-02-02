#!/bin/bash
# modules/report/export/cleanup.sh - Nettoyage des fichiers temporaires

# Demande et effectue le nettoyage si interactif
# Usage: pf_cleanup
pf_cleanup() {
    if [ -t 0 ]; then
        read -p "$T_CLEANUP (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PF_LAB_DIR/revisions" "$PF_LAB_DIR/images" "$PF_LAB_DIR/ocr" "$PF_LAB_DIR/attachments" "$PF_LAB_DIR/attachments_list.txt"
            echo -e "    (v) $T_KEEP_REPORT"
        fi
    else
        echo -e "    $T_NON_INTERACTIVE"
    fi
}
