# PDF Forensic 

> **[Lire en Français](README_FR.md)**

PDF forensic analysis tool. Detects modifications, hidden revisions, attachments, scripts and structural anomalies.

## Features

- **Revision analysis**: Detection of all save states (%%EOF)
- **Text comparison**: Diff between each revision
- **Metadata evolution**: Track changes to CreationDate, ModifyDate, Producer, Creator
- **Font detection**: Alerts when fonts change between revisions
- **Attachments**: Extraction and listing of embedded files
- **Scripts/Actions**: Detection of JavaScript, OpenAction, AA
- **Invisible text**: Detection of render mode 3 (hidden text)
- **Software signatures**: Detection of UPDF, Adobe, Nitro, Foxit, etc.
- **OCR**: Text extraction from images (Tesseract)
- **Boundaries**: MediaBox vs CropBox verification (text outside margins)
- **HTML Report**: Interactive report with print/PDF export button

## Installation

### Required dependencies

```bash
# macOS (Homebrew)
brew install exiftool poppler qpdf tesseract

# Ubuntu/Debian
sudo apt install libimage-exiftool-perl poppler-utils qpdf tesseract-ocr

# Fedora
sudo dnf install perl-Image-ExifTool poppler-utils qpdf tesseract
```

## Usage

```bash
# Interactive mode (choose language)
./pdf-forensic.sh document.pdf

# English
./pdf-forensic.sh document.pdf --en

# French
./pdf-forensic.sh document.pdf --fr
```

### Options

| Option | Description |
|--------|-------------|
| `--en` | English language |
| `--fr` | French language |
| `-h, --help` | Show help |

### PDF Export

The generated HTML report includes a "Print / PDF" button. Click it to:
- Print the report directly
- Save as PDF (select "Save as PDF" in the print dialog)

## Project structure

```
PDF-Forensic/
├── pdf-forensic.sh          # Main script (orchestrator)
├── lib/
│   ├── core/
│   │   ├── constants.sh     # Colors, versions
│   │   ├── utils.sh         # Utility functions
│   │   └── state.sh         # Shared variables
│   ├── i18n/
│   │   ├── loader.sh        # Language loader
│   │   ├── fr.sh            # French translations
│   │   └── en.sh            # English translations
│   ├── cli/
│   │   ├── parser.sh        # Argument parsing
│   │   └── prompts.sh       # Interactive prompts
│   └── deps/
│       └── checker.sh       # Dependency checking
└── modules/
    ├── analysis/
    │   ├── structural.sh    # DNA analysis (EOF, objects)
    │   ├── boundaries.sh    # MediaBox/CropBox
    │   ├── attachments.sh   # Attachments
    │   ├── javascript.sh    # JS/Actions detection
    │   └── markers.sh       # Signatures, invisible text
    ├── revisions/
    │   ├── extractor.sh     # Revision extraction
    │   ├── differ.sh        # Diff text/meta/fonts
    │   └── images.sh        # Images + OCR
    └── report/
        ├── html/
        │   ├── template.sh  # CSS + HTML header
        │   ├── sections.sh  # Section generators
        │   └── summary.sh   # Summary
        └── export/
            └── cleanup.sh   # Cleanup
```

## Generated report

The report contains:

1. **Summary**: Overview table of all modifications
2. **Integrity**: SHA-256 hash, number of revisions
3. **DNA Analysis**: PDF objects, detection of suspicious index jumps
4. **Revision timeline**: Detailed diff for each revision
5. **Image gallery**: Extracted images with OCR and EXIF metadata
6. **Software signatures**: Tools used to create/modify the PDF

## Terminal output example

```
╔══════════════════════════════════════════════════════════════╗
║                         PDF FORENSIC                         ║
║                         Version 1.0                          ║
╚══════════════════════════════════════════════════════════════╝

┌─ File ────────────────────────────────────────────────────────┐
│  document.pdf                                                 │
│  SHA-256: b710553de8199997bac8d40c4bbf50688ee10c5eb7e13d...   │
│  Revisions: 3 | Objects: 48                                   │
└───────────────────────────────────────────────────────────────┘

:: Integrity Status
    - SHA-256 Fingerprint : b710553de...
    - Save states detected : 3

:: Deep Revision Processing...
    Processing Rev 1 [SHA: 813c1345...]
    Processing Rev 2 [SHA: 3dd0b69d...]
      Comparing vs Rev 1...
      (!) Text Content Altered : +15 / -3 lines
          + Added line example
          - Removed line example
      Metadata Evolution : ModDate, Producer
```

## Adding a language

1. Create `lib/i18n/de.sh` (copy `en.sh` as base)
2. Rename the function to `pf_init_translations_de`
3. Translate all `T_*` variables
4. Add the case in `lib/i18n/loader.sh`

## License

MIT License

## Author

PDF Forensic Laboratory - Digital forensics tool
