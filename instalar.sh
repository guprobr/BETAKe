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
if [ "$YOU" == "root" ]; then
    read -rp "What is the user to install? " YOU
fi
read -rp "Do you want to continue for user ( $YOU ) ? (yes/no): " response
# Check the response
if [[ $response == "yes" ]]; then
    colorecho "green" "You chose to continue.";
    sudo apt install fortunes alsa-utils expect dialog zenity yad \
	python3-pexpect pulseaudio-utils wmctrl  \
    python3-tk python3-numpy python3-psutil python3-pyaudio python3-matplotlib xterm \
    sox x42-plugins swh-lv2 lv2file v4l-utils git ffmpeg;

    sudo cp -ra BETAKe.* /usr/bin/;
    colorecho "blue" "PS: instale qualquer dependencia que porventura faltar do python3";
    echo "CANTA RAUL -- vou instalar o yt-dlp do github pois os das distros sempre são podres!";

    colorecho "blue" "Vou obter o yt-dlp do github"
    git clone  https://github.com/yt-dlp/yt-dlp/ && cd yt-dlp && make && sudo make install;
    
    #colorecho "green" "Vou instalar o incrivel Graillon versao FREE plugin LV2 para vocal enhancement";
    #sudo cp -ra ./Auburn\ Sounds\ Graillon\ 2.lv2/ /usr/lib/lv2/;
    #sudo chown -R root:root /usr/lib/lv2/Auburn\ Sounds\ Graillon\ 2.lv2;
    #sudo chmod +x /usr/lib/lv2/Auburn\ Sounds\ Graillon\ 2.lv2/AuburnSoundsGraillon2.so;
    
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
