#!/bin/bash
# modules/revisions/extractor.sh - Extraction des révisions PDF

# Extrait une révision spécifique du PDF
# Usage: pf_extract_revision $index
# Args: $1 = index dans PF_EOF_OFFSETS (0-based)
# Crée: rev_N.pdf, meta_N.txt, text_N.txt, fonts_N.txt
pf_extract_revision() {
    local i="$1"
    local rev_num=$((i + 1))
    local offset="${PF_EOF_OFFSETS[i]}"
    local rev_pdf="$PF_LAB_DIR/revisions/rev_${rev_num}.pdf"

    # Extraire le PDF jusqu'à cet offset
    head -c "$offset" "$PF_FILE" > "$rev_pdf"

    # Calculer le hash
    if [ -n "$PF_HASH_CMD" ]; then
        PF_REV_HASH=$($PF_HASH_CMD "$rev_pdf" | awk '{print $1}')
    else
        PF_REV_HASH="N/A"
    fi

    # Extraire les métadonnées avec exiftool
    if [ "$PF_HAS_EXIFTOOL" -eq 1 ]; then
        exiftool -G1 -a -s "$rev_pdf" > "$PF_LAB_DIR/revisions/meta_${rev_num}.txt"
    fi

    # Extraire le texte avec pdftotext
    if [ "$PF_HAS_PDFTOTEXT" -eq 1 ]; then
        pdftotext -q "$rev_pdf" "$PF_LAB_DIR/revisions/text_${rev_num}.txt" 2>/dev/null
    fi

    # Extraire les polices avec pdffonts
    if [ "$PF_HAS_PDFFONTS" -eq 1 ]; then
        pdffonts "$rev_pdf" 2>/dev/null > "$PF_LAB_DIR/revisions/fonts_${rev_num}.txt"
    fi

    echo -e "    Processing Rev $rev_num [SHA: ${PF_CYAN}${PF_REV_HASH:0:8}...${PF_NC}]"

    export PF_REV_HASH
}

# Récupère les métadonnées d'une révision
# Usage: pf_get_revision_metadata $rev_num
# Sets: PF_REV_CREATE_DATE, PF_REV_MODIFY_DATE, PF_REV_SOFTWARE, PF_REV_PLATFORM
pf_get_revision_metadata() {
    local rev_num="$1"
    local meta_file="$PF_LAB_DIR/revisions/meta_${rev_num}.txt"

    PF_REV_CREATE_DATE="$T_NA"
    PF_REV_MODIFY_DATE="$T_NA"
    PF_REV_SOFTWARE="$T_NA"
    PF_REV_PLATFORM="$T_NA"

    if [ "$PF_HAS_EXIFTOOL" -eq 1 ] && [ -f "$meta_file" ]; then
        PF_REV_CREATE_DATE=$(grep -m1 -E "\bCreateDate\b" "$meta_file" 2>/dev/null | sed 's/.*: //' || true)
        PF_REV_MODIFY_DATE=$(grep -m1 -E "\bModifyDate\b" "$meta_file" 2>/dev/null | sed 's/.*: //' || true)

        local producer creator creator_tool
        producer=$(grep -m1 -E "\bProducer\b" "$meta_file" 2>/dev/null | sed 's/.*: //' || true)
        creator=$(grep -m1 -E "\bCreator\b" "$meta_file" 2>/dev/null | sed 's/.*: //' || true)
        creator_tool=$(grep -m1 -E "\bCreatorTool\b" "$meta_file" 2>/dev/null | sed 's/.*: //' || true)

        PF_REV_SOFTWARE=$(printf '%s; %s; %s' "$creator_tool" "$producer" "$creator" | sed 's/^[; ]*//; s/[; ]*$//; s/;  */; /g')
        [ -z "$PF_REV_SOFTWARE" ] && PF_REV_SOFTWARE="$T_NA"

        PF_REV_PLATFORM=$(pf_infer_platform "$PF_REV_SOFTWARE")
        [ -z "$PF_REV_PLATFORM" ] && PF_REV_PLATFORM="$T_NA"
        [ -z "$PF_REV_CREATE_DATE" ] && PF_REV_CREATE_DATE="$T_NA"
        [ -z "$PF_REV_MODIFY_DATE" ] && PF_REV_MODIFY_DATE="$T_NA"
    fi

    export PF_REV_CREATE_DATE PF_REV_MODIFY_DATE PF_REV_SOFTWARE PF_REV_PLATFORM
}
