#!/bin/bash
# modules/analysis/boundaries.sh - Vérification des bordures de page

# Analyse les bordures MediaBox/CropBox
# Usage: pf_check_boundaries "$file"
pf_check_boundaries() {
    local file="$1"

    pf_print_section "$T_BOXES"

    if [ "$PF_HAS_PDFINFO" -eq 1 ]; then
        local boxes media crop
        boxes=$(pdfinfo -box "$file" 2>/dev/null)
        media=$(echo "$boxes" | grep "MediaBox" | awk '{$1=""; print $0}' | xargs)
        crop=$(echo "$boxes" | grep "CropBox" | awk '{$1=""; print $0}' | xargs)

        echo -e "    - MediaBox: [ $media ]"
        echo -e "    - CropBox:  [ $crop ]"

        if [ "$media" != "$crop" ] && [ -n "$media" ] && [ -n "$crop" ]; then
            echo -e "    ${PF_RED}$T_BOX_ALERT${PF_NC}"
            echo "<div class='alert-box'>$T_BOX_ALERT (Media vs Crop)</div>" >> "$PF_REPORT"
        fi
    else
        echo -e "    $T_SKIPPED"
    fi
}
