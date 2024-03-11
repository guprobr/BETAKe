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

No Ubuntu instale esses pacotes e ele vai puxar as dependencias: 

### sudo apt install -y sox ffmpeg mplayer autotalent pulseaudio-utils alsa-utils;
Este script do FFmpeg processa dois arquivos de áudio de entrada (${1}_voc.wav e ${1}.wav) e aplica uma série de filtros para melhorar as vozes e a qualidade de áudio em geral. Aqui está uma explicação de cada filtro utilizado no comando:

adeclip: Este filtro é usado para eliminar a distorção de clipe do áudio.  (clipping)

anlmdn: Aplica redução de ruído usando o filtro dinâmico multibanda adaptativo.

dynaudnorm: Realiza compressão de alcance dinâmico e normalização para garantir níveis de áudio consistentes.

ladspa: Utiliza o plugin Ladspa tap_autotalent para realizar a correção de tom e o auto-ajuste. Os parâmetros fornecidos controlam o comportamento do efeito de correção automática.

compand: Este filtro aplica compressão e expansão dinâmica ao sinal de áudio. Os parâmetros especificados definem o tempo de ataque e a curva de compressão.

aecho: Adiciona um efeito de eco ao áudio. Os parâmetros fornecidos controlam o atraso, o fator de decaimento e a intensidade do eco.

volume: Ajusta o nível de volume global do áudio.

aformat: Define o formato de áudio em PCM flutuante com uma frequência de amostragem de 48000 Hz e um layout de canal estéreo.

aresample: Reamostra o áudio usando o reamostrador SoX com um formato de saída alvo em PCM de 16 bits.

amix: Mistura os fluxos de áudio processados dos filtros anteriores.

O resultado final é salvo com o nome ${1}_go.wav com as melhorias especificadas aplicadas.

* Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas.
* Você pode fazer isso usando o filtro aresample do FFmpeg
 
* Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. 
* Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado.
* Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
