#!/bin/bash

DIR_ARQUIVOS=$( pwd );

echo "Esse script vai instalar em /usr/bin um script python \
esse script usará este diretório atual ( ${DIR_ARQUIVOS} )  \
como workspace, ou seja, na verdade só instalamos o atalho  \
 .desktop do gnome e esse script no /usr/bin;  ";


# Prompt the user for input
read -p "Do you want to continue? (yes/no): " response

# Check the response
if [[ $response == "yes" ]]; then
    echo "You chose to continue."
    cp -ra BETAKe.desktop ~/.local/share/applications/
    echo "rodando sudo cp -ra BETAKe.py /usr/bin/";
    sed -i "s/\.\//${DIR_ARQUIVOS}/";
    sudo cp -ra BETAKe.py /usr/bin/
elif [[ $response == "no" ]]; then
    echo "You chose to cancel."
    # Add your actions here
else
    echo "Invalid response. Please enter 'yes' or 'no'."
fi