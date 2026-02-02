#!/bin/bash
# modules/analysis/structural.sh - Analyse structurale DNA du PDF

# Analyse la structure du PDF (EOF offsets, objets)
# Usage: pf_analyze_structure "$file"
# Modifie: PF_EOF_OFFSETS (array), PF_REVISIONS, PF_GLOBAL_HASH, PF_OBJECTS, PF_MAX_OBJ
pf_analyze_structure() {
    local file="$1"

    # Trouver tous les %%EOF et calculer les offsets
    PF_EOF_OFFSETS=()
    while IFS= read -r pos; do
        local end=$((pos + 5))
        local trail
        trail=$(dd if="$file" bs=1 skip=$end count=2 2>/dev/null | od -An -t u1 | tr -s ' ')
        local b1 b2
        read -r b1 b2 <<<"$trail"
        if [ "$b1" = "13" ]; then
            end=$((end + 1))
            [ "$b2" = "10" ] && end=$((end + 1))
        elif [ "$b1" = "10" ]; then
            end=$((end + 1))
        fi
        PF_EOF_OFFSETS+=("$end")
    done < <(grep -aob "%%EOF" "$file" | cut -d: -f1)

    PF_REVISIONS=${#PF_EOF_OFFSETS[@]}

    # Hash global
    if [ -n "$PF_HASH_CMD" ]; then
        PF_GLOBAL_HASH=$($PF_HASH_CMD "$file" | awk '{print $1}')
    else
        PF_GLOBAL_HASH="N/A"
    fi

    # Analyse des objets avec qpdf
    if [ "$PF_HAS_QPDF" -eq 1 ]; then
        local xref_data
        xref_data=$(qpdf --show-xref "$file" 2>/dev/null)
        PF_OBJECTS=$(echo "$xref_data" | grep -c "/" || echo 0)
        PF_MAX_OBJ=$(echo "$xref_data" | awk -F'/' '/\// {print $1}' | sort -n | tail -1)
        PF_MAX_OBJ=${PF_MAX_OBJ:-0}
    else
        PF_OBJECTS=0
        PF_MAX_OBJ=0
    fi

    export PF_EOF_OFFSETS PF_REVISIONS PF_GLOBAL_HASH PF_OBJECTS PF_MAX_OBJ
}

# Affiche les résultats de l'analyse structurale
# Usage: pf_print_structure_results
pf_print_structure_results() {
    pf_print_section "$T_INTEGRITY"
    echo -e "    - $T_SHA : ${PF_YELLOW}$PF_GLOBAL_HASH${PF_NC}"
    echo -e "    - $T_REVISIONS : ${PF_YELLOW}$PF_REVISIONS${PF_NC}"

    pf_print_section "$T_DNA"
    echo -e "    - $T_OBJ_TOTAL : $PF_OBJECTS"
    echo -e "    - $T_OBJ_MAX : $PF_MAX_OBJ"

    if [ "$PF_MAX_OBJ" -gt 0 ] && [ "$PF_MAX_OBJ" -gt $((PF_OBJECTS * 2)) ]; then
        echo -e "    ${PF_RED}$T_DNA_ALERT${PF_NC}"
    fi
}

# Écrit les alertes DNA dans le rapport HTML
# Usage: pf_write_dna_alert_html
pf_write_dna_alert_html() {
    if [ "$PF_MAX_OBJ" -gt 0 ] && [ "$PF_MAX_OBJ" -gt $((PF_OBJECTS * 2)) ]; then
        echo "<div class='alert-box'>$T_DNA_ALERT</div>" >> "$PF_REPORT"
    fi
}
