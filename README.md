(docs em pt_BR seguem após)
a Karaoke video PLAYER with performance RECORDER for Linux. 
* just a Shell script karaoke: vocal enhanced effects, pitch correction, auto-download YouTube playbacks + final mix/video render 
* based on FFMpeg + LV2 plugins
*AlphaQ - BETAke - now gammaQ v3*

# OPERA SUMMARY

Tonal correction algorithms in general aim to adjust the pitch or pitch of musical notes in an audio recording to ensure that they conform to a particular scale or tonal pattern. These algorithms are often used in audio editing software to correct pitch problems in vocal or instrumental performances.

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
The Graillon is known for its ability to correct pitches precisely and naturally, adapting to the vocal style and nuances of the singer's performance.

# v3.0 - gammaQ.sh


* Receiving Parameters: The script now receives 4 parameters: the karaoke name, the video URL and the beta directory path, now the device v4l2 /dev/video configured in *python launcher*;

* Directory Configuration: Defines directories to store recordings and output files, creating them if they do not exist.

* Colorecho function: Defines a function to print colored messages on the terminal.

* kill_parent_and_children function: Defines a function to kill the parent process and all its children.

* render_display_progress function: Defines a function to display progress using the estimated file size.

* generate_mp3 function: Defines a function to generate an MP3 file from an MP4 file.

* Obtaining Audio Information: Obtains standard system audio and microphone information.

* Updating and Downloading YouTube Video: Updates the YouTube video downloader program (yt-dlp) and downloads the specified YouTube video, saving it to the recordings directory.

* Video Format Check and Conversion: Checks and converts the downloaded video format to ensure compatibility.

* Recording Confirmation Message: Displays a message to confirm karaoke recording.

* Video and Audio Recording: Start recording video and audio from the system's default device.

* Recording Progress Display: Displays a progress bar indicating recording progress.

* Audio Post-Production: Apply filters and audio adjustments, such as dithering, noise reduction and vocal adjustment.

* Final Video Rendering: Combines the post-produced audio with the original video, applying necessary filters and adjustments.

* Generating MP3 File: Generates an MP3 file from the final rendered video.

* Final Video Display: Displays the finished video in the media player.

The script performs several steps to process and produce a complete karaoke from a YouTube video, including downloading, recording, audio post-production, and rendering the final video.

## mastering with SoX, LV2 and FFMpeg complex filter

Before rendering the video that has already been mixed and mastered, some filters are applied through *stand-alone* binaries to the file with the recorded vocals. Over time I noticed that it was more advantageous to divide and conquer, that is, not trying to solve everything in the same FFMpeg pipeline as there would be no compatibility or availability of complex filters to achieve the quality with the desired efficiency.

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

### Auburn Sound's Graillon Vocal Tuning Algorithm:

Graillon is an audio processing plugin developed by Auburn Sounds used to adjust and modify voices.

The line
```
lv2file -i "${OUT_VOCAL}" -o "${VOCAL_FILE}" -P Younger\ Speech -p p9:1.00 -p p20:2.00 -p p15:0.509 -p p17:1.000 -p p18:1.00 -c 1 :input_38 -c 2:input_39 https://www.auburnsounds.com/products/Graillon.html40733132#in1out2
```
applies the Graillon plugin to the vocal audio file, with different adjustment parameters specified, also using the *lv2file* tool.

* These algorithms are applied to improve vocal audio quality, reduce noise and adjust specific characteristics of the voice to produce a more pleasant and professional end result.
* Each algorithm has its own function and settings that can be adjusted to meet the specific needs of a karaoke recording. A generic balance was sought that could maintain the naturalness of the result but also serve the purpose of improving the original recording.

## post production with FFMpeg

Here the last filters are applied to clean the audio and finally mix with the downloaded playback. Synchronization is guaranteed from recording, where there is a mechanism to only trigger playback for the user when the file is confirmed to be written by FFMpeg. There is also a *diff_ss* variable that guarantees a forced synchronization adjustment in terms of nanoseconds. It is calculated by the difference in value in Unix Epoch nanoseconds at the start of execution of each process, *$epoch_ff* and *$epoch_ffplay*, using the date format *%s*.*%N*

