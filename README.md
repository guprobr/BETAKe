

# RESUMO DA OPERA

Os algoritmos de correção tonal em geral têm o objetivo de ajustar a afinação ou a altura das notas musicais em uma gravação de áudio para garantir que elas estejam em conformidade com uma determinada escala ou padrão tonal. Esses algoritmos são frequentemente usados em softwares de edição de áudio para corrigir problemas de afinação em performances vocais ou instrumentais.

```
O princípio matemático subjacente aos algoritmos de correção tonal envolve a detecção das frequências fundamentais das notas musicais na gravação de áudio e, em seguida, a aplicação de transformações para ajustar essas frequências para correspondência com uma escala tonal desejada. Aqui está uma explicação detalhada do processo:
```

### Detecção de Frequências Fundamentais: 
O primeiro passo é detectar as frequências fundamentais das notas musicais na gravação de áudio. Isso pode ser feito usando técnicas de análise de espectro, como a Transformada de Fourier, que permite decompor o sinal de áudio em suas componentes de frequência.

### Correlação com Escala Tonal: 
Uma vez que as frequências fundamentais são identificadas, elas são correlacionadas com uma escala tonal desejada. Isso pode envolver a comparação das frequências detectadas com os intervalos da escala musical para determinar quais notas estão sendo tocadas ou cantadas.

### Cálculo do Desvio de Afinação: 
Com base na correlação com a escala tonal, é calculado o desvio de afinação de cada nota em relação à escala desejada. Isso é feito comparando as frequências detectadas com as frequências padrão das notas na escala tonal.

### Aplicação de Transformações: 
Com o desvio de afinação determinado para cada nota, são aplicadas transformações para ajustar suas frequências. Isso pode envolver a transposição das frequências para cima ou para baixo para corresponder à afinação correta da nota na escala tonal.

### Suavização de Transições: 
Para garantir que as transições entre as notas ajustadas soem naturais, são aplicadas técnicas de interpolação, como interpolação linear ou interpolação por splines, para suavizar as mudanças de frequência ao longo do tempo.

### Reprocessamento e Síntese de Áudio: 
Após o ajuste das frequências, o áudio é reprocessado e sintetizado para criar uma nova versão da gravação com as correções tonais aplicadas. Isso pode envolver a sobreposição das notas ajustadas sobre a gravação original ou a síntese de novos sons com base nas correções aplicadas.

Este é um resumo simplificado do princípio matemático por trás dos algoritmos de correção tonal. Na prática, esses algoritmos podem ser bastante complexos e incorporar uma variedade de técnicas de processamento de sinais de áudio e modelagem matemática para obter resultados precisos e naturais.

## este SONETO COMPLETO, por etapas:

A interface python constantemente recebe atualizações e novas features, mas é o shell script que realmente faz o trabalho da aplicação. 
Este script shell aborda uma série de etapas para melhorar a qualidade vocal em uma gravação de karaokê. Vamos analisar cada uma dessas etapas em detalhes:

## Download do Vídeo de Karaokê:

Utilizando a ferramenta yt-dlp, o script faz o download do vídeo de karaokê da URL fornecida. O vídeo é então renomeado e armazenado localmente.


## Gravação de Áudio e Vídeo:

O script começa capturando a entrada de áudio e vídeo de uma fonte, como uma webcam, enquanto o vídeo de karaokê é reproduzido. Isso é feito usando o FFmpeg para gravar a entrada de vídeo e áudio simultaneamente.


## Processamento de Áudio:

Após a gravação, o áudio da voz é separado do vídeo e passa por várias etapas de processamento:
Primeiramente, o áudio é submetido a um perfil de ruído para identificar e remover o ruído de fundo.
Em seguida, é aplicado um algoritmo de correção tonal usando o plugin Gareus XC42 e Auburn Sound's Graillon, com ajustes de volume e equalização para melhorar a qualidade vocal.
Se o áudio apresentar problemas de clipping, é utilizado um declipper para corrigir esses problemas.
Finalmente, o áudio processado é combinado com o áudio do vídeo original.

