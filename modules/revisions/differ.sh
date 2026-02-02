#!/bin/bash
# modules/revisions/differ.sh - Comparaison entre révisions

# Compare le texte entre deux révisions
# Usage: pf_diff_text $rev_num $prev_num
# Returns: 0 si diff trouvé, 1 sinon
# Modifie: PF_SUMMARY_TEXT_CHANGES
pf_diff_text() {
    local rev="$1"
    local prev="$2"

    [ "$PF_HAS_PDFTOTEXT" -eq 0 ] && { echo -e "      $T_TEXT_MOD $T_SKIPPED"; return 1; }

    local t_diff
    t_diff=$(diff -u "$PF_LAB_DIR/revisions/text_${prev}.txt" "$PF_LAB_DIR/revisions/text_${rev}.txt")

    if [ -n "$t_diff" ]; then
        PF_SUMMARY_TEXT_CHANGES=$((PF_SUMMARY_TEXT_CHANGES + 1))

        local text_add=0 text_rem=0 text_sa_count=0 text_sr_count=0
        local text_samples_add="" text_samples_rem=""
        local sub_cls="subsection diff-section"
        local diff_line_count=0

        echo "<table class='$sub_cls'><tr><td><h4 class='subsection-title'>$T_TEXT_MOD</h4><div class='diff-box'><table class='diff-table'><tbody>" >> "$PF_REPORT"

        while read -r line; do
            if [[ $line == +* ]] && [[ $line != +++* ]]; then
                if [ $diff_line_count -gt 0 ] && [ $((diff_line_count % PF_DIFF_CHUNK_LINES)) -eq 0 ]; then
                    echo "</tbody></table></div></td></tr></table>" >> "$PF_REPORT"
                    echo "<table class='$sub_cls page-break'><tr><td><h4 class='subsection-title'>$T_TEXT_MOD $T_CONT</h4><div class='diff-box'><table class='diff-table'><tbody>" >> "$PF_REPORT"
                fi
                text_add=$((text_add + 1))
                if [ $text_sa_count -lt 2 ]; then
                    local sample
                    sample=$(printf '%s' "${line#?}" | cut -c1-60)
                    text_samples_add="${text_samples_add}+${sample}; "
                    text_sa_count=$((text_sa_count + 1))
                fi
                local content_esc
                content_esc=$(printf '%s' "${line#?}" | pf_html_escape)
                echo "<tr class='diff-add'><td>$content_esc</td></tr>" >> "$PF_REPORT"
                diff_line_count=$((diff_line_count + 1))
            elif [[ $line == -* ]] && [[ $line != ---* ]]; then
                if [ $diff_line_count -gt 0 ] && [ $((diff_line_count % PF_DIFF_CHUNK_LINES)) -eq 0 ]; then
                    echo "</tbody></table></div></td></tr></table>" >> "$PF_REPORT"
                    echo "<table class='$sub_cls page-break'><tr><td><h4 class='subsection-title'>$T_TEXT_MOD $T_CONT</h4><div class='diff-box'><table class='diff-table'><tbody>" >> "$PF_REPORT"
                fi
                text_rem=$((text_rem + 1))
                if [ $text_sr_count -lt 2 ]; then
                    local sample
                    sample=$(printf '%s' "${line#?}" | cut -c1-60)
                    text_samples_rem="${text_samples_rem}-${sample}; "
                    text_sr_count=$((text_sr_count + 1))
                fi
                local content_esc
                content_esc=$(printf '%s' "${line#?}" | pf_html_escape)
                echo "<tr class='diff-rem'><td>$content_esc</td></tr>" >> "$PF_REPORT"
                diff_line_count=$((diff_line_count + 1))
            fi
        done <<< "$t_diff"

        echo "</tbody></table></div></td></tr></table>" >> "$PF_REPORT"

        # Construire le détail pour le résumé
        PF_TEXT_DETAIL=""
        if [ "$text_add" -gt 0 ] || [ "$text_rem" -gt 0 ]; then
            PF_TEXT_DETAIL="$T_CHANGE_TEXT: +$text_add/-$text_rem"
            text_samples_add=${text_samples_add%"; "}
            text_samples_rem=${text_samples_rem%"; "}
            local sample_combo=""
            [ -n "$text_samples_add" ] && sample_combo="$text_samples_add"
            [ -n "$text_samples_rem" ] && sample_combo="$sample_combo $text_samples_rem"
            [ -n "$sample_combo" ] && PF_TEXT_DETAIL="$PF_TEXT_DETAIL (ex: $sample_combo)"
        fi

        # Afficher le résumé détaillé dans le terminal
        echo -e "      ${PF_RED}$T_TEXT_MOD${PF_NC} ${PF_GREEN}+${text_add}${PF_NC} / ${PF_RED}-${text_rem}${PF_NC} lines"
        if [ -n "$text_samples_add" ]; then
            echo -e "        ${PF_GREEN}+ ${text_samples_add}${PF_NC}"
        fi
        if [ -n "$text_samples_rem" ]; then
            echo -e "        ${PF_RED}- ${text_samples_rem}${PF_NC}"
        fi

        export PF_SUMMARY_TEXT_CHANGES PF_TEXT_DETAIL
        return 0
    fi
    return 1
}

