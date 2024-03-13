#### V1.7 b
**Audio Processing Pipeline Documentation**
This document describes an audio processing pipeline using ffmpeg to preprocess vocals with Autotalent, enhance the pitch-corrected vocals with effects, and masterize the audio for streaming, combining both playback and enhanced vocals.

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



#### Audio Processing Pipeline Documentation

This document describes an audio processing pipeline using ffmpeg to preprocess vocals with Autotalent, enhance the pitch-corrected vocals with effects, and masterize the audio for streaming, combining both playback and enhanced vocals.

### Preprocessing with Autotalent:

```
Noise Reduction and Equalization:
adeclip: Remove clipping distortion from audio.
anlmdn: Apply noise reduction using a speech noise suppressor.
Autotalent Pitch Correction:
ladspa=tap_autotalent:plugin=autotalent: Correct pitch using Autotalent 
```

## Additional Processing:
```
afftdn: Adaptive Free-Form Time-Domain Noise Reduction.
Equalization: Adjust frequency response with three equalizer bands centered at 150 Hz, 800 Hz, and 5000 Hz.
Firequalizer: Apply additional gain adjustments to specific frequency bands.
Treble: Boost high-frequency content.
Enhancement with Effects:
Echo Effect:
aecho: Apply echo effect
Fast Lookahead Limiter:
ladspa=fast_lookahead_limiter_1913: Apply dynamic range compression to control peaks.
SC4 Compressor:
ladspa=sc4_1882: Apply dynamic range compression to further control peaks.
```

## Masterization:
```
Loudness Normalization:
loudnorm: Normalize audio to -16 LUFS Integrated Loudness with an 11 LU Loudness Range and a True Peak of -1.5 dBFS.
Format Conversion:
aformat: Convert audio to floating-point format with a sample rate of 44100 Hz and stereo channel layout.
Resampling:
aresample: Resample audio using the SoX Resampler with high-quality settings.
Mixing:
amix: Mix the processed vocal and the original audio with a 40:60 weight ratio.
```

# Usage:
```
To use this audio processing pipeline, replace ${1} with the input file name (without extension) and execute the provided ffmpeg command. The processed audio will be saved as ${1}_go.wav and played using the mplayer utility.
```

* Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas.
* Você pode fazer isso usando o filtro aresample do FFmpeg
 
* Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. 
* Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado.
* Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