## Renderização do Vídeo Final:

Após o processamento do áudio, o vídeo é reajustado para sincronizar com o áudio tratado. O tempo de atraso ou adiantamento é calculado com base na diferença de duração entre a gravação do áudio e do vídeo.
A renderização final combina o vídeo original com o áudio tratado, aplicando texto na tela para exibir o tempo restante da música. O vídeo resultante é então salvo.

## Geração de Arquivo de Saída MP3:

Além do vídeo final, o script também gera um arquivo de áudio MP3 separado a partir do arquivo de saída final. Isso permite que os usuários tenham uma versão apenas de áudio da gravação de karaokê.

## Exibição do Vídeo para o Usuário:

Por fim, o vídeo final é reproduzido para o usuário usando o FFplay, permitindo que eles visualizem o resultado final da gravação de karaokê.
Em termos de qualidade da abordagem, este script shell apresenta uma série de técnicas para melhorar a qualidade vocal, incluindo redução de ruído, correção tonal e equalização. No entanto, a eficácia dessas técnicas pode variar dependendo da qualidade da gravação original e da precisão dos algoritmos utilizados, estando em constante aperfeiçoamento, buscando não exagerar nos recursos mas sim construir uma solução direta, que não obrigue subtrações de um conjunto maior no percurso.

### XC 42:

O XC 42 é outro algoritmo de correção tonal, desenvolvido por Joshua Reiss e Andrew McLeod. Ele usa técnicas avançadas de processamento de sinais de áudio para realizar correção tonal em gravações vocais.
O XC 42 é projetado para oferecer correção tonal precisa e eficiente, com controle sobre parâmetros como a extensão de correção e a suavização de transições entre notas musicais.

### Graillon:

O Graillon é uma ferramenta de correção tonal baseada em aprendizado de máquina, desenvolvida por Grzegorz Ptasinski. Ele usa algoritmos avançados de processamento de sinais de áudio e técnicas de aprendizado de máquina para realizar correção tonal em gravações de áudio de alta qualidade.
O Graillon é conhecido por sua capacidade de corrigir afinações de forma precisa e natural, adaptando-se ao estilo vocal e às nuances da performance do cantor.

# v3.0 - gammaQ.sh


* Recebendo Parâmetros: O script recebe agora 4 parâmetros: o nome do karaokê, a URL do vídeo e o caminho do diretório beta, agora o dispositivo v4l2 /dev/video configurado no *python launcher*;

* Configuração de Diretórios: Define diretórios para armazenar gravações e arquivos de saída, criando-os se não existirem.

* Função colorecho: Define uma função para imprimir mensagens coloridas no terminal.

* Função kill_parent_and_children: Define uma função para encerrar o processo pai e todos os seus filhos.

* Função render_display_progress: Define uma função para exibir o progresso usando o tamanho estimado do arquivo.

* Função generate_mp3: Define uma função para gerar um arquivo MP3 a partir de um arquivo MP4.

* Obtendo Informações de Áudio: Obtém informações padrão de áudio e microfone do sistema.

* Atualizando e Baixando Vídeo do YouTube: Atualiza o programa de download de vídeos do YouTube (yt-dlp) e baixa o vídeo do YouTube especificado, salvando-o no diretório de gravações.

* Verificação e Conversão de Formato do Vídeo: Verifica e converte o formato do vídeo baixado para garantir compatibilidade.

* Mensagem de Confirmação de Gravação: Exibe uma mensagem para confirmar a gravação do karaokê.

* Gravação de Vídeo e Áudio: Inicia a gravação de vídeo e áudio a partir do dispositivo padrão do sistema.

* Exibição do Progresso da Gravação: Exibe uma barra de progresso indicando o progresso da gravação.

