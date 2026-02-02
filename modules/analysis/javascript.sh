#!/bin/bash
# modules/analysis/javascript.sh - Détection de JavaScript et actions

# Détecte les scripts et actions automatiques
# Usage: pf_detect_javascript "$file"
# Modifie: PF_SUMMARY_JS_COUNT, PF_SUMMARY_JS_NAMES
pf_detect_javascript() {
    local file="$1"
    local js_hits

    js_hits=$(grep -aoEi "/JS|/JavaScript|/OpenAction|/AA" "$file" 2>/dev/null | sort | uniq -c || true)

    if [ -n "$js_hits" ]; then
        local js_hits_esc
        js_hits_esc=$(printf '%s' "$js_hits" | pf_html_escape)

        PF_SUMMARY_JS_COUNT=$(echo "$js_hits" | awk '{sum+=$1} END{print sum+0}')
        PF_SUMMARY_JS_NAMES=$(echo "$js_hits" | awk '{print $2}' | paste -sd ", " -)

        echo -e "    ${PF_RED}$T_JS_ALERT${PF_NC}"
        echo "<div class='section-title'>Active Content</div><pre class='diff-box'>$js_hits_esc</pre>" >> "$PF_REPORT"
    fi

    export PF_SUMMARY_JS_COUNT PF_SUMMARY_JS_NAMES
}
