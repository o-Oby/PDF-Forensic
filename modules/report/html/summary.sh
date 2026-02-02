#!/bin/bash
# modules/report/html/summary.sh - Génération du résumé

# Injecte le résumé dans le rapport HTML
# Usage: pf_inject_summary
pf_inject_summary() {
    local summary_mods=$((PF_REVISIONS > 0 ? PF_REVISIONS - 1 : 0))
    local summary_attach_show="$PF_SUMMARY_ATTACHMENTS"
    local summary_js_show="$PF_SUMMARY_JS_COUNT"
    local summary_ghost_show="$PF_SUMMARY_GHOST"
    local summary_markers_show="$PF_SUMMARY_MARKERS"

    [ "$PF_HAS_PDFDETACH" -eq 0 ] && summary_attach_show="$T_NA"
    [ -z "$summary_markers_show" ] && summary_markers_show="$T_NA"

    local summary_mods_esc summary_attach_esc summary_attach_names_esc
    local summary_js_esc summary_js_names_esc summary_ghost_esc summary_markers_esc

    summary_mods_esc=$(printf '%s' "$summary_mods" | pf_html_escape)
    summary_attach_esc=$(printf '%s' "$summary_attach_show" | pf_html_escape)
    summary_attach_names_esc=$(printf '%s' "$PF_SUMMARY_ATTACH_NAMES" | pf_html_escape)
    summary_js_esc=$(printf '%s' "$summary_js_show" | pf_html_escape)
    summary_js_names_esc=$(printf '%s' "$PF_SUMMARY_JS_NAMES" | pf_html_escape)
    summary_ghost_esc=$(printf '%s' "$summary_ghost_show" | pf_html_escape)
    summary_markers_esc=$(printf '%s' "$summary_markers_show" | pf_html_escape)

    local summary_attach_line="$summary_attach_esc"
    [ -n "$PF_SUMMARY_ATTACH_NAMES" ] && summary_attach_line="$summary_attach_line ($summary_attach_names_esc)"

    local summary_js_line="$summary_js_esc"
    [ -n "$PF_SUMMARY_JS_NAMES" ] && summary_js_line="$summary_js_line ($summary_js_names_esc)"

    if [ -z "$PF_SUMMARY_ROWS" ]; then
        PF_SUMMARY_ROWS="<tr><td>$T_NA</td><td>$T_NA</td><td>$T_NA</td><td>$T_NA</td><td>$T_NA</td></tr>"
    fi

    # Utiliser awk pour injecter le résumé
    awk -v sfile=/dev/fd/3 '
        $0 == "        __SUMMARY_PLACEHOLDER__" {
            while ((getline line < sfile) > 0) print line;
            close(sfile);
            next
        }
        { print }
    ' "$PF_REPORT" 3<<EOF > "$PF_REPORT.tmp" && mv "$PF_REPORT.tmp" "$PF_REPORT"
        <div class="section-title">$T_SUMMARY</div>
        <div class="summary-box">
            <p><strong>$T_MOD_COUNT</strong></p>
            <p><strong>$T_CHANGE_TEXT:</strong> $PF_SUMMARY_TEXT_CHANGES &nbsp;|&nbsp; <strong>$T_CHANGE_META:</strong> $PF_SUMMARY_META_CHANGES &nbsp;|&nbsp; <strong>$T_CHANGE_FONTS:</strong> $PF_SUMMARY_FONT_CHANGES</p>
            <p><strong>$T_CHANGE_ATTACH:</strong> $summary_attach_line &nbsp;|&nbsp; <strong>$T_CHANGE_JS:</strong> $summary_js_line &nbsp;|&nbsp; <strong>$T_CHANGE_GHOST:</strong> $summary_ghost_esc</p>
            <p><strong>$T_CHANGE_SOFT:</strong> $summary_markers_esc</p>
            <table class="summary-table">
                <thead>
                    <tr>
                        <th>$T_REVISION</th>
                        <th>$T_WHEN</th>
                        <th>$T_CHANGE_TYPES</th>
                        <th>$T_DETAILS</th>
                        <th>$T_SOFTWARE</th>
                    </tr>
                </thead>
                <tbody>
                    $PF_SUMMARY_ROWS
                </tbody>
            </table>
        </div>
EOF
}

