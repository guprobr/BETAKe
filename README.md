
## esses scripts estão o mais simples possível pois estou sempre que possível testando, 

DE FORMA ALGUMA ISSO É UMA APLICAÇÃO PARA USUÁRIO FINAL!

São dois scripts. Os playbacks devem ser formato WAV de preferencia nao ADPCM Microsoft.

Coloque o playback na mesma pasta, ex, We_are_the_Champions.wav

Nunca grave sem fones de ouvido, pois não é para gravar a saída do playback no arquivo da voz.
O arquivo de voz gravado passa por processos de transformação e filtros, que o timbre dos instrumentos não é válido para o algoritmo.

para gravar você usa o ./yeah.sh  We_are_the_Champions (note que o comando recebe o nome da arquivo como parametro, mas sem extensao)

* imediatamente ele começa a tocar o playback gravando o input da placa em um arquivo
* Pressionar CTRL+C uma UNICA vez, interrompe a gravação e salva o q foi gravado.

O script automaticamente chama o *go.sh* -- Este script executa o mix do input com o arquivo do playback e aplica os fitros.
Assim que o ffmpeg terminar a pipeline, ele executa o *mplayer* para você ouvir a mazela que acabou de fazer :)

São dois scripts separados para ser bem fácil mudar se você quiser a programação para tentar adaptar.
Rodando porventura ./go.sh  We_are_the_Champions ele nao grava de novo, apenas aplica novamente os filtros

O nome do produto final é  We_are_the_Champions_go.mp3

Note que sempre que você rodar o ./yeah.sh você vai sobrescrever a gravação anterior

GO NUTS, ppl!

## Requisitos de instalação

* sox - Swiss army knife of sound processing
* ffmpeg - Tools for transcoding, streaming and playing of multimedia files
* mplayer - movie player for Unix-like systems
* autotalent -  pitch correction LADSPA plugin
* pulseaudio-utils - Command line tools for the PulseAudio sound server
* alsa-utils - Utilities for configuring and using ALSA

No Ubuntu instale esses pacotes e ele vai puxar as dependencias: sudo apt install -y sox ffmpeg mplayer autotalent pulseaudio-utils alsa-utils;


