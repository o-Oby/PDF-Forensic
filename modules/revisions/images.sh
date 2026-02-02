#!/bin/bash
# modules/revisions/images.sh - Extraction et OCR des images

# Extrait les images d'une révision
# Usage: pf_extract_images $rev_num
pf_extract_images() {
    local rev_num="$1"
    local rev_pdf="$PF_LAB_DIR/revisions/rev_${rev_num}.pdf"

    if [ "$PF_HAS_PDFIMAGES" -eq 1 ]; then
        mkdir -p "$PF_LAB_DIR/images/rev_${rev_num}"
        pdfimages -png -j "$rev_pdf" "$PF_LAB_DIR/images/rev_${rev_num}/img" 2>/dev/null
    fi
}

# Génère la galerie d'images pour une révision
# Usage: pf_generate_image_gallery $rev_num
pf_generate_image_gallery() {
    local rev_num="$1"

    if [ "$PF_HAS_PDFIMAGES" -eq 1 ]; then
        local images=( "$PF_LAB_DIR/images/rev_${rev_num}/"* )

        if [ -e "${images[0]}" ]; then
            local sub_cls="subsection"
            echo "<table class='$sub_cls'><tr><td><h4 class='subsection-title'>$T_IMG_GAL</h4><div class='grid-images'>" >> "$PF_REPORT"

            for img_path in "${images[@]}"; do
                local img img_esc img_exif="" ocr_text=""
                img=$(basename "$img_path")
                img_esc=$(printf '%s' "$img" | pf_html_escape)

                # Métadonnées EXIF des images
                if [ "$PF_HAS_EXIFTOOL" -eq 1 ]; then
                    img_exif=$(exiftool -G1 -a -s "$img_path" 2>/dev/null | grep -iE "Software|Make|Model|CreateDate|ModifyDate" || true)
                fi

                # OCR avec Tesseract
                if [ "$PF_HAS_TESSERACT" -eq 1 ]; then
                    tesseract "$img_path" "$PF_LAB_DIR/ocr/rev_${rev_num}_$img" --psm 6 &>/dev/null
                    ocr_text=$(cat "$PF_LAB_DIR/ocr/rev_${rev_num}_$img.txt" 2>/dev/null | xargs)
                fi

                echo "<div class='img-card'><strong>$img_esc</strong>" >> "$PF_REPORT"

                if [ -n "$ocr_text" ]; then
                    local ocr_text_esc
                    ocr_text_esc=$(printf '%s' "$ocr_text" | pf_html_escape)
                    echo "<p><strong>OCR:</strong> $ocr_text_esc</p>" >> "$PF_REPORT"
                fi

                if [ -n "$img_exif" ]; then
                    local img_exif_esc
                    img_exif_esc=$(printf '%s' "$img_exif" | pf_html_escape)
                    echo "<pre class='img-meta'>$img_exif_esc</pre>" >> "$PF_REPORT"
                fi

                echo "</div>" >> "$PF_REPORT"
            done

            echo "</div></td></tr></table>" >> "$PF_REPORT"
        fi
    else
        echo -e "    $T_IMG_GAL $T_SKIPPED"
    fi
}
