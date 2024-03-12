#### V1.69A


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


Aqui está a explicação detalhada do comando:

1. `-y`: Sobrescreve o arquivo de saída sem perguntar.
2. `-hide_banner`: Esconde o banner de apresentação do ffmpeg.
3. `-i ${1}_voc.wav -i ${1}.wav`: Define os arquivos de entrada, onde `${1}_voc.wav` é o arquivo de áudio do vocal e `${1}.wav` é o outro arquivo de áudio.
4. `-filter_complex`: Define um filtro complexo, permitindo múltiplas entradas e saídas.
5. `[0:a]`: Indica que estamos operando na primeira entrada de áudio (o vocal).
6. `adeclip`: Remove a distorção do áudio (clipping).
7. `anlmdn=s=25`: Aplica o filtro de redução de ruído anlmdn com uma sensibilidade de 25.
8. `compand`: Aplica a expansão e compressão dinâmica do áudio para ajustar o volume em diferentes partes do áudio.
9. `speechnorm`: Normaliza o volume do áudio, especificamente projetado para a fala.
10. `ladspa=tap_autotalent:plugin=autotalent`: Aplica o plugin Autotalent usando o Ladspa para ajustar o tom do vocal.
11. `treble=g=5`: Ajusta o tom de agudos do áudio em 5dB.
12. `equalizer`: Aplica equalização de áudio para ajustar as frequências em diferentes bandas.
13. `firequalizer`: Aplica um equalizador paramétrico gráfico para ajustar as características tonais do áudio.
14. `ladspa=sc4_1882`: Aplica o plugin SC4 usando o Ladspa para controle de dinâmica (compressão).
15. `loudnorm`: Normaliza o volume do áudio para padrões específicos de intensidade, faixa dinâmica e pico.
16. `aecho`: Adiciona eco ao áudio.
17. `aformat`: Define o formato de áudio de saída.
18. `aresample`: Realiza a amostragem do áudio.
19. `[enhanced]`: Nome da saída do filtro complexo.
20. `[1:a]`: Indica que estamos operando na segunda entrada de áudio (o áudio principal).
21. `loudnorm`: Normaliza o volume do áudio para padrões específicos de intensidade, faixa dinâmica e pico.
22. `[audio]`: Nome da saída da segunda entrada de áudio.
23. `amix=inputs=2:weights=0.4|0.6`: Mistura os dois fluxos de áudio com pesos diferentes.
24. `-ar 44100`: Define a taxa de amostragem de saída como 44100 Hz.
25. `${1}_go.wav`: Nome do arquivo de saída.
26. `&& mplayer ${1}_go.wav`: Reproduz o arquivo de saída usando o mplayer após a conclusão do processo.

Este comando realiza uma série de operações de processamento de áudio para melhorar a qualidade do vocal e do áudio principal, incluindo remoção de clipping, redução de ruído, normalização de volume, ajuste de tom, equalização e compressão dinâmica, entre outros.

O resultado final é salvo com o nome ${1}_go.wav com as melhorias especificadas aplicadas.

* Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas.
* Você pode fazer isso usando o filtro aresample do FFmpeg
 
* Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. 
* Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado.
* Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
