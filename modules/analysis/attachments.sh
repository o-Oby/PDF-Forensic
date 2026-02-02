#!/bin/bash
# modules/analysis/attachments.sh - Détection des pièces jointes

# Scanne les pièces jointes du PDF
# Usage: pf_scan_attachments "$file"
# Modifie: PF_SUMMARY_ATTACHMENTS, PF_SUMMARY_ATTACH_NAMES
pf_scan_attachments() {
    local file="$1"

    pf_print_section "$T_ATTACH"

    if [ "$PF_HAS_PDFDETACH" -eq 1 ]; then
        pdfdetach -list "$file" 2>/dev/null > "$PF_LAB_DIR/attachments_list.txt"

        # Compter les entrées
        local attach_found
        attach_found=$(grep -c "^[0-9][0-9]*" "$PF_LAB_DIR/attachments_list.txt" || echo 0)
        PF_SUMMARY_ATTACHMENTS=$attach_found

        if [ "$attach_found" -gt 0 ]; then
            PF_SUMMARY_ATTACH_NAMES=$(sed -E 's/^[0-9]+[: ]+//' "$PF_LAB_DIR/attachments_list.txt" | head -5 | paste -sd ", " -)
            echo -e "    ${PF_RED}$T_ATTACH_ALERT${PF_NC}"

            # Extraire les pièces jointes
            pdfdetach -saveall -o "$PF_LAB_DIR/attachments" "$file" 2>/dev/null

            # Écrire dans le rapport HTML
            echo "<div class='section-title'>Attachments / Pièces Jointes</div><div class='revision'><p>$T_ATTACH_ALERT</p><ul>" >> "$PF_REPORT"
            while read -r line; do
                local line_esc
                line_esc=$(printf '%s' "$line" | pf_html_escape)
                echo -e "    - Attachment: ${PF_CYAN}$line${PF_NC}"
                echo "<li>$line_esc</li>" >> "$PF_REPORT"
            done < "$PF_LAB_DIR/attachments_list.txt"
            echo "</ul></div>" >> "$PF_REPORT"
        fi
    else
        echo -e "    $T_SKIPPED"
    fi

    export PF_SUMMARY_ATTACHMENTS PF_SUMMARY_ATTACH_NAMES
}
