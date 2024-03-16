#### V2.5
v2.5 AINDA NAO TEM EXEMPLOS DE OUTPUT: https://xiclet.com.br

## yeah.sh
This script sets up live audio processing with Autotalent pitch correction, dynamics processing, and equalization using PulseAudio's pactl utility. 

## betaKE.sh

* betaKE.sh is the post-processing script that renders a final MP4 video with tux.jpeg as fixed image of video;
* Now some enhancemente live, during recording time, except autotalent;
* we just have to enhance already pitch corrected vocal with effects in order to masterize:
* then MASTERIZE for streaming both playback and enhanced vocals, mixing both tracks.

 * esses scripts focam ser o mais simples possível,
 * tenha em mente, que, quanto mais se tenta efeitos sonoros mirabolantes, mais fácil estragar o audio final. 

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

O script automaticamente chama o *betaKE.sh* -- Este script executa o mix do input com o arquivo do playback e aplica os fitros.
Assim que o ffmpeg terminar a pipeline, ele executa o *mplayer* para você ouvir a mazela que acabou de fazer :)

São dois scripts separados para ser bem fácil mudar se você quiser a programação para tentar adaptar.
Rodando porventura 

## ./betaKE.sh  We_are_the_Champions 

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

* Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas.
* Você pode fazer isso usando o filtro aresample do FFmpeg
 
* Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. 
* Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado.
* Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!

## Audio Processing Pipeline Documentation
This document describes an audio processing pipeline using ffmpeg to preprocess vocals with Autotalent, enhance the pitch-corrected vocals with effects, and masterize the audio for streaming, combining both playback and enhanced vocals.
This script performs the following actions:

Let's break down each filter used in the ffmpeg command:

```
anlmdn:

This filter performs noise reduction using the NLMDenoise algorithm.
s=13: Sets the strength of the noise reduction. Higher values result in more aggressive noise reduction.
highpass=f=100,lowpass=f=15000: Applies a high-pass and low-pass filter to limit the frequency range of the audio being processed.
ladspa (Tap Autotalent):

This filter applies pitch correction and harmonization.
plugin=autotalent: Specifies the Autotalent plugin.
The numbers following autotalent are control parameters for the plugin. These parameters control aspects such as pitch correction strength, format, and other settings.
compand:

This filter performs dynamic range compression/expansion.
points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7: Specifies the compression/expansion curve points.
This filter helps to normalize the audio's loudness levels.
firequalizer (Equalizer):

This filter applies equalization to adjust the frequency response of the audio.
gain_entry='entry(250,-5);entry(4000,3)': Specifies the gain for specific frequency bands. In this case, it boosts frequencies around 250Hz and 4kHz.
aecho:

This filter adds echo to the audio.
0.8:0.7:111:0.13: Specifies parameters for the echo effect, including delay time, feedback, and other properties.
extrastereo:

This filter increases the stereo width of the audio.
m=1.5: Sets the amount of stereo expansion. Higher values result in more pronounced stereo width.
loudnorm:

This filter performs loudness normalization.
I=-16:LRA=11:TP=-1.5: Specifies loudness normalization parameters such as target integrated loudness (I), loudness range (LRA), and true peak level (TP).
aformat:

This filter adjusts the audio format settings.
sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo: Specifies the desired sample format, sample rate, and channel layout.
aresample:

This filter resamples the audio.
resampler=soxr:osf=s16: Specifies the resampling algorithm (soxr) and output sample format (s16).
amix:

This filter mixes audio streams together.
inputs=2: Specifies the number of input streams to mix.
weights=0.4|0.6: Sets the relative weights of the input streams.
This filter combines the processed vocal audio (voc_master) with the original playback audio (play_master) and applies fading.
```

These filters together process the vocal and playback audio, applying noise reduction, pitch correction, equalization, echo, and other effects, and then mix them together for the final output. Adjusting the parameters of these filters can result in different audio processing effects.
