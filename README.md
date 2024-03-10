ex de outputs: https://gu.pro.br/betake-records/

 * esses scripts estão o mais simples possível,
 * quanto mais se tenta efeitos sonoros mirabolantes, mais fácil estragar o audio final. 

DE FORMA ALGUMA ISSO já é UMA APLICAÇÃO PARA USUÁRIO FINAL!


* Para flexibilidade, separei em dois scripts. 
* Os playbacks devem ser formato WAV de preferencia nao ADPCM Microsoft.
* Coloque os playback na mesma pasta, ex, "We_are_the_Champions.wav"
* Nunca grave sem fones de ouvido, pois não é para gravar a saída do playback no arquivo da voz.
* O arquivo de voz gravado passa por processos de transformação e filtros, que o timbre dos instrumentos não é válido para o algoritmo.
* o princípio de todo bom resultado é ajustar o volume do microfone
* volume de input mto alto vai distorcer sua voz
* gritar não é cantar, mas se quiser pode, só vai ficar ruim seu karaoke
* teste antes de pegar o  jeito, o volume do microfone em si que resulta numa voz decente
* depois também ajuste o volume do playback se necessario, isso é outra fonte de empecilhos para um bom resultado
* quando você roda o script *yeah.sh* ele aciona o módulo de loopback do input,
* para q você ouça sua própria voz quando estiver gravando
* também para ajustar antes de gravar definitivamente, sua voz o microfone em função do volume do playback

para gravar você usa: 

## ./yeah.sh  We_are_the_Champions 

(note que o comando recebe o nome da arquivo como parametro, mas sem extensao)

* imediatamente ele começa a tocar o playback gravando o input da placa em um arquivo
* Pressionar CTRL+C uma UNICA vez, interrompe a gravação e salva o q foi gravado.

O script automaticamente chama o *go.sh* -- Este script executa o mix do input com o arquivo do playback e aplica os fitros.
Assim que o ffmpeg terminar a pipeline, ele executa o *mplayer* para você ouvir a mazela que acabou de fazer :)

São dois scripts separados para ser bem fácil mudar se você quiser a programação para tentar adaptar.
Rodando porventura 

## ./go.sh  We_are_the_Champions 

assim ele nao grava de novo, apenas aplica novamente os filtros

O nome do produto final ficará  "We_are_the_Champions_go.mp3"

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


O comando ffmpeg fornecido processa dois arquivos de áudio de entrada (${1}_voc.wav e ${1}.wav) e aplica uma série de filtros para aprimorar e misturar o áudio. 
Aqui está uma explicação do comando:

```markdown
## Processamento de Áudio com FFmpeg

Este é um exemplo de comando `ffmpeg` para processamento de áudio usando uma cadeia de filtros complexos. O comando realiza várias operações, incluindo redução de ruído, equalização, aplicação de efeitos, normalização e mistura de áudio.

```bash
ffmpeg -i ${1}_voc.wav -i ${1}.wav -filter_complex \
"[0:a]anlmdn=s=25,\
equalizer=f=800:width_type=h:width=100:g=-6,\
deesser=f=0.95,\
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=440 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1.0000,\
alimiter,\
speechnorm=e=50:r=0.0001:l=1,\
aecho=0.8:0.9:111:0.255,\
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,\
aresample=resampler=soxr:osf=s16[avoc];\
[1:a]aresample=resampler=soxr:osf=s16[a1];\
[avoc][a1]amix=inputs=2;"\
 ${1}_go.mp3 -y;
```

### Descrição do Processamento:

- `anlmdn=s=25`: Redução de ruído com sensibilidade de 25.
- `equalizer=f=800:width_type=h:width=100:g=-6`: Equalização para ajustar a resposta de frequência.
- `deesser=f=0.95`: Filtro de de-esser para reduzir sibilâncias.
- `ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=440 ...`: Aplicação do plugin Autotalent.
- `alimiter`: Limitação de áudio para evitar picos de volume.
- `speechnorm=e=50:r=0.0001:l=1`: Normalização do nível de volume do áudio da voz.
- `aecho=0.8:0.9:111:0.255`: Adição de um efeito de eco.
- `aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo`: Definição do formato de áudio de saída.
- `aresample=resampler=soxr:osf=s16`: Conversão da saída para o formato desejado.

A música resultante é salva como `${1}_go.mp3`.
```

* Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas.
* Você pode fazer isso usando o filtro aresample do FFmpeg
 
Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado. Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
