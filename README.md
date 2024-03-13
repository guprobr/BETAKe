#### V1.69 c


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
* Steve Harris LADSPA plugins

No Ubuntu instale esses pacotes e ele vai puxar as dependencias: 

### sudo apt install -y sox ffmpeg mplayer autotalent pulseaudio-utils alsa-utils swh-plugins;

### explicação do comando da última versão


Este comando do FFmpeg é usado para aprimorar as vozes em um arquivo de áudio ${1}_voc.wav, processando-o com vários filtros e depois misturando-o com outro arquivo de áudio ${1}.wav. Aqui está uma explicação de cada parte do comando:

Arquivos de Entrada: -i ${1}_voc.wav -i ${1}.wav
```
${1}_voc.wav: O arquivo de entrada contendo as vozes.
${1}.wav: O arquivo de entrada contendo a música ou áudio de fundo.
Filtro Complexo:

[0:a]: Refere-se ao primeiro fluxo de áudio de entrada (vocais).
adeclip: Remove o clipe do áudio.
anlmdn: Realiza redução de ruído usando o algoritmo NLMD com a força s=XX.
compand: Comprime e expande a dinâmica de áudio com parâmetros de ataque, decaimento, pontos e soft-knee especificados.
ladspa: Aplica o plugin Autotalent usando LADSPA, corrigindo o tom das vozes.
compand: Outra compressão e expansão da dinâmica de áudio.
deesser: Reduz a sibilância nas vozes.
aecho: Adiciona um efeito de eco ao áudio.
treble: Ajusta a faixa de frequência de agudos.
equalizer: Aplica equalização para amplificar ou atenuar faixas de frequência específicas.
ladspa: Aplica um plugin de limitador de antecipação rápida.
ladspa: Aplica o plugin compressor SC4.
[voc_enhanced]: Rótulo para o fluxo de áudio de voz aprimorado.
[voc_enhanced]: Refere-se ao fluxo de áudio de voz aprimorado.
loudnorm: Realiza normalização de volume novamente.
aformat: Define o formato de áudio para PCM de ponto flutuante.
aresample: Remostura o áudio para uma taxa de amostragem de 44100 Hz usando o remisturador SoX.
[voc_master]: Rótulo para o fluxo de áudio de voz processado.
[1:a]: Refere-se ao segundo fluxo de áudio de entrada (música ou áudio de fundo).
aformat: Define o formato de áudio para PCM de ponto flutuante.
aresample: Remistura o áudio para uma taxa de amostragem de 44100 Hz usando o remisturador SoX.
[play_master]: Rótulo para o fluxo de áudio de música processado.
[play_master][voc_master]amix=inputs=2:weights=0.5|0.5: Mistura os fluxos de áudio de voz e música processados com pesos iguais.
Saída: -ar 44100 ${1}_go.wav

Define a taxa de amostragem de áudio de saída como 44100 Hz e salva o resultado como ${1}_go.wav.
Reprodução: && mplayer ${1}_go.wav
```
Reproduz o arquivo de áudio resultante ${1}_go.wav usando mplayer após a execução do comando FFmpeg.

* Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas.
* Você pode fazer isso usando o filtro aresample do FFmpeg
 
* Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. 
* Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado.
* Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