### Audio Configuration:

```
[0:a]volume=volume=0.35, aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo, aresample=resampler=soxr:osf=s16[playback];
```
This part of the code is responsible for configuring the audio coming from the first input (index [0:a]), the downloaded playback;
```
volume=0.35
```
Sets the audio volume to 35% of the original volume. Absolutely all playbacks from the karaoke communities on You Tube have an unnecessary volume boost that we compensate for in this forced way;

```
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo
```

Sets the sampling format (fltp), sample rate (44100 Hz), and channel layout (stereo), for standardization and to mix the two tracks compatible.

```
aresample=resampler=soxr:osf=s16
```

Applies a sample resize using the SoX Resampler (soxr) resampler to convert the audio to a 16-bit sample format.

### Vocal Audio Processing:
```
[1:a] adeclip, compensationdelay, alimiter, speechnorm, acompressor, aecho=0.8:0.8:56:0.33, treble=g=4, aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo, aresample=resampler=soxr :osf=s16:precision=33[vocals];
```
This part processes the audio coming from the second input (index [1:a]), which is the vocal audio.

* adeclip, compensationdelay, alimiter, speechnorm, acompressor: Apply a series of filters and audio effects, such as distortion removal, delay compensation, limiting, volume normalization and compression.

* aecho=0.8:0.8:56:0.33: Adds a very slight echo to the audio with the specified parameters.
* treble=g=4: Adjusts the treble level of the audio.

```
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo
```

Sets the sampling format, sample rate, and channel layout of vocal audio.

```
aresample=resampler=soxr:osf=s16:precision=33
```

Applies sample resizing to vocal audio using SoX Resampler.

### Audio Merging:
```
[playback][vocals] amix=inputs=2:weights=0.45|0.56;
```
Merges the processed playback and vocal audios (defined previously) using the amix function, where inputs=2 indicates that there are two inputs to be merged and weights=0.45|0.56 specifies the weights of each input in the final merge.

### Video Generation:
```
waveform, scale=s=640x360[v1]; gradients=n=7:s=640x360, format=rgba[vscope]; [0:v] scale=s=640x360[v0]; [v1][vscope] xstack=inputs=2, scale=s=640x360[badcoffee]; [v0][badcoffee] vstack=inputs=2, scale=s=640x480;
```
This part sets up the video.

* waveform: Generates an audio waveform. In the final MP4 it is the monochrome frame in the lower left corner.
* gradients: Creates visual gradients. In the final MP4 it is the colored frame to the right of the waveforms.
* [0:v] scale=s=640x360[v0]: Resizes the original video recording of the user singing, to a resolution of 640x360.
* [v1][vscope] xstack=inputs=2: Stacks waveform and gradient videos horizontally, along with playback.
* [v0][badcoffee] vstack=inputs=2: Stacks the resized original video and the xstack result vertically.
* scale=s=640x480: Scales the final video to a resolution of 640x480.

These settings combine audio and video processing to produce a final result that includes audio adjustments, blending of different audio sources, and visual effects applied to the video.

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

Antes de renderizar o vídeo que já mixa e masteriza, alguns filtros são aplicados por meio de binários *stand-alone* no arquivo com os vocais gravados. Com o tempo notei que era mais vantajoso dividir para conquistar, ou seja, não tentar resolver tudo na mesma pipeline de FFMpeg pois não haveria compatibilidade ou disponibilidade de filtros complexos para alcançar a qualidade com a eficiência desejada.

### Shibata Dithering e Redução de Ruído via SoX:

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

O Gareus XC42 é um algoritmo de ajuste vocal desenvolvido por Robin Gareus. Ele é usado para ajustar e aprimorar a qualidade das vozes nas gravações de áudio. Usamos a ferramenta lv2file para aplicar com eficiência e flexibilidade o filtro, separadamente.

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
aplica o plugin Graillon ao arquivo de áudio vocal, com diferentes parâmetros de ajuste especificados, também utilizando a ferramenta *lv2file*.

