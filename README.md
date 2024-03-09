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

Redução de Ruído ANLMDN (anlmdn=s=30):

Este filtro ANLMDN (Adaptive Non-Linear Median Denoising) é usado para reduzir o ruído de fundo no áudio vocal. Ele aplica uma técnica adaptativa de filtragem não linear que é eficaz na redução de ruídos de baixo nível e não estacionários.
Equalização (equalizer=f=800:width_type=h:width=100:g=-3):

A equalização é usada para ajustar as características de frequência do áudio. Neste caso, a frequência central de 800 Hz é realçada com uma largura de banda de 100 Hz e um ganho de -3 dB. Isso pode ajudar a realçar certas frequências importantes no áudio vocal.
Correção de Afinação (ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=444 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0.05 1.0 1.0):

Este filtro utiliza o plugin Autotalent através do LADSPA para aplicar correção de afinação ao áudio vocal. Os parâmetros fornecidos (como tom, escala, etc.) determinam o comportamento da correção de afinação.
De-essing (deesser=f=0.25):

O filtro de de-essing é usado para reduzir a sibilância no áudio vocal. O parâmetro f=0.25 ajusta a intensidade do efeito de de-essing.
Eco (aecho=0.5:0.6:100:0.3):

O filtro de eco adiciona um efeito de eco ao áudio vocal. Os parâmetros especificam a taxa de feedback, o atraso inicial, a taxa de decaimento e a atenuação do eco.
Normalização de Volume (speechnorm=e=6:r=0.0001:l=1):

A normalização de volume é usada para ajustar o nível de volume do áudio vocal. Os parâmetros especificam o nível de energia alvo (e=6), o tempo de resposta (r=0.0001) e o limite de amplitude (l=1).
Compressão/Expansão Dinâmica (compand=points=-90/-90|-70/-70|-30/-15|0/-15|20/-15):

O filtro de compressão/expansão é usado para ajustar a faixa dinâmica do áudio. Os pontos de curva especificados determinam como a compressão/expansão é aplicada em diferentes níveis de sinal.
Divisão de Áudio (asplit=2[bg][fg]):

Este filtro divide o áudio vocal e o áudio de fundo em dois fluxos separados.
Sidechain Compress ([fg][bg]sidechaincompress=threshold=0.5:ratio=5:attack=0.1:release=0.1[side]):

Este filtro comprime o áudio de fundo (bg) com base na energia do áudio vocal (fg). Isso ajuda a garantir que a voz permaneça audível mesmo quando a música de fundo estiver mais alta.
Mixagem de Áudio ([bg][side]amix=inputs=2[audio]):

Este filtro mistura o áudio de fundo comprimido (bg) com o áudio vocal original (side). Os pesos dos inputs são determinados pela compressão sidechain.
Mapeamento de Saída (-map "[audio]"):
Define a saída do áudio misturado como a saída final.
Salvando o Áudio (${1}_go.mp3 -y):
Salva o áudio finalizado em um arquivo MP3 com o nome especificado.
Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado. Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
