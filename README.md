(+ docs em pt_BR seguem após as britânicas)


a Karaoke video PLAYER with performance RECORDER for Linux. 
* just a Shell script karaoke: vocal enhanced effects, pitch correction, auto-download YouTube playbacks + final mix/video render 
* based on FFMpeg + LV2 plugins
*AlphaQ - BETAke - now gammaQ v3*

# DeltaQ° ŧħ3 B3TAKê ·v4·
Este é um script de shell para gravar e aprimorar performances de karaokê. Ele é usado para capturar a performance de karaokê de um usuário usando uma webcam e um microfone, combinar a performance com a faixa de áudio original e, em seguida, aplicar várias melhorias de áudio, como ajuste de volume e remoção de ruído.

## Como usar
Configuração: Antes de usar o script, certifique-se de ter os seguintes requisitos instalados no seu sistema:

``ffmpeg
sox
yad
lv2file
mplayer
v4l-utils``

No ubuntu é fácil:
### Faça o clone do repositório e rode como SEU USUARIO NORMAL o arquivo ./instalar.sh
#### Um icone no gnome-shell vai surgir chamado BETAKe - gammaQ
#### para efeito de debug, existe um log pormenorizado script.log criado no diretório onde está o programa
##### na interface python há logs menos verbose.

Execução do Script: Execute o script PYTHON *BETAKe.py* no terminal, se precisar debugar, ou no gnome-shell, pois o instalar.sh cria um .desktop como dito. 
O script python3 é que vai fornecendo os seguintes argumentos para o shell principal  *gammaQ.sh*:

* Nome da performance de karaokê
* URL do vídeo de karaokê
* Diretório do projeto
* Dispositivo de vídeo
* URL da sobreposição (opcional)
* Opção para pular a performance (0 ou 1)
* Outra opção (opcional) - duplicar ECHO
* Outra opção (opcional) - Pitch bend UP ou DOWN

Portanto um launcher, uma interface grafica para manipular o comando "gammaQ.sh"

## Gravação da Performance: 

O script inicia a gravação da performance de karaokê usando a webcam e o microfone especificados.

## Melhorias de Áudio: 

Após a gravação, o script aplica várias melhorias de áudio, como remoção de ruído, ajuste de volume e equalização.

## Visualização e Renderização: 
O usuário pode visualizar a performance aprimorada e, se estiver satisfeito, renderizar o vídeo final. 

## detecção de volume ideal

O script compara o volume dos vocais com o playback e sugere uma porcentagem de alteração. O usuário pode fazer um preview do mix inteiro e alterar conforme o volume de 0 a 100% para diminuir ou mais para aumentar.
* Converte o arquivo de playback para o formato WAV usando o ffmpeg.
* Verifica a validade do arquivo WAV convertido.
* Extrai as informações de volume (amplitude RMS) de ambos os arquivos de playback e de vocais.
* Calcula a diferença de volume em decibéis (dB) entre os arquivos de playback e de vocais.
* Transforma a diferença de volume em uma porcentagem para fornecer uma recomendação de ajuste base.

# Filtros SoX (Sound eXchange):

## Geração de perfil de ruído:
sox "${OUT_VOCAL}" -n trim 0 15 noiseprof "$OUT_DIR"/"$karaoke_name"/"${karaoke_name}".prof > lv2.tmp.log 2>&1

## Redução de ruído:
sox "${OUT_VOCAL}" "${VOCAL_FILE}" noisered "$OUT_DIR"/"$karaoke_name"/"${karaoke_name}".prof 0.1 dither -s > lv2.tmp.log 2>&1

# Filtros LV2 (LADSPA):

## Aplicação do plugin de desclipping:
lv2file -i "${VOCAL_FILE}" -o "${OUT_VOCAL}" http://plugin.org.uk/swh-plugins/declip > lv2.tmp.log 2>&1

# Filtros ffmpeg:

## Conversão de vídeo para áudio WAV:
ffmpeg -i "${PLAYBACK_BETA}" "${PLAYBACK_BETA%.*}".wav

