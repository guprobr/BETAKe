#!/bin/bash
betake_path=${HOME}/BETAKE;
gnome-terminal -t "gammaQ CMD prompt"  --geometry 80x98+1+0 -- /bin/bash -c "cd ${betake_path} && ./BETAKe.py; echo "Finished karaoke!"; exit;"