# Formate une date PDF (2025:01:21 13:26:57+01:00) en format lisible
# Usage: _pf_format_pdf_date "2025:01:21 13:26:57+01:00"
_pf_format_pdf_date() {
    local raw_date="$1"

    # Si vide ou N/A, retourner tel quel
    [[ -z "$raw_date" || "$raw_date" == "$T_NA" ]] && { echo "$T_NA"; return; }

    # Extraire les composants (format: 2025:01:21 13:26:57+01:00)
    local year month day hour min sec tz_part

    # Nettoyer et parser
    raw_date=$(echo "$raw_date" | tr -d '\n' | sed 's/^ *//')

    if [[ "$raw_date" =~ ^([0-9]{4}):([0-9]{2}):([0-9]{2})[[:space:]]+([0-9]{2}):([0-9]{2}):([0-9]{2})(.*)$ ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        day="${BASH_REMATCH[3]#0}"  # Supprimer le zéro initial
        hour="${BASH_REMATCH[4]}"
        min="${BASH_REMATCH[5]}"
        sec="${BASH_REMATCH[6]}"
        tz_part="${BASH_REMATCH[7]}"

        # Formater le timezone (+01:00 → UTC+1)
        if [[ -n "$tz_part" ]]; then
            local tz_sign="" tz_hours=""
            # Extraire le signe
            [[ "$tz_part" == +* ]] && tz_sign="+"
            [[ "$tz_part" == -* ]] && tz_sign="-"
            # Extraire les heures (supprimer signe, prendre avant ":", supprimer zéro initial)
            tz_hours=$(echo "$tz_part" | sed 's/^[+-]//' | cut -d':' -f1 | sed 's/^0//')
            [[ -n "$tz_hours" ]] && tz_part=" (UTC${tz_sign}${tz_hours})" || tz_part=""
        fi

        local month_name
        if [ "$PF_LANG" == "FR" ]; then
            case "$month" in
                01) month_name="jan" ;; 02) month_name="fév" ;; 03) month_name="mar" ;;
                04) month_name="avr" ;; 05) month_name="mai" ;; 06) month_name="jun" ;;
                07) month_name="jul" ;; 08) month_name="aoû" ;; 09) month_name="sep" ;;
                10) month_name="oct" ;; 11) month_name="nov" ;; 12) month_name="déc" ;;
            esac
            echo "$day $month_name $year, $hour:$min:$sec$tz_part"
        else
            case "$month" in
                01) month_name="Jan" ;; 02) month_name="Feb" ;; 03) month_name="Mar" ;;
                04) month_name="Apr" ;; 05) month_name="May" ;; 06) month_name="Jun" ;;
                07) month_name="Jul" ;; 08) month_name="Aug" ;; 09) month_name="Sep" ;;
                10) month_name="Oct" ;; 11) month_name="Nov" ;; 12) month_name="Dec" ;;
            esac
            echo "$month_name $day, $year, $hour:$min:$sec$tz_part"
        fi
    else
        # Si le format ne correspond pas, retourner tel quel
        echo "$raw_date"
    fi
}

# Ajoute une ligne au tableau de résumé
# Usage: pf_add_summary_row $rev_num "$date" "$changes" "$details" "$software"
pf_add_summary_row() {
    local rev_num="$1"
    local rev_date="$2"
    local rev_changes="$3"
    local rev_details="$4"
    local rev_software="$5"

    local rev_date_formatted rev_date_esc rev_changes_esc rev_details_esc rev_soft_esc

    rev_date_formatted=$(_pf_format_pdf_date "$rev_date")
    rev_date_esc=$(printf '%s' "$rev_date_formatted" | pf_html_escape)
    rev_changes_esc=$(printf '%s' "$rev_changes" | pf_html_escape)
    rev_details_esc=$(printf '%s' "$rev_details" | pf_html_escape)
    rev_soft_esc=$(printf '%s' "$rev_software" | pf_html_escape)

    PF_SUMMARY_ROWS+=$'<tr><td>'"$rev_num"$'</td><td>'"$rev_date_esc"$'</td><td>'"$rev_changes_esc"$'</td><td>'"$rev_details_esc"$'</td><td>'"$rev_soft_esc"$'</td></tr>\n'
}
