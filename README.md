# V2.69

*PARA RODAR: abra o terminal e use o python3*

```
$ python3 BETAKe.py
```

## python3 BETAKe.py
Insira uma ID unica para seu karaoke, eu normalmente coloco o primeiro nome da música em maiúsculo.

Insira a  URL do vídeo que vamos extrair para cantar junto como playback.

Overall, betaREC.sh sets up the environment for live recording with effects applied, while betaKE.sh performs post-processing to enhance the recorded audio and video. Together, they provide a comprehensive solution for karaoke recording.

## betaREC.sh
This script sets up live audio processing with Autotalent pitch correction, dynamics processing, and equalization using PulseAudio's pactl utility,
and records to a filename with name followed by _voc.wav, every time you run it overwrites again. This is file is used by next script, which generates the final video.

Vamos documentar os filtros LADSPA e PulseAudio usados no primeiro script, betaREC.sh, e explicar como o vídeo do YouTube é baixado.
```
Filtros LADSPA:
declip_1195:
Este plugin é utilizado para remover a distorção de clipagem do áudio. Ele suaviza os picos de áudio que ultrapassam o limite de amplitude, resultando em um som menos distorcido.
tap_pitch:
Este plugin é usado para ajustar o tom do áudio, o que é útil em karaoke para corrigir pequenos desvios de afinação na voz. Os parâmetros controlam o ajuste do tom: o primeiro e o segundo controlam o tom em semitons e centavos, respectivamente, enquanto os terceiro, quarto e quinto controlam o deslocamento do volume.
Módulos PulseAudio:
module-echo-cancel:
Este módulo é carregado para cancelar o eco do áudio, especialmente do retorno de áudio proveniente do loopback. Isso ajuda a melhorar a qualidade do áudio, removendo ecos indesejados.
module-loopback:
Este módulo é carregado para criar um loopback de áudio, permitindo que o áudio seja redirecionado de uma fonte de entrada para uma fonte de saída. No contexto do script, é usado para redirecionar o áudio processado de volta para o sistema de áudio para reprodução.
```
Baixando o Vídeo do YouTube:
O script utiliza a ferramenta yt-dlp para baixar o vídeo do YouTube. Aqui está como funciona:
```
Obtenção do Título do Vídeo:
Primeiro, o script usa yt-dlp --get-title para obter o título do vídeo do YouTube fornecido como argumento. Isso é feito para exibir informações sobre o vídeo que está sendo baixado.
Download do Vídeo:
Em seguida, o script usa yt-dlp novamente para baixar o vídeo do YouTube. Ele especifica a opção --embed-subs para incorporar legendas se estiverem disponíveis e --progress para exibir o progresso do download.
Conversão para WAV:
Depois que o vídeo é baixado, o script utiliza o ffmpeg para extrair o áudio do vídeo baixado e convertê-lo para o formato WAV. Isso é necessário para processamento adicional e gravação posterior.
```

Essas etapas permitem que o script baixe vídeos do YouTube, extraia o áudio e o prepare para gravação, permitindo a criação de karaokês com playback instrumental de alta qualidade e legendas embutidas, se disponíveis. Existem muitos canais hoje em dia, como ZOOM, KaraFun, ou até mesmo covers independentes instrumentais. Na verdade você pode usar esse programa vom qualquer vídeo.

## betaKE.sh

* betaKE.sh is the post-processing script that renders a final MP4 video
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

para *gravar* você usa: 


# betaREC.sh ID_SUA_MUSICA URL_VIDEO_KARAOKE:

This script is designed to set up and perform live recording with various effects applied, primarily for karaoke purposes. It will download a karaoke video, actually any video, and will mix the recording with the video original audio at the next step. Here's a breakdown of its functionality:

```
Unload Existing Modules and Restart PulseAudio: T
his section unloads any existing PulseAudio modules and restarts PulseAudio to ensure a clean audio setup.
Load Configuration Variables: 
efines variables for sink names.
Load the Null Sink Module:
Creates a virtual sink named "loopback" using the ALSA source.
Load Echo Cancellation Module:
Loads the echo cancellation module to cancel echo from the loopback.
Load Ladspa Effects:
Loads Ladspa effects for declipping and pitch correction.
Prepare to Record:
Determines the length of the audio to be recorded and prepares for downloading a lyrics video if a URL is provided.
Start Recording:
Starts recording audio with applied effects using parec and sox.
Launch Lyrics Video:
Downloads and plays the lyrics video using mplayer.
Stop Recording:
Stops recording after the lyrics video is finished or interrupted.
Housekeeping:
Cleans up by terminating unnecessary processes.
```