# Compare les métadonnées entre deux révisions
# Usage: pf_diff_meta $rev_num $prev_num
# Returns: 0 si diff trouvé, 1 sinon
# Modifie: PF_SUMMARY_META_CHANGES
pf_diff_meta() {
    local rev="$1"
    local prev="$2"

    [ "$PF_HAS_EXIFTOOL" -eq 0 ] && { echo -e "      $T_META_EVOL $T_SKIPPED"; return 1; }

    local m_diff
    m_diff=$(diff -u "$PF_LAB_DIR/revisions/meta_${prev}.txt" "$PF_LAB_DIR/revisions/meta_${rev}.txt")

    if [ -n "$m_diff" ]; then
        PF_SUMMARY_META_CHANGES=$((PF_SUMMARY_META_CHANGES + 1))

        local meta_fields
        meta_fields=$(echo "$m_diff" | awk '/^[+-]/ && $0 !~ /^\+\+\+|^---/ {line=$0; sub(/^[+-][^]]*\]/, "", line); sub(/^[[:space:]]+/, "", line); split(line, parts, ":"); field=parts[1]; sub(/[[:space:]]+$/, "", field); if (field != "") print field;}' | sort -u | head -5 | paste -sd ", " -)

        # Afficher le résumé détaillé dans le terminal
        echo -e "      ${PF_YELLOW}$T_META_EVOL${PF_NC}"
        if [ -n "$meta_fields" ]; then
            echo -e "        ${PF_CYAN}Fields: $meta_fields${PF_NC}"
        fi
        # Afficher quelques exemples de changements
        local meta_samples
        meta_samples=$(echo "$m_diff" | grep -E "^[+-]" | grep -v "^[+-]{3}" | head -4)
        if [ -n "$meta_samples" ]; then
            while IFS= read -r sample_line; do
                if [[ "$sample_line" == +* ]]; then
                    echo -e "        ${PF_GREEN}${sample_line}${PF_NC}"
                elif [[ "$sample_line" == -* ]]; then
                    echo -e "        ${PF_RED}${sample_line}${PF_NC}"
                fi
            done <<< "$meta_samples"
        fi

        local sub_cls="subsection diff-section"
        local diff_line_count=0

        echo "<table class='$sub_cls'><tr><td><h4 class='subsection-title'>$T_META_EVOL</h4><div class='diff-box'><table class='diff-table'><tbody>" >> "$PF_REPORT"

        while read -r line; do
            if [[ $line == +* ]] && [[ $line != +++* ]]; then
                if [ $diff_line_count -gt 0 ] && [ $((diff_line_count % PF_DIFF_CHUNK_LINES)) -eq 0 ]; then
                    echo "</tbody></table></div></td></tr></table>" >> "$PF_REPORT"
                    echo "<table class='$sub_cls page-break'><tr><td><h4 class='subsection-title'>$T_META_EVOL $T_CONT</h4><div class='diff-box'><table class='diff-table'><tbody>" >> "$PF_REPORT"
                fi
                local content_esc
                content_esc=$(printf '%s' "${line#?}" | pf_html_escape)
                echo "<tr class='diff-add'><td>$content_esc</td></tr>" >> "$PF_REPORT"
                diff_line_count=$((diff_line_count + 1))
            elif [[ $line == -* ]] && [[ $line != ---* ]]; then
                if [ $diff_line_count -gt 0 ] && [ $((diff_line_count % PF_DIFF_CHUNK_LINES)) -eq 0 ]; then
                    echo "</tbody></table></div></td></tr></table>" >> "$PF_REPORT"
                    echo "<table class='$sub_cls page-break'><tr><td><h4 class='subsection-title'>$T_META_EVOL $T_CONT</h4><div class='diff-box'><table class='diff-table'><tbody>" >> "$PF_REPORT"
                fi
                local content_esc
                content_esc=$(printf '%s' "${line#?}" | pf_html_escape)
                echo "<tr class='diff-rem'><td>$content_esc</td></tr>" >> "$PF_REPORT"
                diff_line_count=$((diff_line_count + 1))
            fi
        done <<< "$m_diff"

        echo "</tbody></table></div></td></tr></table>" >> "$PF_REPORT"

        if [ -n "$meta_fields" ]; then
            PF_META_DETAIL="$T_CHANGE_META: $meta_fields"
        else
            PF_META_DETAIL="$T_CHANGE_META"
        fi

        export PF_SUMMARY_META_CHANGES PF_META_DETAIL
        return 0
    fi
    return 1
}

