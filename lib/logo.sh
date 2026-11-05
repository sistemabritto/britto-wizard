# Logo do Sistema Britto em ASCII: escudo SB (metal, aro verde, S prata, B verde) + SISTEMA BRITTO.
# Cores 256 (fallback: terminais sem 256 cores mostram a cor mais próxima).
c_metal='\e[38;5;242m'; c_brilho='\e[38;5;250m'; c_verde='\e[38;5;76m'; c_verde2='\e[38;5;118m'; c_prata='\e[38;5;254m'
logo() {
  echo -e "    ${c_brilho}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ${reset}"
  echo -e "  ${c_metal}▄█${c_brilho}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀${c_metal}█▄   ${c_verde}S  I  S  T  E  M  A${reset}"
  echo -e "  ${c_metal}██ ${c_verde}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ${c_metal}██   ${branco}██████╗  ██████╗  ██╗ ████████╗ ████████╗  ██████╗ ${reset}"
  echo -e "  ${c_metal}██ ${c_verde}█ ${c_prata}▄▀▀▀▀ ${c_verde2}█▀▀▀▄ ${c_verde}█ ${c_metal}██   ${branco}██╔══██╗ ██╔══██╗ ██║ ╚══██╔══╝ ╚══██╔══╝ ██╔═══██╗${reset}"
  echo -e "  ${c_metal}██ ${c_verde}█ ${c_prata}▀▄▄▄  ${c_verde2}█▄▄▄▀ ${c_verde}█ ${c_metal}██   ${branco}██████╔╝ ██████╔╝ ██║    ██║       ██║    ██║   ██║${reset}"
  echo -e "  ${c_metal}██ ${c_verde}█     ${c_prata}█ ${c_verde2}█   █ ${c_verde}█ ${c_metal}██   ${branco}██╔══██╗ ██╔══██╗ ██║    ██║       ██║    ██║   ██║${reset}"
  echo -e "  ${c_metal}██ ${c_verde}█ ${c_prata}▀▄▄▄▀ ${c_verde2}█▄▄▄▀ ${c_verde}█ ${c_metal}██   ${branco}██████╔╝ ██║  ██║ ██║    ██║       ██║    ╚██████╔╝${reset}"
  echo -e "  ${c_metal}▀██ ${c_verde}▀▄         ▄▀ ${c_metal}██▀   ${branco}╚═════╝  ╚═╝  ╚═╝ ╚═╝    ╚═╝       ╚═╝     ╚═════╝ ${reset}"
  echo -e "   ${c_metal}▀██ ${c_verde}▀▄▄     ▄▄▀ ${c_metal}██▀ ${reset}"
  echo -e "     ${c_metal}▀██▄ ${c_verde}▀▀▄▀▀ ${c_metal}▄██▀      ${c_metal}CRMs de nicho · WhatsApp · IA · tráfego${reset}"
  echo -e "        ${c_brilho}▀▀▀▄▄▄▀▀▀      ${reset}"
}