Trigger Post Processing: 
Calls the betaKE.sh script for post-processing.

# betaKE.sh ID_SEU_KARAOKE TITULO_DO_VIDEO_FINAL_Mp4:

This script performs post-processing on the recorded audio and video. Here's an overview:
```
Clean Up:
Unloads modules and cleans up the audio setup left by betaREC.sh.
Check Parameters:
Checks if the required parameters are provided, which are the name of the playback without the WAV extension and the title in MP3 format.
Perform Post-Processing:
 Uses ffmpeg to apply various audio filters, including echo cancellation, autotune, volume normalization, and mixing. It also overlays visual effects on the video.
Play Processed Video:
Uses mplayer to play the processed video.

```

## Requisitos de instalação

* yt-dlp -   downloader of videos from YouTube and **other sites**
* sox - Swiss **army knife of sound** processing
* ffmpeg - Tools for **transcoding, streaming and playing** of multimedia files
* autotalent -  **pitch correction** LADSPA plugin
* pulseaudio-utils - Command line **tools for the PulseAudio** sound server
* alsa-utils - Utilities for configuring and **using** **ALSA**
* Steve Harris **LADSPA** plugins

No Ubuntu instale esses pacotes e ele vai puxar as dependencias: 

### sudo apt install -y sox ffmpeg mplayer autotalent pulseaudio-utils alsa-utils swh-plugins yt-dlp;

* Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas.
* Você pode fazer isso usando o filtro aresample do FFmpeg
 
* Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. 
* Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado.
* Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!

## Audio Processing Pipeline Documentation
This document describes an audio processing pipeline using ffmpeg to preprocess vocals with Autotalent, enhance the pitch-corrected vocals with effects, and masterize the audio for streaming, combining both playback and enhanced vocals.

The audio pipeline in the betaKE.sh script involves several steps of audio processing using ffmpeg. Let's break down the pipeline in detail:

```
Input Sources:

Original Vocal Recording: This is the raw vocal recording obtained from the karaoke session.
Original Playback Audio: The original audio playback without any effects.
Lyrics Video Audio: The audio extracted from the lyrics video.
Filtering and Processing:

adeclip: This filter removes clipping distortion from the original vocal recording.
anlmdn: A noise gate filter that reduces low-level background noise.
ladspa=tap_autotalent: Applies autotune effect to the vocal recording for pitch correction. The parameters include the fundamental frequency, bandwidth, and formant shift.
compand: Compressor/expander filter that adjusts the dynamic range of the audio to make it sound more consistent.
firequalizer: Graphic equalizer filter that adjusts the frequency response of the audio.
aecho: Adds a simulated echo effect to the vocal recording.
treble: Adjusts the treble frequency range of the audio.
loudnorm: Loudness normalization filter that adjusts the volume level to a standardized level.
volume: Increases the overall volume of the audio.
aformat: Converts the audio format to a standardized format (floating-point PCM, 44100 Hz sample rate, stereo channels).
aresample: Resamples the audio to a standardized sample rate using the SoX resampler.
Mixing and Output:

Mixing: The processed vocal recording is mixed with the original playback audio using the amix filter.
Fading: The mixed audio is faded in over a duration of 2 seconds using the afade filter.
Visualization:

showcqt and avectorscope: Generate visualizations of the audio, including a continuous frequency transform (CQT) and an audio vectorscope.
Overlaying:

Overlaying Visual Effects: The visualizations are overlaid onto the video output.
Output Format:

The processed audio is encoded in AAC format with a bitrate of 320 kbps.
The output video format is MP4.
This pipeline applies a series of audio filters and effects to enhance the original vocal recording and mixes it with the original playback audio to create a final karaoke video with improved audio quality and visualizations.
```

These filters together process the vocal and playback audio, applying noise reduction, pitch correction, equalization, echo, and other effects, and then mix them together for the final output. Adjusting the parameters of these filters can result in different audio processing effects.


