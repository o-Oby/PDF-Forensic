#!/bin/bash
# lib/deps/checker.sh - Vérification des dépendances

# Vérifie toutes les dépendances et configure les flags
# Usage: pf_check_dependencies
pf_check_dependencies() {
    PF_HAS_EXIFTOOL=0
    PF_HAS_PDFTOTEXT=0
    PF_HAS_QPDF=0
    PF_HAS_PDFINFO=0
    PF_HAS_PDFIMAGES=0
    PF_HAS_PDFFONTS=0
    PF_HAS_PDFDETACH=0
    PF_HAS_TESSERACT=0
    PF_HAS_STRINGS=0
    PF_HASH_CMD=""

    pf_have_cmd exiftool && PF_HAS_EXIFTOOL=1 || echo -e "${PF_YELLOW}Warning:${PF_NC} exiftool $T_DEP_MISSING"
    pf_have_cmd pdftotext && PF_HAS_PDFTOTEXT=1 || echo -e "${PF_YELLOW}Warning:${PF_NC} pdftotext $T_DEP_MISSING"
    pf_have_cmd qpdf && PF_HAS_QPDF=1 || echo -e "${PF_YELLOW}Warning:${PF_NC} qpdf $T_DEP_MISSING"
    pf_have_cmd pdfinfo && PF_HAS_PDFINFO=1 || echo -e "${PF_YELLOW}Warning:${PF_NC} pdfinfo $T_DEP_MISSING"
    pf_have_cmd pdfimages && PF_HAS_PDFIMAGES=1 || echo -e "${PF_YELLOW}Warning:${PF_NC} pdfimages $T_DEP_MISSING"
    pf_have_cmd pdffonts && PF_HAS_PDFFONTS=1 || echo -e "${PF_YELLOW}Warning:${PF_NC} pdffonts $T_DEP_MISSING"
    pf_have_cmd pdfdetach && PF_HAS_PDFDETACH=1 || echo -e "${PF_YELLOW}Warning:${PF_NC} pdfdetach $T_DEP_MISSING"
    pf_have_cmd tesseract && PF_HAS_TESSERACT=1 || echo -e "${PF_YELLOW}Warning:${PF_NC} tesseract $T_DEP_MISSING"
    pf_have_cmd strings && PF_HAS_STRINGS=1 || echo -e "${PF_YELLOW}Warning:${PF_NC} strings $T_DEP_MISSING"

    if pf_have_cmd shasum; then
        PF_HASH_CMD="shasum -a 256"
    elif pf_have_cmd sha256sum; then
        PF_HASH_CMD="sha256sum"
    else
        echo -e "${PF_YELLOW}Warning:${PF_NC} shasum/sha256sum $T_DEP_MISSING"
    fi

    export PF_HAS_EXIFTOOL PF_HAS_PDFTOTEXT PF_HAS_QPDF PF_HAS_PDFINFO
    export PF_HAS_PDFIMAGES PF_HAS_PDFFONTS PF_HAS_PDFDETACH PF_HAS_TESSERACT
    export PF_HAS_STRINGS PF_HASH_CMD
}

# Vérifie si une dépendance spécifique est disponible
# Usage: pf_require_dep "exiftool" && do_something
pf_require_dep() {
    local dep="$1"
    local var_name="PF_HAS_${dep^^}"
    local var_value="${!var_name}"

    if [ "$var_value" -eq 1 ]; then
        return 0
    else
        echo -e "    $T_SKIPPED"
        return 1
    fi
}