* Esses algoritmos são aplicados para melhorar a qualidade do áudio vocal, reduzir o ruído e ajustar características específicas da voz para produzir um resultado final mais agradável e profissional.
* Cada algoritmo tem sua própria função e configurações que podem ser ajustadas para atender às necessidades específicas de uma gravação de karaokê. Buscou-se um equilibrio genérico que pudesse manter a naturalidade do resultado mas também atendesse o propósito de aperfeiçoar a gravação original.

## pós produção com FFMpeg

Aqui se aplicam os últimos filtros para limpeza do audio e finalmente a mixagem com o playback baixado. A sincronia é garantida desde a gravação, onde existe um mecanismo de somente disparar o playback para o usuário quando o arquivo está confirmadamente sendo escrito pelo FFMpeg. Existe ainda uma variável *diff_ss* que garante em termos de nanosegundos um ajuste forçado de sincronia. Ela é calculada pela diferença de valor em nanosegundos do Unix Epoch do início de execução de cada processo, *$epoch_ff* e *$epoch_ffplay*, usando o formato de data *%s*.*%N*

### Configuração do Áudio:

```
[0:a]volume=volume=0.35, aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo, aresample=resampler=soxr:osf=s16[playback];
```
Esta parte do código é responsável por configurar o áudio proveniente da primeira entrada (índice [0:a]), o playback baixado;
```
volume=0.35
```
Define o volume do áudio para 35% do volume original. Absolutamente todos os playbacks das comunidades de karaoke no You Tube tem um boost desnecessário de volume que compensamos dessa forma forçada;

```
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo
```

Define o formato de amostragem (fltp), a taxa de amostragem (44100 Hz) e o layout de canal (estéreo), para padronização e para mixar as duas faixas de forma compatível.

```
aresample=resampler=soxr:osf=s16 
```

Aplica um redimensionamento de amostra usando o resampler SoX Resampler (soxr) para converter o áudio para um formato de amostra de 16 bits.

### Processamento do Áudio Vocal:
```
[1:a] adeclip, compensationdelay, alimiter, speechnorm, acompressor, aecho=0.8:0.8:56:0.33, treble=g=4, aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo, aresample=resampler=soxr:osf=s16:precision=33[vocals];
```
Esta parte processa o áudio proveniente da segunda entrada (índice [1:a]), que é o áudio vocal.

* adeclip, compensationdelay, alimiter, speechnorm, acompressor: Aplicam uma série de filtros e efeitos de áudio, como remoção de distorção, atraso de compensação, limitação, normalização de volume e compressão.

* aecho=0.8:0.8:56:0.33: Adiciona um eco bem leve ao áudio com os parâmetros especificados.
* treble=g=4: Ajusta o nível de agudos do áudio.

```
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo
```

Define o formato de amostragem, taxa de amostragem e layout de canal do áudio vocal.

```
aresample=resampler=soxr:osf=s16:precision=33
```

Aplica o redimensionamento de amostra ao áudio vocal usando o SoX Resampler.

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

* waveform: Gera uma forma de onda do áudio. No MP4 final ele é o quadro monocromático do canto inferior esquerdo.
* gradients: Cria gradientes visuais. No MP4 final ele é o quadro colorido ao lado direito dos waveforms.
* [0:v] scale=s=640x360[v0]: Redimensiona o vídeo original da gravação do usuário cantando, para uma resolução de 640x360.
* [v1][vscope] xstack=inputs=2: Empilha os vídeos da forma de onda e dos gradientes horizontalmente, junto com o playback.
* [v0][badcoffee] vstack=inputs=2: Empilha o vídeo original redimensionado e o resultado do xstack verticalmente.
* scale=s=640x480: Redimensiona o vídeo final para uma resolução de 640x480.

Essas configurações combinam processamento de áudio e vídeo para produzir um resultado final que inclui ajustes de áudio, mesclagem de diferentes fontes de áudio e efeitos visuais aplicados ao vídeo.

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