## Processamento de áudio com filtros:
ffmpeg -i "${OUT_VOCAL}" -af ... "${VOCAL_FILE}"

## Combinação de áudio e vídeo:
ffmpeg -i ... -filter_complex ... -map ... "${OUT_FILE}"

* uma série de filtros de video são aplicados, para criar boxes com o video do playback, a imagem do usuario cantando, efeitos visuais e mais alguns ajustes vocais, além do mix propriamente dito.

* após isso é gerada uma MP3 e o display do resultado final. 

![Screenshot from 2024-05-14 14-52-43](https://github.com/guprobr/BETAKe/assets/40776097/de09601a-8e7f-47c1-b5ad-d2f02ce1367f)

* Karaoke OUTPUT name: o nome do projeto, vai ser o nome do diretorio criado onde serao criados os sssets
* Playback Video URL: uma URL do Youtube, por exemplo, ou varios streamings suportados pelo *yt-dlp*. Ela sera baixada e armazenada, será disponibilizada na tela para o usuario cantar e depois no video final em um box separado.
* Overlay video: (opcional) um outro video para fetch que será sobreposto ao video do usuario, para efitos visuais.
* cfg /dev/videoX - seletor de *arquivo de dispositivo v4l2* para a webcam
* NOTA: o microfone da gravação é selecionado pela *source DEFAULT pulse/pipewire atual* no launch do script,
* Just render, no rec: pula a gravação da performance e renderiza novamente o arquivo de projeto que estiver escrito na caixa de texto *Karaoke Name*
* SELECT: *saved proj, overlay, playback*: preenche as 3 caixas respectivamente com arquivos que ja existem no sistema de arquivos. Evita download.
* Get Fortune! - para efeito de descontrair, o programa pode falar mensagens do */usr/bin/fortunes* UNIX no console da interface python.
* OPT-out fun effects: deixa o video do usuario na webcam cru, sem efeitos psicodélicos (que sáo meio exagerados por default)
* DOUBLE echo: normalmente o mix vai com um *echo leve*, nesse caso ele fica bem forçado. Ideal para músicas do Moby, etc.
* Pitch BEND up ou DOWN: faz um *shift para cima ou para baixo da tonalidade dos vocais* usando o XC 42
* FULL logs: para ver exatamente o que *apareceria no console e não os logs simples* da interface python3
* PLOT mic / CLOSE plot: um *visualizador para testar o nivel em decibeis do vocal*, ou seja, ajustar o microfone com precisão. Uma janela se abre e vc pode durante o karaoke tbm observar isso.
* Karaoke KILL: nao só um Quit mas tbm força matar caso algum processo fique preso. Talvez seja necessario apertar diversas vezes, nesses casos. Força na peruca.

## Opções do Script
* Simula a execução do script sem realizar a gravação ou aprimoramento de áudio. Isso serve para não ter que cantar de novo apenas para ajustar algum parametro, assim rendereizando novamente com outros efeitos, ou overlays, ou até mesmo playbacks. Basta colocar o nome do projeto igual ao diretorio onde foi gravado (há um botao na interface para Saved PRoject)
* Duplicar o efeito de eco durante a gravação da performance. 
* Pitch [UP|DOWN]: Define a direção do ajuste de tom durante a renderização do vídeo final.

Requisitos do Sistema
``Linux
Bash
Pacotes mencionados acima instalados``

Sinta-se à vontade para contribuir com melhorias, relatar problemas ou propor novos recursos através de problemas e solicitações pull.
Sinta-se à vontade para ajustar ou expandir esta documentação de acordo com as necessidades do seu projeto. Se precisar de mais alguma coisa ou tiver dúvidas, estou aqui para ajudar!



# OPERA SUMMARY

Karaoke Bash Script - Turn Your Machine into a Karaoke Machine!
This Bash script allows you to create your own karaoke videos with enhanced vocals!

Here's what you can do:

* Download a karaoke video (playback) from a URL or use a local file.
* Optionally include an overlay video for additional effects.
* Capture your singing performance using your webcam and microphone.
* Create a combined MP4 video with your performance, the playback video (with adjusted volume), and the overlay video (if used).
* Enhance the captured audio to make your vocals stand out (functionality currently commented out).

## Technical Details:

* The script utilizes FFmpeg for video processing and audio manipulation.
* It interacts with the user through colored messages and dialog boxes using the yad tool (installation required).
* PulseAudio or PipeWire is used for capturing audio from your microphone.

## Getting Started:

Requirements:
* Bash shell
* FFmpeg (https://ffmpeg.org/download.html)
* yad (https://sourceforge.net/projects/yad-dialog/)
* PulseAudio or PipeWire (https://wiki.archlinux.org/title/PipeWire)

### How it Works:

The script will guide you through a series of steps:

* Enter a name for your karaoke video (defaults to "BETA").
* Provide the URL of the karaoke video or the path to a local video file.
* Specify where you want to save the final karaoke video.
* Select your webcam device.
* (Optional) Enter the URL of an overlay video.
* Choose whether to skip webcam capture (useful for editing existing recordings).
* (Optional) Choose whether to restore vocals from a previously saved audio file.
* Select if you want the vocals to be "bent", shift pitch UP or DOWN.
* The script will then download the videos (if necessary), process the audio, and guide you through recording your performance. Finally, it combines everything into a finished karaoke video with your singing in the spotlight!

Note: The functionality for more enhanced vocals is currently commented out but can be potentially enabled in the future.

This script provides a fun and customizable way to create your own karaoke videos. Feel free to tinker with the code and explore its possibilities!

* Tonal correction algorithms in general aim to adjust the pitch or pitch of musical notes in an audio recording to ensure that they conform to a particular scale or tonal pattern. These algorithms are often used in audio editing software to correct pitch problems in vocal or instrumental performances.

The mathematical principle underlying tonal correction algorithms involves detecting the fundamental frequencies of musical notes in the audio recording and then applying transformations to adjust these frequencies to match a desired tonal scale. Here is a detailed explanation of the process:


* Detection of Fundamental Frequencies:
The first step is to detect the fundamental frequencies of musical notes in the audio recording. This can be done using spectrum analysis techniques, such as the Fourier Transform, which allows you to decompose the audio signal into its frequency components.

* Correlation with Tonal Scale:
Once the fundamental frequencies are identified, they are correlated with a desired tonal scale. This may involve comparing the detected frequencies with the intervals of the musical scale to determine which notes are being played or sung.

* Pitch Deviation Calculation:
Based on the correlation with the tonal scale, the pitch deviation of each note in relation to the desired scale is calculated. This is done by comparing the detected frequencies to the standard frequencies of the notes in the tonal scale.

* Application of Transformations:
With the pitch deviation determined for each note, transformations are applied to adjust their frequencies. This may involve transposing frequencies up or down to match the correct pitch of the note on the tonal scale.

* Transition Smoothing:
To ensure that transitions between adjusted notes sound natural, interpolation techniques such as linear interpolation or spline interpolation are applied to smooth out frequency changes over time.

* Audio Reprocessing and Synthesis:
After adjusting the frequencies, the audio is reprocessed and synthesized to create a new version of the recording with the tonal corrections applied. This may involve overlaying the adjusted notes over the original recording or synthesizing new sounds based on the applied corrections.

This is a simplified summary of the mathematical principle behind tonal correction algorithms. In practice, these algorithms can be quite complex and incorporate a variety of audio signal processing and mathematical modeling techniques to obtain accurate and natural results.

### this COMPLETE SONNET, in stages:

The Python interface constantly receives updates and new features, but it is the shell script that really does the application's work.
This shell script goes through a series of steps to improve vocal quality in a karaoke recording. Let's look at each of these steps in detail:

## Karaoke Video Download:

Using the yt-dlp tool, the script downloads the karaoke video from the provided URL. The video is then renamed and stored locally.


## Audio and Video Recording:

The script begins by capturing audio and video input from a source, such as a webcam, while the karaoke video plays. This is done by using FFmpeg to record input video and audio simultaneously.


## Audio Processing:

After recording, the voice audio is separated from the video and goes through several processing steps:
First, the audio is noise profiled to identify and remove background noise.
Next, a tonal correction algorithm is applied using the Gareus XC42 and Auburn Sound's Graillon plugin, with volume and equalization adjustments to improve vocal quality.
If the audio has clipping problems, a declipper is used to correct these problems.
Finally, the processed audio is combined with the audio from the original video.

## Final Video Rendering:

After processing the audio, the video is readjusted to synchronize with the processed audio. The delay or advance time is calculated based on the difference in duration between the audio and video recording.
The final rendering combines the original video with the processed audio, applying text to the screen to display the remaining time of the song. The resulting video is then saved.

## MP3 Output File Generation:

In addition to the final video, the script also generates a separate MP3 audio file from the final output file. This allows users to have an audio-only version of the karaoke recording.

## Displaying the Video to the User:

Finally, the final video is played back to the user using FFplay, allowing them to preview the final result of the karaoke recording.
In terms of the quality of the approach, This shell script presents a series of techniques for improving vocal quality, including noise reduction, tonal correction and equalization. However, the effectiveness of these techniques may vary depending on the quality of the original recording and the precision of the algorithms used, being constantly improved, seeking not to exaggerate the resources but rather to build a direct solution, which does not require subtractions from a larger set along the way.

### XC 42:

XC 42 is another tonal correction algorithm, developed by Joshua Reiss and Andrew McLeod. It uses advanced audio signal processing techniques to perform tonal correction on vocal recordings.
The XC 42 is designed to provide accurate and efficient tonal correction, with control over parameters such as the extent of correction and the smoothing of transitions between musical notes.

### Graillon:

Graillon is a machine learning-based tonal correction tool developed by Grzegorz Ptasinski. It uses advanced audio signal processing algorithms and machine learning techniques to perform tonal correction on high-quality audio recordings.
The Graillon is known for its ability to correct pitches precisely and naturally, adapting to the vocal style and nuances of the singer's performance. I've decided to remove Graillon for a moment, because it is proprietary.

### Shibata Dithering and Noise Reduction via SoX:

Shibata Dithering is a dithering method used to improve digital audio quality. In the context of scripting, it is applied using SoX (Sound eXchange), a powerful audio processing tool.

The line

```sox "${VOCAL_FILE}" -n trim 0 5 noiseprof "$OUT_DIR"/"$karaoke_name".prof```

creates a noise profile from the first 5 seconds of the previously generated audio file.
Right away,

```sox "${VOCAL_FILE}" "${OUT_VOCAL}" noisered "$OUT_DIR"/"$karaoke_name".prof 0.2 dither -s -f shibata```

applies noise reduction using the created noise profile and applies Shibata Dithering to improve audio quality.

### Gareus XC42 Vocal Tuning Algorithm:

Gareus XC42 is a vocal tuning algorithm developed by Robin Gareus. It is used to adjust and enhance the quality of voices in audio recordings. We use the lv2file tool to efficiently and flexibly apply the filter separately.

The line

```lv2file -i "${OUT_VOCAL}" -o "${VOCAL_FILE}" -P Live http://gareus.org/oss/lv2/fat1```

applies this algorithm to the vocal audio file, generating a new, enhanced audio file.


* These algorithms are applied to improve vocal audio quality, reduce noise and adjust specific characteristics of the voice to produce a more pleasant and professional end result.
* Each algorithm has its own function and settings that can be adjusted to meet the specific needs of a karaoke recording. A generic balance was sought that could maintain the naturalness of the result but also serve the purpose of improving the original recording.

## post production with FFMpeg

Here the last filters are applied to clean the audio and finally mix with the downloaded playback. Synchronization is guaranteed from recording, where there is a mechanism to only trigger playback for the user when the file is confirmed to be written by FFMpeg. There is also a *diff_ss* variable that guarantees a forced synchronization adjustment in terms of nanoseconds. It is calculated by the difference in value in Unix Epoch nanoseconds at the start of execution of each process, *$epoch_ff* and *$epoch_ffplay*, using the date format *%s*.*%N*



### preview and mp3

* after all this, FFMpeg is invoked again to create an overlay or xstack of the user filmed with the videos with effects and playback. The program then, if everything went well, plays the final file for preview;

* as a courtesy we generated an MP3 of the performance!

* everything is written to the *./outputs* directory
* downloaded playbacks are cached in *./recordings*

# installation

partially implemented

* before running I recommend looking at *install.sh* to evaluate package requirements, python, etc.;
* *BETAKe.py* is the interface itself, there are few python library requirements. This one calls the main shell script *gammaQ.sh*
* I must have already placed most of the requirements in the installer.

# lame DEMOs by Guzpido

https://Xiclet.com.br

## PORTUGUESE DOCS

# RESUMO DA OPERA

Os algoritmos de correção tonal em geral têm o objetivo de ajustar a afinação ou a altura das notas musicais em uma gravação de áudio para garantir que elas estejam em conformidade com uma determinada escala ou padrão tonal. Esses algoritmos são frequentemente usados em softwares de edição de áudio para corrigir problemas de afinação em performances vocais ou instrumentais.

O princípio matemático subjacente aos algoritmos de correção tonal envolve a detecção das frequências fundamentais das notas musicais na gravação de áudio e, em seguida, a aplicação de transformações para ajustar essas frequências para correspondência com uma escala tonal desejada. Aqui está uma explicação detalhada do processo:


* Detecção de Frequências Fundamentais: 
O primeiro passo é detectar as frequências fundamentais das notas musicais na gravação de áudio. Isso pode ser feito usando técnicas de análise de espectro, como a Transformada de Fourier, que permite decompor o sinal de áudio em suas componentes de frequência.

* Correlação com Escala Tonal: 
Uma vez que as frequências fundamentais são identificadas, elas são correlacionadas com uma escala tonal desejada. Isso pode envolver a comparação das frequências detectadas com os intervalos da escala musical para determinar quais notas estão sendo tocadas ou cantadas.

* Cálculo do Desvio de Afinação: 
Com base na correlação com a escala tonal, é calculado o desvio de afinação de cada nota em relação à escala desejada. Isso é feito comparando as frequências detectadas com as frequências padrão das notas na escala tonal.

* Aplicação de Transformações: 
Com o desvio de afinação determinado para cada nota, são aplicadas transformações para ajustar suas frequências. Isso pode envolver a transposição das frequências para cima ou para baixo para corresponder à afinação correta da nota na escala tonal.

* Suavização de Transições: 
Para garantir que as transições entre as notas ajustadas soem naturais, são aplicadas técnicas de interpolação, como interpolação linear ou interpolação por splines, para suavizar as mudanças de frequência ao longo do tempo.

* Reprocessamento e Síntese de Áudio: 
Após o ajuste das frequências, o áudio é reprocessado e sintetizado para criar uma nova versão da gravação com as correções tonais aplicadas. Isso pode envolver a sobreposição das notas ajustadas sobre a gravação original ou a síntese de novos sons com base nas correções aplicadas.

Este é um resumo simplificado do princípio matemático por trás dos algoritmos de correção tonal. Na prática, esses algoritmos podem ser bastante complexos e incorporar uma variedade de técnicas de processamento de sinais de áudio e modelagem matemática para obter resultados precisos e naturais.

### este SONETO COMPLETO, por etapas:

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

### preview e mp3

* após tudo isso, novamente se invoca o FFMpeg para criar um overlay ou xstack do usuário filmado com os vídeos com efeitos e o playback. O programa então se tudo deu certo, toca o arquivo final para preview;

* por cortesia geramos uma MP3 da performance!

* tudo é gravado no diretório *./outputs*
* os playbacks baixados ficam em cache em *./recordings*

# instalação 

parcialmente implementada

* antes de rodar recomendo olhar o *instalar.sh* para avaliar os requisitos de pacotes, python, etc;
* *BETAKe.py* é a interface em si, são poucos requisitos de biblioteca python. Este que chama o script shell principal *gammaQ.sh*
* a maioria dos requisitos já devo ter colocado no instalador.

# DEMOs fuleiros by Guzpido

https://Xiclet.com.br

