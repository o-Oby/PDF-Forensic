#!/bin/bash
# lib/core/state.sh - Variables d'état partagées

# === Fichier en cours d'analyse ===
export PF_FILE=""
export PF_LANG=""
export PF_LANG_SET=0
export PF_OUTPUT_MODE=""
export PF_OUTPUT_SET=0

# === Flags de sortie ===
export PF_WANT_HTML_OUTPUT=1

# === Workspace ===
# PF_SCRIPT_DIR est défini par le script principal, ne pas réinitialiser
export PF_LAB_DIR=""
export PF_REPORT=""
export PF_TIMESTAMP=""
export PF_REPORT_DATE=""

# === Flags de dépendances ===
export PF_HAS_EXIFTOOL=0
export PF_HAS_PDFTOTEXT=0
export PF_HAS_QPDF=0
export PF_HAS_PDFINFO=0
export PF_HAS_PDFIMAGES=0
export PF_HAS_PDFFONTS=0
export PF_HAS_PDFDETACH=0
export PF_HAS_TESSERACT=0
export PF_HAS_STRINGS=0
export PF_HASH_CMD=""

# === Données d'analyse structurale ===
export PF_EOF_OFFSETS=()
export PF_REVISIONS=0
export PF_GLOBAL_HASH=""
export PF_OBJECTS=0
export PF_MAX_OBJ=0

# === Données de révision courante ===
export PF_REV_HASH=""
export PF_REV_CREATE_DATE=""
export PF_REV_MODIFY_DATE=""
export PF_REV_SOFTWARE=""
export PF_REV_PLATFORM=""

# === Accumulateurs de résultats ===
export PF_SUMMARY_TEXT_CHANGES=0
export PF_SUMMARY_META_CHANGES=0
export PF_SUMMARY_FONT_CHANGES=0
export PF_SUMMARY_ATTACHMENTS=0
export PF_SUMMARY_ATTACH_NAMES=""
export PF_SUMMARY_JS_COUNT=0
export PF_SUMMARY_JS_NAMES=""
export PF_SUMMARY_GHOST=0
export PF_SUMMARY_MARKERS=""
export PF_SUMMARY_ROWS=""

# === Détails de diff par révision ===
export PF_TEXT_DETAIL=""
export PF_META_DETAIL=""
export PF_FONT_DETAIL=""

# Génère la date formatée selon la langue
# Usage: _pf_format_date
_pf_format_date() {
    local day month year hour min sec tz
    day=$(date +%d | sed 's/^0//')
    year=$(date +%Y)
    hour=$(date +%H)
    min=$(date +%M)
    sec=$(date +%S)
    tz=$(date +%Z)

    if [ "$PF_LANG" == "FR" ]; then
        case $(date +%m) in
            01) month="janvier" ;; 02) month="février" ;; 03) month="mars" ;;
            04) month="avril" ;; 05) month="mai" ;; 06) month="juin" ;;
            07) month="juillet" ;; 08) month="août" ;; 09) month="septembre" ;;
            10) month="octobre" ;; 11) month="novembre" ;; 12) month="décembre" ;;
        esac
        echo "$day $month $year à $hour:$min:$sec $tz"
    else
        case $(date +%m) in
            01) month="January" ;; 02) month="February" ;; 03) month="March" ;;
            04) month="April" ;; 05) month="May" ;; 06) month="June" ;;
            07) month="July" ;; 08) month="August" ;; 09) month="September" ;;
            10) month="October" ;; 11) month="November" ;; 12) month="December" ;;
        esac
        echo "$month $day, $year at $hour:$min:$sec $tz"
    fi
}

# Initialise le workspace
# Usage: pf_init_workspace
pf_init_workspace() {
    PF_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    PF_REPORT_DATE=$(_pf_format_date)
    PF_LAB_DIR="lab_forensic_${PF_TIMESTAMP}"
    PF_REPORT="$PF_LAB_DIR/report_forensic.html"

    mkdir -p "$PF_LAB_DIR/revisions" "$PF_LAB_DIR/images" "$PF_LAB_DIR/attachments" "$PF_LAB_DIR/ocr"

    export PF_TIMESTAMP PF_REPORT_DATE PF_LAB_DIR PF_REPORT
}

# Réinitialise les accumulateurs de résumé
# Usage: pf_reset_summary
pf_reset_summary() {
    PF_SUMMARY_TEXT_CHANGES=0
    PF_SUMMARY_META_CHANGES=0
    PF_SUMMARY_FONT_CHANGES=0
    PF_SUMMARY_ATTACHMENTS=0
    PF_SUMMARY_ATTACH_NAMES=""
    PF_SUMMARY_JS_COUNT=0
    PF_SUMMARY_JS_NAMES=""
    PF_SUMMARY_GHOST=0
    PF_SUMMARY_MARKERS=""
    PF_SUMMARY_ROWS=""
}
