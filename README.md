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


O comando ffmpeg fornecido processa dois arquivos de áudio de entrada (${1}_voc.wav e ${1}.wav) e aplica uma série de filtros para aprimorar e misturar o áudio. Aqui está uma explicação do comando:

ffmpeg -i ${1}_voc.wav -i ${1}.wav -filter_complex \
-i ${1}_voc.wav: Especifica o primeiro arquivo de áudio de entrada, que contém a voz.
-i ${1}.wav: Especifica o segundo arquivo de áudio de entrada, que contém a música.
-filter_complex: Indica o início da cadeia de filtros complexos.
Aqui está a cadeia de filtros complexos:


"[0:a]anlmdn=s=25,\
equalizer=f=800:width_type=h:width=100:g=-6,\
deesser=f=0.95,\
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=440 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1.0000,\
alimiter,\
speechnorm=e=50:r=0.0001:l=1,\
aecho=0.8:0.9:111:0.255,\
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,\
aresample=resampler=soxr:osf=s16[avoc];\
[0:a]: Indica que o filtro será aplicado ao primeiro arquivo de áudio de entrada (a voz).
anlmdn=s=25: Aplica uma redução de ruído usando o filtro anlmdn, com um nível de sensibilidade de 25.
equalizer=f=800:width_type=h:width=100:g=-6: Aplica um equalizador para ajustar a resposta de frequência, reduzindo em 6dB a amplitude dos graves a 800Hz.
deesser=f=0.95: Aplica um filtro de de-esser para reduzir sibilâncias indesejadas na voz.
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=440 ...: Aplica o plugin Autotalent usando o Ladspa, ajustando as configurações especificadas.
alimiter: Aplica um limitador de áudio para evitar picos de volume excessivos.
speechnorm=e=50:r=0.0001:l=1: Normaliza o nível de volume do áudio da voz.
aecho=0.8:0.9:33:0.255: Adiciona um efeito de eco com as configurações especificadas.
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo: Define o formato de áudio de saída para ponto flutuante de 32 bits, taxa de amostragem de 44100Hz e layout de canais estéreo.
aresample=resampler=soxr:osf=s16: Usa o resample para converter a saída para o formato desejado.
Agora, a mistura dos áudios é feita com o seguinte trecho:


[1:a]aresample=resampler=soxr:osf=s16[a1];\
[avoc][a1]amix=inputs=2;"\
[1:a]: Indica que o filtro será aplicado ao segundo arquivo de áudio de entrada (a música).
aresample=resampler=soxr:osf=s16[a1]: Usa o resample para converter a saída para o formato desejado.
[avoc][a1]amix=inputs=2: Mistura os dois áudios de entrada (voz e música) com pesos iguais.
Por fim, o áudio resultante é salvo como ${1}_go.mp3 com o parâmetro -y para confirmar a sobregravação, se necessário.

Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas. Você pode fazer isso usando o filtro aresample do FFmpeg
 
Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado. Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
