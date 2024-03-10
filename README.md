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

Input Files:

${1}_voc.wav: Represents the input vocal audio file.
${1}.wav: Represents the input instrumental audio file.
Filter Complex:

[0:a]: Selects the audio stream from the first input file (vocal audio).
anlmdn=s=10: Applies noise reduction using the anlmdn filter with a suppression value of 10 dB.
ladspa: Applies the autotalent LADSPA plugin with specified parameters for pitch correction.
deesser: Reduces sibilance in the vocal audio.
dynaudnorm: Normalizes the audio volume dynamically.
speechnorm: Normalizes the speech level.
aecho: Adds an echo effect to the vocal audio with specified parameters.
compand: Applies compression and expansion to the audio waveform.
equalizer: Applies equalization to adjust the frequency response.
highpass and lowpass: Filters out frequencies below 100 Hz and above 15 kHz respectively.
stereowiden: Widens the stereo image of the audio.
acontrast: Adjusts the contrast of the audio.
alimiter: Applies limiting to prevent clipping.
aformat: Specifies the audio format.
aresample: Resamples the audio to the desired output format.
Output:

[avoc]: Represents the processed vocal audio stream.
[1:a]: Selects the audio stream from the second input file (instrumental audio).
[a1]: Represents the processed instrumental audio stream.
[avoc][a1]: Mixes the processed vocal and instrumental audio streams.
amix=inputs=2:weights=0.6|0.4: Mixes the vocal and instrumental audio streams with specified weights (60% for vocals and 40% for instrumental).
${1}_go.mp3: Represents the output file name in MP3 format.
Overall, this command applies various audio processing filters to enhance the vocal and instrumental audio and then mixes them to produce the final MP3 output.

Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas. Você pode fazer isso usando o filtro aresample do FFmpeg
 
Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado. Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
