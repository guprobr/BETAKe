ex de outputs: https://gu.pro.br/betake-records/

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



Este comando ffmpeg é usado para processar um arquivo de áudio vocal (${1}_voc.wav) e um arquivo de áudio instrumental (${1}.wav). Aqui está uma explicação passo a passo do comando:

-loglevel info: Define o nível de detalhamento do log para "info", o que significa que apenas mensagens informativas serão exibidas durante a execução do comando.

-i ${1}_voc.wav: Especifica o arquivo de áudio de voz de entrada.

-i ${1}.wav: Especifica o arquivo de áudio instrumental de entrada.

-filter_complex "...": Indica o início da cadeia de filtros complexos.

[0:a]anlmdn=s=30,...: Aplica o filtro ANLMDN (Redução de Ruído Através da Mediana Adaptativa) com um nível de supressão de 30 para reduzir o ruído do áudio vocal de entrada.

equalizer=f=800:width_type=h:width=100:g=-3: Aplica um equalizador para realçar as frequências em torno de 800 Hz com uma largura de banda de 100 Hz e um ganho de -3 dB.

deesser=f=1.0: Aplica o filtro de de-essing com um fator de 1.0 para reduzir a sibilância no áudio vocal.

ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=444 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0.05 1.0 1.0: Aplica a correção de afinação usando o plugin Autotalent com os parâmetros especificados.

aecho=0.8:0.9:1000:0.3: Adiciona um eco ao áudio vocal com os parâmetros especificados.

speechnorm=e=6:r=0.0001:l=1: Normaliza o volume do áudio vocal para um nível de energia de 6 dB com um tempo de resposta de 0.0001 segundos e um limite de amplitude de 1.

[avoc]: Indica o final da cadeia de filtros para o áudio vocal e atribui o nome [avoc] ao resultado.

[avoc][1:a]amix=inputs=2:weights=0.7|0.3[amixed];: Mistura os áudios vocal e instrumental usando a proporção de 70% para o áudio vocal e 30% para o áudio instrumental.

[amixed]compand=points=-90/-90|-70/-70|-30/-15|0/-15|20/-15[w]: Aplica o filtro compand para comprimir/expansão o áudio com os pontos de curva especificados.

-map "[w]": Define a saída do mapa para o resultado do compand.

${1}_go.mp3: Especifica o nome do arquivo de saída, que será convertido para o formato MP3.

-y: Sobrescreve o arquivo de saída se ele já existir.