* Pós-Produção de Áudio: Aplica filtros e ajustes de áudio, como dithering, redução de ruído e ajuste vocal.

* Renderização do Vídeo Final: Combina o áudio pós-produzido com o vídeo original, aplicando filtros e ajustes necessários.

* Gerando Arquivo MP3: Gera um arquivo MP3 a partir do vídeo final renderizado.

* Exibição do Vídeo Final: Exibe o vídeo finalizado no player de mídia.

O script realiza várias etapas para processar e produzir um karaokê completo a partir de um vídeo do YouTube, incluindo download, gravação, pós-produção de áudio e renderização do vídeo final.

## masterização com SoX, LV2 e FFMpeg complex filter

### Shibata Dithering com SoX e Redução de Ruído:

O Shibata Dithering é um método de dithering usado para melhorar a qualidade de áudio digital. No contexto do script, é aplicado usando o SoX (Sound eXchange), uma poderosa ferramenta de processamento de áudio.
A linha 
```sox "${VOCAL_FILE}" -n trim 0 5 noiseprof "$OUT_DIR"/"$karaoke_name".prof``` 
cria um perfil de ruído a partir dos primeiros 5 segundos do arquivo de áudio gerado anteriormente.
Em seguida, 
```
sox "${VOCAL_FILE}" "${OUT_VOCAL}" noisered "$OUT_DIR"/"$karaoke_name".prof 0.2 dither -s -f shibata 
```
aplica a redução de ruído usando o perfil de ruído criado e aplica o Shibata Dithering para melhorar a qualidade do áudio.

### Algoritmo de Ajuste Vocal Gareus XC42:

O Gareus XC42 é um algoritmo de ajuste vocal desenvolvido por Robin Gareus. Ele é usado para ajustar e aprimorar a qualidade das vozes nas gravações de áudio.
A linha 
```
lv2file -i "${OUT_VOCAL}" -o "${VOCAL_FILE}" -P Live http://gareus.org/oss/lv2/fat1 
```
aplica esse algoritmo ao arquivo de áudio vocal, gerando um novo arquivo de áudio aprimorado.

### Algoritmo de Ajuste Vocal Auburn Sound's Graillon:

O Graillon é um plugin de processamento de áudio desenvolvido pela Auburn Sounds, usado para ajustar e modificar vozes.
A linha 
```
lv2file -i "${OUT_VOCAL}" -o "${VOCAL_FILE}" -P Younger\ Speech -p p9:1.00 -p p20:2.00 -p p15:0.509 -p p17:1.000 -p p18:1.00 -c 1:input_38 -c 2:input_39 https://www.auburnsounds.com/products/Graillon.html40733132#in1out2 
```
aplica o plugin Graillon ao arquivo de áudio vocal, com diferentes parâmetros de ajuste especificados.

* Esses algoritmos são aplicados para melhorar a qualidade do áudio vocal, reduzir o ruído e ajustar características específicas da voz para produzir um resultado final mais agradável e profissional.
* Cada algoritmo tem sua própria função e configurações que podem ser ajustadas para atender às necessidades específicas de uma gravação de karaokê.

## pós produção com FFMpeg e mixagem

### Configuração do Áudio:

```
[0:a]volume=volume=0.35, aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo, aresample=resampler=soxr:osf=s16[playback];
```
Esta parte do código é responsável por configurar o áudio proveniente da primeira entrada (índice [0:a]).
```
volume=0.35
```
Define o volume do áudio para 35% do volume original.
```
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo
```
Define o formato de amostragem (fltp), a taxa de amostragem (44100 Hz) e o layout de canal (estéreo).
```
aresample=resampler=soxr:osf=s16 
```

Aplica um redimensionamento de amostra usando o resampler SoX Resampler (soxr) para converter o áudio para um formato de amostra de 16 bits.

