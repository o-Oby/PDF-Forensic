#!/bin/bash
# modules/report/html/template.sh - Template HTML/CSS du rapport

# Génère le CSS du rapport
# Usage: _pf_generate_css
_pf_generate_css() {
    cat <<'CSSEOF'
        :root { --text: #111; --muted: #555; --border: #bdbdbd; --soft: #f4f4f4; --soft2: #fafafa; --accent: #1a5f2a; --warn: #b00020; --ok: #0b6; }
        body { font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif; font-size: 11pt; background: #f8f9fa; color: var(--text); margin: 0; padding: 20px; line-height: 1.5; }
        .container { max-width: 1000px; margin: 0 auto; background: #fff; padding: 0; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; }

        /* Header stylisé */
        .main-header { background: linear-gradient(135deg, #1a5f2a 0%, #2d8f47 100%); color: #fff; padding: 30px 40px; text-align: center; }
        .main-header h1 { margin: 0 0 8px 0; font-size: 28pt; font-weight: 700; letter-spacing: 2px; border: none; padding: 0; color: #fff; }
        .main-header .version { font-size: 12pt; opacity: 0.9; margin-bottom: 20px; }
        .file-info-box { background: rgba(255,255,255,0.1); border-radius: 6px; padding: 15px 20px; margin-top: 15px; text-align: left; }
        .file-info-box .file-row { display: flex; margin: 6px 0; font-size: 10pt; }
        .file-info-box .file-label { width: 80px; opacity: 0.8; font-weight: 500; }
        .file-info-box .file-value { font-family: "Courier New", monospace; word-break: break-all; }

        .content { padding: 24px 40px 40px; }
        h3 { margin: 0 0 6px; }
        .report-meta { display: flex; justify-content: space-between; padding: 12px 40px; background: #f8f9fa; border-bottom: 1px solid var(--border); font-size: 10pt; color: var(--muted); }

        .header-info { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; margin: 20px 0; }
        .info-card { background: var(--soft2); border: 1px solid var(--border); border-radius: 6px; padding: 12px 16px; }
        .info-card h4 { margin: 0 0 4px; font-size: 9pt; text-transform: uppercase; color: var(--muted); font-weight: 600; letter-spacing: 0.5px; }
        .info-card p { margin: 0; font-family: "Courier New", monospace; font-size: 10pt; word-break: break-all; }

        .section-title { background: var(--accent); color: #fff; padding: 10px 16px; border-radius: 4px; margin: 28px 0 14px; font-size: 12pt; font-weight: 600; }
        .summary-box { border: 1px solid var(--border); border-radius: 6px; padding: 16px; background: var(--soft2); }
        .summary-table { width: 100%; border-collapse: collapse; font-size: 10pt; margin-top: 12px; }
        .summary-table th { background: var(--soft); font-weight: 600; }
        .summary-table th, .summary-table td { border: 1px solid var(--border); padding: 8px 10px; text-align: left; vertical-align: top; }

        .revision { border: 1px solid var(--border); border-radius: 6px; padding: 16px; margin-bottom: 16px; background: #fff; }
        .rev-head { margin-bottom: 12px; padding-bottom: 10px; border-bottom: 1px solid #eee; }
        .rev-head h3 { color: var(--accent); }
        .subsection { width: 100%; border-collapse: collapse; margin: 10px 0 14px; }
        .subsection td { padding: 0; }
        .subsection-title { margin: 0 0 8px; font-size: 11pt; font-weight: 600; }
        .alert-box { background: #fff5f5; border: 1px solid #f5c6cb; color: #721c24; padding: 10px 14px; margin: 10px 0; font-weight: 600; border-radius: 4px; }
        .diff-box { background: #f8f9fa; color: #000; padding: 10px; border: 1px solid #dee2e6; border-radius: 4px; margin: 8px 0; white-space: pre-wrap; font-family: "Courier New", monospace; font-size: 9pt; word-break: break-word; overflow-wrap: break-word; max-width: 100%; overflow-x: hidden; }
        .diff-table { width: 100%; border-collapse: collapse; font-family: "Courier New", monospace; font-size: 9pt; table-layout: fixed; }
        .diff-table td { padding: 3px 6px; border-bottom: 1px solid #eee; white-space: pre-wrap; word-break: break-word; overflow-wrap: break-word; }
        .diff-table tr { page-break-inside: avoid; break-inside: avoid; }
        .diff-add { color: #28a745; background: #f0fff4; }
        .diff-rem { color: #dc3545; background: #fff5f5; }
        .grid-images { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 14px; }
        .img-card { border: 1px solid var(--border); border-radius: 6px; padding: 10px; background: #fff; overflow: hidden; }
        .img-card img { width: 100%; border-radius: 4px; margin-bottom: 8px; }
        .img-meta { font-size: 0.65em; white-space: pre-wrap; word-break: break-word; overflow-wrap: break-word; margin: 6px 0 0; padding: 6px; background: #f8f9fa; border-radius: 3px; max-width: 100%; overflow: hidden; }
        .page-break { page-break-before: always; break-before: page; }

        /* Bouton d'impression */
        .print-btn { position: fixed; top: 20px; right: 20px; background: var(--accent); color: #fff; border: none; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 11pt; font-weight: 600; box-shadow: 0 2px 8px rgba(0,0,0,0.2); z-index: 1000; display: flex; align-items: center; gap: 8px; transition: background 0.2s; }
        .print-btn:hover { background: #145a24; }
        .print-btn svg { width: 18px; height: 18px; fill: currentColor; }

        /* Mode PDF (appliqué via JS pour html2pdf) */
        body.pdf-mode { background: #fff; padding: 0; font-size: 10pt; line-height: 1.4; }
        body.pdf-mode .print-btn { display: none; }
        body.pdf-mode .container { width: 100%; max-width: 100%; box-shadow: none; border-radius: 0; overflow: visible; }
        body.pdf-mode .content { padding: 16px 24px 24px; }
        body.pdf-mode .main-header { background: #fff; color: #111; border-bottom: 2px solid #1a5f2a; }
        body.pdf-mode .main-header h1 { color: #1a5f2a; font-size: 22pt; }
        body.pdf-mode .main-header .version { color: #555; opacity: 1; }
        body.pdf-mode .file-info-box { background: #f8f9fa; border: 1px solid #ddd; }
        body.pdf-mode .file-info-box .file-label { color: #555; opacity: 1; }
        body.pdf-mode .file-info-box .file-value { color: #111; }
        body.pdf-mode .section-title { background: #f4f4f4; color: #1a5f2a; border-left: 4px solid #1a5f2a; border-radius: 0; margin-top: 20px; }
        body.pdf-mode .rev-head h3 { color: #333; }
        /* Éviter les coupures et fermer les bordures */
        body.pdf-mode .summary-box { page-break-inside: avoid; box-decoration-break: clone; -webkit-box-decoration-break: clone; }
        body.pdf-mode .revision { page-break-inside: auto; margin-bottom: 15px; box-decoration-break: clone; -webkit-box-decoration-break: clone; border: 1px solid var(--border); }
        body.pdf-mode .revision:first-of-type { page-break-inside: avoid; }
        body.pdf-mode .rev-head { page-break-after: avoid; }
        body.pdf-mode .rev-head + * { page-break-before: avoid; }
        body.pdf-mode .alert-box { page-break-inside: avoid; box-decoration-break: clone; -webkit-box-decoration-break: clone; }
        body.pdf-mode .img-card { page-break-inside: avoid; }
        body.pdf-mode .subsection { box-decoration-break: clone; -webkit-box-decoration-break: clone; }
        body.pdf-mode .subsection-title { page-break-after: avoid; }
        body.pdf-mode .subsection-title + * { page-break-before: avoid; }
        body.pdf-mode .section-title { page-break-after: avoid; }
        body.pdf-mode .section-title + * { page-break-before: avoid; }
        body.pdf-mode .diff-box { box-decoration-break: clone; -webkit-box-decoration-break: clone; padding: 8px; font-size: 8pt; }
        body.pdf-mode .diff-table { box-decoration-break: clone; -webkit-box-decoration-break: clone; font-size: 8pt; }
        body.pdf-mode .diff-table td { padding: 2px 4px; }
        body.pdf-mode .diff-table tr { page-break-inside: avoid; }
        body.pdf-mode .summary-table { font-size: 9pt; }
        body.pdf-mode .summary-table th, body.pdf-mode .summary-table td { padding: 6px 8px; }
        body.pdf-mode .main-header { padding: 20px 24px; }
        body.pdf-mode .main-header h1 { font-size: 22pt; }
        body.pdf-mode .report-meta { padding: 8px 24px; font-size: 9pt; }
        body.pdf-mode .info-card { padding: 10px 12px; }
        body.pdf-mode .info-card p { font-size: 9pt; }
        body.pdf-mode .grid-images { gap: 10px; }

        @media print {
            * { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            @page { margin: 12mm 10mm 18mm 10mm; @bottom-center { content: "Page " counter(page) " / " counter(pages); font-size: 9pt; color: #555; } }
            body { background: #fff; padding: 0; font-size: 9pt; line-height: 1.4; }
            .container { width: 100%; max-width: 100%; box-shadow: none; border-radius: 0; overflow: visible; }
            .content { padding: 16px 24px 24px; }
            .main-header { background: #fff !important; color: #111 !important; padding: 20px 24px; border-bottom: 2px solid #1a5f2a; }
            .main-header h1 { color: #1a5f2a !important; font-size: 22pt; }
            .main-header .version { color: #555 !important; opacity: 1; }
            .file-info-box { background: #f8f9fa !important; border: 1px solid #ddd; }
            .file-info-box .file-label { color: #555 !important; opacity: 1; }
            .file-info-box .file-value { color: #111 !important; }
            .report-meta { padding: 8px 24px; font-size: 9pt; }
            /* Styles simplifiés - laisser Chrome gérer les coupures */
            .section-title { background: #f4f4f4 !important; color: #1a5f2a !important; border-left: 4px solid #1a5f2a; border-radius: 0; margin: 16px 0 10px; padding: 8px 12px; font-size: 11pt; }
            .revision { margin-bottom: 10px; padding: 12px; box-decoration-break: clone; -webkit-box-decoration-break: clone; }
            .rev-head { margin-bottom: 8px; padding-bottom: 6px; }
            .rev-head h3 { color: #333 !important; }
            .subsection { margin: 6px 0 10px; box-decoration-break: clone; -webkit-box-decoration-break: clone; }
            .subsection-title { font-size: 10pt; margin-bottom: 6px; }
            .diff-table { box-decoration-break: clone; -webkit-box-decoration-break: clone; font-size: 8pt; }
            .diff-table td { padding: 2px 4px; }
            .grid-images { gap: 10px; }
            .alert-box { page-break-inside: avoid; }
            .img-card { page-break-inside: avoid; padding: 8px; max-height: 200px; overflow: hidden; }
            .summary-table { font-size: 9pt; }
            .summary-table th, .summary-table td { padding: 6px 8px; }
            .diff-box, .diff-table td, pre, code, .img-meta { word-break: break-all; overflow-wrap: break-word; white-space: pre-wrap; max-width: 100%; }
            .diff-box { padding: 8px; margin: 6px 0; font-size: 8pt; box-decoration-break: clone; -webkit-box-decoration-break: clone; }
            .no-print, .print-btn { display: none; }
        }
CSSEOF
}

# Initialise le rapport HTML
# Usage: pf_init_report
pf_init_report() {
    local l_code file_esc global_hash_esc revisions_esc objects_esc report_date_esc app_version_esc

    l_code=$(echo "$PF_LANG" | tr '[:upper:]' '[:lower:]')
    file_esc=$(printf '%s' "$PF_FILE" | pf_html_escape)
    global_hash_esc=$(printf '%s' "$PF_GLOBAL_HASH" | pf_html_escape)
    revisions_esc=$(printf '%s' "$PF_REVISIONS" | pf_html_escape)
    objects_esc=$(printf '%s' "$PF_OBJECTS" | pf_html_escape)
    report_date_esc=$(printf '%s' "$PF_REPORT_DATE" | pf_html_escape)
    app_version_esc=$(printf '%s' "$PF_APP_VERSION" | pf_html_escape)

    cat <<EOF > "$PF_REPORT"
<!DOCTYPE html>
<html lang="$l_code">
<head>
    <meta charset="UTF-8">
    <title>$T_LAB - $file_esc</title>
    <style>
$(_pf_generate_css)
    </style>
</head>
<body>
    <button class="print-btn" onclick="window.print()">
        <svg viewBox="0 0 24 24"><path d="M19 8H5c-1.66 0-3 1.34-3 3v6h4v4h12v-4h4v-6c0-1.66-1.34-3-3-3zm-3 11H8v-5h8v5zm3-7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm-1-9H6v4h12V3z"/></svg>
        $T_PRINT_PDF
    </button>
    <div class="container">
        <div class="main-header">
            <h1>$T_LAB</h1>
            <div class="version">Version $app_version_esc</div>
            <div class="file-info-box">
                <div class="file-row"><span class="file-label">$T_FILE:</span><span class="file-value">$file_esc</span></div>
                <div class="file-row"><span class="file-label">SHA-256:</span><span class="file-value">$global_hash_esc</span></div>
                <div class="file-row"><span class="file-label">Output:</span><span class="file-value">$PF_LAB_DIR/</span></div>
            </div>
        </div>
        <div class="report-meta">
            <span>$T_REPORT_DATE: $report_date_esc</span>
            <span>$T_REVISIONS: $revisions_esc | $T_OBJ_TOTAL: $objects_esc</span>
        </div>
        <div class="content">
        __SUMMARY_PLACEHOLDER__
EOF
}

# Écrit l'en-tête d'une section de révision
# Usage: pf_write_revision_header $rev_num $rev_hash
pf_write_revision_header() {
    local rev_num="$1"
    local rev_hash="$2"

    echo "<div class='revision'><div class='rev-head'><h3>Revision $rev_num</h3><p>SHA-256: <code>$rev_hash</code></p></div>" >> "$PF_REPORT"
}

# Ferme une section de révision
# Usage: pf_close_revision
pf_close_revision() {
    echo "</div>" >> "$PF_REPORT"
}

# Écrit le titre de la section révisions
# Usage: pf_write_revisions_section_title
pf_write_revisions_section_title() {
    echo "<div class='section-title'>$T_REV_TITLE</div>" >> "$PF_REPORT"
}