# Compare les polices entre deux révisions
# Usage: pf_diff_fonts $rev_num $prev_num
# Returns: 0 si diff trouvé, 1 sinon
# Modifie: PF_SUMMARY_FONT_CHANGES
pf_diff_fonts() {
    local rev="$1"
    local prev="$2"

    [ "$PF_HAS_PDFFONTS" -eq 0 ] && { echo -e "      $T_FONT_ALERT $T_SKIPPED"; return 1; }

    local f_diff
    f_diff=$(diff "$PF_LAB_DIR/revisions/fonts_${prev}.txt" "$PF_LAB_DIR/revisions/fonts_${rev}.txt")

    if [ -n "$f_diff" ]; then
        PF_SUMMARY_FONT_CHANGES=$((PF_SUMMARY_FONT_CHANGES + 1))

        local font_names
        font_names=$(echo "$f_diff" | awk '/^[<>] / {if ($2 != "name" && $2 != "Name") print $2;}' | sort -u | head -5 | paste -sd ", " -)

        # Afficher le résumé détaillé dans le terminal
        echo -e "      ${PF_PURPLE}$T_FONT_ALERT${PF_NC}"
        if [ -n "$font_names" ]; then
            echo -e "        ${PF_CYAN}Fonts: $font_names${PF_NC}"
        fi

        if [ -n "$font_names" ]; then
            PF_FONT_DETAIL="$T_CHANGE_FONTS: $font_names"
        else
            PF_FONT_DETAIL="$T_CHANGE_FONTS"
        fi

        local sub_cls="subsection"
        echo "<table class='$sub_cls'><tr><td><div class='alert-box'>$T_FONT_ALERT</div></td></tr></table>" >> "$PF_REPORT"

        export PF_SUMMARY_FONT_CHANGES PF_FONT_DETAIL
        return 0
    fi
    return 1
}
