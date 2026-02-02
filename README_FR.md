# PDF Forensic

> **[Read in English](README.md)**

Outil d'analyse forensique de documents PDF. Détecte les modifications, révisions cachées, pièces jointes, scripts et anomalies structurelles.

## Fonctionnalites

- **Analyse des r&visions** : Détection de tous les etats de sauvegarde (%%EOF)
- **Comparaison de texte** : Diff entre chaque révision
- **Evolution des metadonnees** : Suivi des modifications CreationDate, ModifyDate, Producer, Creator
- **D&tection de polices** : Alertes si les polices changent entre révisions
- **Pièces jointes** : Extraction et listage des fichiers embarqués
- **Scripts/Actions** : Détection de JavaScript, OpenAction, AA
- **Texte invisible** : Détection du mode de rendu 3 (texte cache)
- **Signatures logicielles** : Détection UPDF, Adobe, Nitro, Foxit, etc.
- **OCR** : Extraction de texte depuis les images (Tesseract)
- **Bordures** : Vérification MediaBox vs CropBox (texte hors marges)
- **Rapport HTML** : Rapport interactif avec bouton d'impression/export PDF

## Installation

### Dépendances requises

```bash
# macOS (Homebrew)
brew install exiftool poppler qpdf tesseract

# Ubuntu/Debian
sudo apt install libimage-exiftool-perl poppler-utils qpdf tesseract-ocr

# Fedora
sudo dnf install perl-Image-ExifTool poppler-utils qpdf tesseract
```

## Utilisation

```bash
# Mode interactif (choisir la langue)
./pdf-forensic.sh document.pdf

# Anglais
./pdf-forensic.sh document.pdf --en

# Francais
./pdf-forensic.sh document.pdf --fr
```

### Options

| Option | Description |
|--------|-------------|
| `--en` | Langue anglaise |
| `--fr` | Langue francaise |
| `-h, --help` | Afficher l'aide |

### Export PDF

Le rapport HTML génere inclut un bouton "Imprimer / PDF". Cliquez dessus pour :
- Imprimer le rapport directement
- Sauvegarder en PDF (selectionnez "Enregistrer au format PDF" dans la boite de dialogue d'impression)

## Structure du projet

```
PDF-Forensic/
├── pdf-forensic.sh          # Script principal (orchestrateur)
├── lib/
│   ├── core/
│   │   ├── constants.sh     # Couleurs, versions
│   │   ├── utils.sh         # Fonctions utilitaires
│   │   └── state.sh         # Variables partagées
│   ├── i18n/
│   │   ├── loader.sh        # Chargeur de langue
│   │   ├── fr.sh            # Traductions FR
│   │   └── en.sh            # Traductions EN
│   ├── cli/
│   │   ├── parser.sh        # Parsing arguments
│   │   └── prompts.sh       # Prompts interactifs
│   └── deps/
│       └── checker.sh       # Vérification dependances
└── modules/
    ├── analysis/
    │   ├── structural.sh    # Analyse DNA (EOF, objets)
    │   ├── boundaries.sh    # MediaBox/CropBox
    │   ├── attachments.sh   # Pièces jointes
    │   ├── javascript.sh    # Détection JS/Actions
    │   └── markers.sh       # Signatures, texte invisible
    ├── revisions/
    │   ├── extractor.sh     # Extraction révisions
    │   ├── differ.sh        # Diff text/meta/fonts
    │   └── images.sh        # Images + OCR
    └── report/
        ├── html/
        │   ├── template.sh  # CSS + header HTML
        │   ├── sections.sh  # Generateurs sections
        │   └── summary.sh   # Résumé
        └── export/
            └── cleanup.sh   # Nettoyage
```

## Rapport genere

Le rapport contient :

1. **Résume** : Tableau recapitulatif de toutes les modifications
2. **Integrité** : Hash SHA-256, nombre de révisions
3. **Analyse DNA** : Objets PDF, détection de sauts d'index suspects
4. **Chronologie des revisions** : Diff détaillée pour chaque révision
5. **Galerie d'images** : Images extraites avec OCR et metadonnées EXIF
6. **Signatures logicielles** : Outils utilisés pour créer/modifier le PDF

## Exemple de sortie terminal

```
╔══════════════════════════════════════════════════════════════╗
║                   PDF FORENSIC LABORATORY                     ║
║                         Version 1.0                           ║
╚══════════════════════════════════════════════════════════════╝

┌─ Fichier ─────────────────────────────────────────────────────┐
│  document.pdf                                                 │
│  SHA-256: b710553de8199997bac8d40c4bbf50688ee10c5eb7e13d...  │
│  Revisions: 3 | Objets: 48                                    │
└───────────────────────────────────────────────────────────────┘

:: Integrity Status
    - SHA-256 Fingerprint : b710553de...
    - Save states detected : 3

:: Deep Revision Processing...
    Processing Rev 1 [SHA: 813c1345...]
    Processing Rev 2 [SHA: 3dd0b69d...]
      Comparing vs Rev 1...
      (!) Text Content Altered : +15 / -3 lines
          + Ligne ajoutee exemple
          - Ligne supprimee exemple
      Metadata Evolution : ModDate, Producer
```

## Ajouter une langue

1. Créer `lib/i18n/de.sh` (copier `en.sh` comme base)
2. Renommer la fonction en `pf_init_translations_de`
3. Traduire toutes les variables `T_*`
4. Ajouter le cas dans `lib/i18n/loader.sh`

## Licence

MIT License

## Auteur

Médéric D.
PDF Forensic - Outil d'investigation numérique