### Processamento do Áudio Vocal:
```
[1:a] adeclip, compensationdelay, alimiter, speechnorm, acompressor, aecho=0.8:0.8:56:0.33, treble=g=4, aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo, aresample=resampler=soxr:osf=s16:precision=33[vocals];
```
Esta parte processa o áudio proveniente da segunda entrada (índice [1:a]), que é o áudio vocal.
adeclip, compensationdelay, alimiter, speechnorm, acompressor: Aplicam uma série de filtros e efeitos de áudio, como remoção de distorção, atraso de compensação, limitação, normalização de volume e compressão.
aecho=0.8:0.8:56:0.33: Adiciona um eco ao áudio com os parâmetros especificados.
treble=g=4: Ajusta o nível de agudos do áudio.
```
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo
```
Define o formato de amostragem, taxa de amostragem e layout de canal do áudio vocal.
```
aresample=resampler=soxr:osf=s16:precision=33
```
Aplica um redimensionamento de amostra ao áudio vocal usando o SoX Resampler.

### Mesclagem de Áudio:
```
[playback][vocals] amix=inputs=2:weights=0.45|0.56;
```
Mescla os áudios processados do playback e dos vocais (definidos anteriormente) usando a função amix, onde inputs=2 indica que há duas entradas a serem mescladas e weights=0.45|0.56 especifica os pesos de cada entrada na mesclagem final.

### Geração de Vídeo:
```
waveform, scale=s=640x360[v1]; gradients=n=7:s=640x360, format=rgba[vscope]; [0:v] scale=s=640x360[v0]; [v1][vscope] xstack=inputs=2, scale=s=640x360[badcoffee]; [v0][badcoffee] vstack=inputs=2, scale=s=640x480;
```
Esta parte configura o vídeo.

* waveform: Gera uma forma de onda do áudio.
* gradients: Cria gradientes visuais.
* [0:v] scale=s=640x360[v0]: Redimensiona o vídeo original para uma resolução de 640x360.
* [v1][vscope] xstack=inputs=2: Empilha os vídeos da forma de onda e dos gradientes horizontalmente.
* [v0][badcoffee] vstack=inputs=2: Empilha o vídeo original redimensionado e o resultado do xstack verticalmente.
* scale=s=640x480: Redimensiona o vídeo final para uma resolução de 640x480.

Essas configurações combinam processamento de áudio e vídeo para produzir um resultado final que inclui ajustes de áudio, mesclagem de diferentes fontes de áudio e efeitos visuais aplicados ao vídeo.

### preview e mp3

* após tudo isso, novamente se invoca o FFMpeg para criar um overlay ou xstack do usuário filmado com os vídeos com efeitos e o playback. O programa então se tudo deu certo, toca o arquivo final para preview;

* por cortesia geramos uma MP3 da performance!

* tudo é gravado no diretório *./outputs*
* os playbacks baixados ficam em cache em *./recordings*

# instalação parcialmente implementada

* para rodar recomendo olhar o *instalar.sh*
* BETAKe.py é a interface em si, são poucos requisitos de biblioteca python.
* a maioria dos requisitos já devo ter colocado no instalador.

# DEMOs fuleiros by Guzpido

https://Xiclet.com.br

# V2.8

# grandes avanços na interface python3

*PARA RODAR: abra o terminal e use o python3*

```
$ python3 BETAKe.py
```

## python3 BETAKe.py
Insira uma ID unica para seu karaoke, eu normalmente coloco o primeiro nome da música em maiúsculo.

Insira a  URL do vídeo que vamos extrair para cantar como playback.

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
O script utiliza a ferramenta **yt-dlp** para baixar o vídeo do YouTube. Aqui está como funciona:
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

* sox - Swiss army knife of sound processing
* pavumeter - PulseAudio Volume Meter
* yt-dlp - downloader of videos from YouTube and **other sites**
* python3-pexpect - Python 3 module for automating interactive applications
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


