#!/bin/bash

DIR_aqui=$( pwd );
BETA_PATH=$(printf '%s\n' "$DIR_aqui" | sed 's/[\/&]/\\&/g');

echo "Esse script vai instalar em /usr/bin um script python \
esse script usará este diretório atual ( ${DIR_ARQUIVOS} )  \
como workspace, ou seja, na verdade só instalamos o atalho  \
 .desktop do gnome e esse script no /usr/bin;  ";
echo "Tambem usamos todos os pacotes do fortunes e eles serão instalados.";


# Prompt the user for input
read -p "Do you want to continue? (yes/no): " response

# Check the response
if [[ $response == "yes" ]]; then
    echo "You chose to continue.";
    sudo apt -y install fortunes* ffmpeg swh-plugins lsp-plugins alsa-utils yt-dlp \
	autotalent python3-pexpect pulseaudio-utils ;
    echo "cp -ra BETAKe.desktop ~/.local/share/applications/;"
    cp -ra BETAKe.desktop ~/.local/share/applications/;

elif [[ $response == "no" ]]; then
    echo "You chose to cancel.";
else
    echo "Invalid response. Please enter 'yes' or 'no'.";
fi
