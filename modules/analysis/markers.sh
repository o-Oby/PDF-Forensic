#!/bin/bash
# modules/analysis/markers.sh - Détection des signatures logicielles et texte invisible

# Scanne les marqueurs globaux (signatures logicielles)
# Usage: pf_scan_markers "$file"
# Modifie: PF_SUMMARY_MARKERS, PF_SUMMARY_GHOST
pf_scan_markers() {
    local file="$1"

    pf_print_section "$T_SCAN_GLOBAL"

    local markers sign_html=""
    markers=$(grep -aoE "/[A-Z]{3,}[A-Za-z0-9]{2,}" "$file" 2>/dev/null | sort | uniq | grep -iE "UPDF|Adobe|Acro|Nitro|Foxit|SmallPDF" || true)

    if [ -n "$markers" ]; then
        echo -e "    - $T_SIGN_FOUND : ${PF_GREEN}$markers${PF_NC}"
        PF_SUMMARY_MARKERS="$markers"

        sign_html="<ul>"
        for m in $markers; do
            local m_esc
            m_esc=$(printf '%s' "$m" | pf_html_escape)
            sign_html+="<li>Software Signature: <strong>$m_esc</strong></li>"
        done
        sign_html+="</ul>"
    fi

    # Détection du texte invisible (Mode 3)
    local ghost ghost_html=""
    ghost=$(grep -aoEi "/Tr 3|/Tr3" "$file" 2>/dev/null | wc -l | xargs || echo "0")
    ghost=${ghost:-0}

    if [ "$ghost" -gt 0 ] 2>/dev/null; then
        echo -e "    ${PF_RED}$T_GHOST_ALERT${PF_NC}"
        PF_SUMMARY_GHOST=$ghost
        ghost_html="<div class='alert-box'>$T_GHOST_ALERT</div>"
    fi

    # Écrire dans le rapport
    cat <<EOF >> "$PF_REPORT"
        <div class="section-title">$T_SIGN_FOUND</div>
        <div class="meta-box">$sign_html $ghost_html</div>
EOF

    export PF_SUMMARY_MARKERS PF_SUMMARY_GHOST
}

# Affiche le log complet des signatures
# Usage: pf_print_signature_log "$file"
pf_print_signature_log() {
    local file="$1"

    pf_print_section "$T_LOG_SIGN"

    if [ "$PF_HAS_STRINGS" -eq 1 ]; then
        strings "$file" | grep -iE "Producer|Creator|CreatorTool" | sort | uniq | sed 's/^/    - /' || true
    else
        echo -e "    $T_SKIPPED"
    fi
}
