#!/bin/bash
# modules/report/html/sections.sh - Générateurs de sections HTML

# Finalise le rapport HTML
# Usage: pf_finalize_html
pf_finalize_html() {
    cat <<EOF >> "$PF_REPORT"
        </div>
    </div>
</body>
</html>
EOF
}

# Affiche la fin de l'investigation
# Usage: pf_print_completion
pf_print_completion() {
    echo -e "\n${PF_GREEN}====================================================${PF_NC}"
    echo -e "${PF_GREEN} $T_COMPLETE ${PF_NC}"
}

# Affiche les résultats des rapports
# Usage: pf_print_report_results
pf_print_report_results() {
    echo -e " $T_REPORT_READY : ${PF_YELLOW}$PF_REPORT${PF_NC}"
    echo -e "${PF_GREEN}====================================================${PF_NC}"
}
