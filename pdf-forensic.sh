#!/bin/bash
# =============================================================================
# PDF Forensic Laboratory - Modular Edition v2.0
# =============================================================================
# Analyse forensique de documents PDF avec détection de révisions,
# modifications de texte, métadonnées, polices, pièces jointes et scripts.
#
# Supports: FR / EN | Revisions, OCR, Exif, DNA, Boundaries, JS, Fonts, Attachments
# =============================================================================

set -euo pipefail

# === Déterminer le répertoire du script ===
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    PF_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    PF_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
export PF_SCRIPT_DIR

# =============================================================================
# Chargement des modules
# =============================================================================

# Core
source "$PF_SCRIPT_DIR/lib/core/constants.sh"
source "$PF_SCRIPT_DIR/lib/core/utils.sh"
source "$PF_SCRIPT_DIR/lib/core/state.sh"

# CLI
source "$PF_SCRIPT_DIR/lib/cli/parser.sh"
source "$PF_SCRIPT_DIR/lib/cli/prompts.sh"

# Dependencies
source "$PF_SCRIPT_DIR/lib/deps/checker.sh"

# I18n
source "$PF_SCRIPT_DIR/lib/i18n/loader.sh"

# Analysis modules
source "$PF_SCRIPT_DIR/modules/analysis/structural.sh"
source "$PF_SCRIPT_DIR/modules/analysis/boundaries.sh"
source "$PF_SCRIPT_DIR/modules/analysis/attachments.sh"
source "$PF_SCRIPT_DIR/modules/analysis/javascript.sh"
source "$PF_SCRIPT_DIR/modules/analysis/markers.sh"

# Revisions modules
source "$PF_SCRIPT_DIR/modules/revisions/extractor.sh"
source "$PF_SCRIPT_DIR/modules/revisions/differ.sh"
source "$PF_SCRIPT_DIR/modules/revisions/images.sh"

# Report modules
source "$PF_SCRIPT_DIR/modules/report/html/template.sh"
source "$PF_SCRIPT_DIR/modules/report/html/sections.sh"
source "$PF_SCRIPT_DIR/modules/report/html/summary.sh"
source "$PF_SCRIPT_DIR/modules/report/export/pdf.sh"
source "$PF_SCRIPT_DIR/modules/report/export/cleanup.sh"

# =============================================================================
# Main
# =============================================================================

main() {
    # 1. Parser les arguments
    pf_parse_args "$@"
    pf_validate_file

    # 2. Prompts interactifs (langue, format)
    pf_run_prompts

    # 3. Vérifier les dépendances
    pf_check_dependencies

    # 4. Initialiser le workspace
    pf_init_workspace

    # 5. Analyse structurale (avant l'en-tête pour avoir le hash)
    pf_analyze_structure "$PF_FILE"

    # 6. Afficher l'en-tête
    pf_print_header

    # 7. Afficher les résultats structuraux
    pf_print_structure_results

    # 7. Initialiser le rapport HTML
    pf_init_report

    # 8. Vérification des bordures
    pf_check_boundaries "$PF_FILE"

    # 9. Scan des pièces jointes
    pf_scan_attachments "$PF_FILE"

    # 10. Détection JavaScript
    pf_detect_javascript "$PF_FILE"

    # 11. Traitement des révisions
    pf_print_section "$T_REV_PROC"
    pf_write_revisions_section_title

    for i in "${!PF_EOF_OFFSETS[@]}"; do
        local rev_num=$((i + 1))

        # Extraire la révision
        pf_extract_revision "$i"
        pf_get_revision_metadata "$rev_num"

        # Écrire l'en-tête de révision dans le rapport
        pf_write_revision_header "$rev_num" "$PF_REV_HASH"

        # Variables pour cette révision
        local rev_changes="" rev_details=""

        # Comparer avec la révision précédente
        if [ "$rev_num" -gt 1 ]; then
            local prev=$i
            echo -e "      $T_COMPARE $prev..."

            # Diff texte
            PF_TEXT_DETAIL=""
            if pf_diff_text "$rev_num" "$prev"; then
                [ -z "$rev_changes" ] && rev_changes="$T_CHANGE_TEXT" || rev_changes="$rev_changes, $T_CHANGE_TEXT"
                [ -n "$PF_TEXT_DETAIL" ] && { [ -z "$rev_details" ] && rev_details="$PF_TEXT_DETAIL" || rev_details="$rev_details | $PF_TEXT_DETAIL"; }
            fi

            # Diff métadonnées
            PF_META_DETAIL=""
            if pf_diff_meta "$rev_num" "$prev"; then
                [ -z "$rev_changes" ] && rev_changes="$T_CHANGE_META" || rev_changes="$rev_changes, $T_CHANGE_META"
                [ -n "$PF_META_DETAIL" ] && { [ -z "$rev_details" ] && rev_details="$PF_META_DETAIL" || rev_details="$rev_details | $PF_META_DETAIL"; }
            fi

            # Diff polices
            PF_FONT_DETAIL=""
            if pf_diff_fonts "$rev_num" "$prev"; then
                [ -z "$rev_changes" ] && rev_changes="$T_CHANGE_FONTS" || rev_changes="$rev_changes, $T_CHANGE_FONTS"
                [ -n "$PF_FONT_DETAIL" ] && { [ -z "$rev_details" ] && rev_details="$PF_FONT_DETAIL" || rev_details="$rev_details | $PF_FONT_DETAIL"; }
            fi
        fi

        # Extraire et afficher les images
        pf_extract_images "$rev_num"
        pf_generate_image_gallery "$rev_num"

        # Valeurs par défaut
        [ -z "$rev_changes" ] && { [ "$rev_num" -eq 1 ] && rev_changes="$T_INITIAL_REV" || rev_changes="$T_NO_CHANGE"; }
        [ -z "$rev_details" ] && { [ "$rev_num" -eq 1 ] && rev_details="$T_INITIAL_REV" || rev_details="$T_NO_CHANGE"; }

        # Date de la révision
        local rev_date="$PF_REV_MODIFY_DATE"
        [ "$rev_date" == "$T_NA" ] || [ -z "$rev_date" ] && rev_date="$PF_REV_CREATE_DATE"
        [ -z "$rev_date" ] && rev_date="$T_NA"

        # Ajouter au résumé
        pf_add_summary_row "$rev_num" "$rev_date" "$rev_changes" "$rev_details" "$PF_REV_SOFTWARE"

        # Fermer la section de révision
        pf_close_revision
    done

    # 12. Scan des marqueurs globaux
    pf_scan_markers "$PF_FILE"

    # 13. Injecter le résumé
    pf_inject_summary

    # 14. Finaliser le HTML
    pf_finalize_html

    # 15. Log des signatures
    pf_print_signature_log "$PF_FILE"

    # 16. Afficher la fin
    pf_print_completion

    # 17. Export PDF si demandé
    pf_export_pdf

    # 18. Afficher les résultats
    pf_print_report_results

    # 19. Nettoyage
    pf_cleanup
}

# Exécuter le main
main "$@"
