#!/bin/bash

DIR_aqui=$( pwd );
BETA_PATH=$(printf '%s\n' "$DIR_aqui" | sed 's/[\/&]/\\&/g');



echo "Esse script vai instalar em /usr/bin um script python \
esse script usará este diretório atual ( ${DIR_ARQUIVOS} )  \
como workspace, ou seja, na verdade só instalamos o atalho  \
 .desktop do gnome e esse script no /usr/bin;  ";
echo "Tambem usamos todos os pacotes do fortunes e eles serão instalados.";
    YOU=$( whoami );

colorecho() {
    color=$1;
    message=$2;
    # echo with colored escape codes
    case $color in
        "black") coding="\e[30m" ;;
        "red") coding="\e[31m" ;;
        "green") coding="\e[32m" ;;
        "yellow") coding="\e[33m" ;;
        "blue") coding="\e[34m" ;;
        "magenta") coding="\e[35m" ;;
        "cyan") coding="\e[36m" ;;
        "white") coding="\e[37m" ;;
        *) coding="\e[32m" ;;
    esac
    echo -e "${coding}${message} 🎵 𝄞\e[0m";
}

# Prompt the user for input
colorecho "red" "ESSE SCRIPT DEVE RODAR COMO SEU USUARIO NORMAL, POIS PRECISA DETERMINAR QUEM VOCÊ É *ANTES* DO SUDO";

read -rp "Do you want to continue? (yes/no): " response

# Check the response
if [[ $response == "yes" ]]; then
    colorecho "green" "You chose to continue.";
    sudo apt -y install fortunes*  swh-plugins lsp-plugins alsa-utils yt-dlp \
	autotalent python3-pexpect pulseaudio-utils pavumeter wmctrl guvcview python3-tk \
    python3-pyaudio python3-numpy sox ladspalist vocproc lv2file v4l-utils pandoc git;

    sudo cp -ra BETAKe.* /usr/bin/;
    colorecho "blue" "instale qualquer dependencia que faltar no python3, via pip";
    echo "CANTA RAUL -- vou instalar o yt-dlp do github pois os das distros sempre são podres!";

    git clone  https://github.com/yt-dlp/yt-dlp/ && cd yt-dlp && make && sudo make install;
    
    colorecho "yellow" "vou instalar o atalho .desktop na sua /home";
    echo "cp -ra BETAq.desktop ~/.local/share/applications/;"
    cp -ra BETAq.desktop /home/"${YOU}"/.local/share/applications/;
    colorecho "yellow" "vou instalar o script python em /usr/bin";
    sudo cp -ra BETAKe.py /usr/bin/;

    colorecho "magenta" "Vou adicionar o usuario ${YOU} ao grupo de execução em tempo real, considere instalar kernel low-latency.";
    sudo usermod -aG rtkit,audio "${YOU}";

    escaped_path=$(printf '%q' "${BETA_PATH}")
    sudo sed -i '3s|.*|betake_path = '\""$escaped_path"'/\"|' /usr/bin/BETAKe.py;
    sudo sed -i '3s|\\\/|\/|g' /usr/bin/BETAKe.py;

elif [[ $response == "no" ]]; then
    colorecho "white" "You chose to cancel.";
else
    colorecho "red" "Invalid response. Please enter 'yes' or 'no'.";
fi
