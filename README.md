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

Redução de Ruído (ANLMDN):

O filtro ANLMDN é usado para reduzir o ruído de fundo indesejado no áudio vocal. Ele emprega uma técnica adaptativa de filtragem não linear que é eficaz na remoção de ruídos de baixo nível e não estacionários.
Equalização:

O equalizador é usado para ajustar as características de frequência do áudio. Neste caso, estamos realçando as frequências em torno de 800 Hz com uma largura de banda de 100 Hz e atenuando em 3 dB. Isso pode ajudar a realçar certas frequências importantes na voz.
Correção de Afinação (Autotalent):

O plugin Autotalent é utilizado para realizar a correção automática de afinação na voz. Ele ajusta automaticamente a afinação da voz de acordo com os parâmetros especificados.
De-essing:

O filtro de de-essing é usado para reduzir a sibilância ou os sons sibilantes na voz. Isso é feito atenuando as frequências agudas que podem causar sibilância.
Eco:

O filtro de eco adiciona um efeito de eco ao áudio vocal. Ele cria repetições suaves do áudio original, dando uma sensação de espaço e profundidade.
Normalização de Volume:

A normalização de volume é usada para ajustar o nível de volume do áudio vocal. Isso garante que o áudio tenha um volume consistente e adequado para a reprodução.
Compressão/Expansão Dinâmica:

O filtro de compand é usado para controlar a dinâmica do áudio. Ele comprime as partes mais altas do áudio enquanto expande as partes mais baixas, reduzindo assim a faixa dinâmica.
Divisão de Áudio (asplit):

O áudio de entrada é dividido em dois fluxos separados: um que será processado e o outro que será usado como referência para a compressão sidechain.
Compressão Sidechain (sidechaincompress):

Este filtro comprime o áudio de fundo com base na energia do áudio vocal. Isso permite que a voz permaneça audível mesmo quando a música de fundo estiver mais alta.
Mixagem de Áudio (amix):

Finalmente, os áudios comprimidos e não comprimidos são misturados novamente para criar o áudio final. Isso garante que a voz e a música de fundo sejam combinadas de forma equilibrada, levando em consideração a compressão sidechain aplicada.
Salvando o Áudio (${1}_go.mp3 -y):
Salva o áudio finalizado em um arquivo MP3 com o nome especificado.
Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado. Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
