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

Vou descrever cada uma das técnicas utilizadas no comando e como elas se relacionam, explicando sua relevância e a ordem em que são aplicadas:

anlmdn (Noise Reduction):

O filtro ANLMDN é usado para reduzir o ruído de fundo indesejado presente na gravação de áudio, especialmente em faixas vocais. Ele usa um algoritmo avançado para identificar e atenuar o ruído sem afetar negativamente o sinal de áudio principal.
ladspa (Auto-Tune):

O plug-in LADSPA com o autotune é empregado para ajustar automaticamente o tom e a afinação do áudio vocal. Os parâmetros fornecidos (como frequência central, amplitude e largura do filtro) controlam a intensidade e a natureza do efeito de afinação.
deesser (Sibilance Reduction):

O filtro deesser é usado para atenuar as frequências de sibilância excessivas presentes na voz, como "s" e "sh". Ele suaviza essas frequências agudas para tornar o áudio mais agradável ao ouvido.
dynaudnorm (Dynamic Audio Normalization):

Esse filtro normaliza dinamicamente o volume do áudio, ajustando os níveis de amplitude ao longo do tempo. Ele garante uma consistência de volume adequada em toda a faixa de áudio, evitando picos e quedas repentinas.
speechnorm (Speech Normalization):

O speechnorm é usado para normalizar o nível de áudio específico da fala. Ele ajusta a intensidade do áudio para um nível padronizado, o que é útil para garantir uma audição confortável e consistente em diferentes tipos de gravações vocais.
compand (Compression and Expansion):

O compand é um filtro que combina compressão e expansão para controlar a faixa dinâmica do áudio. Ele reduz os picos de volume excessivos e aumenta os sons mais silenciosos, resultando em um áudio mais equilibrado e consistente.
equalizer (Equalization):

Esse filtro é usado para ajustar a resposta de frequência do áudio, realçando ou atenuando determinadas frequências conforme necessário. No caso deste comando, ele ajusta as frequências na faixa de 100 Hz a 15 kHz para melhorar a qualidade geral do áudio.
highpass e lowpass (High-pass e Low-pass Filters):

Esses filtros removem frequências indesejadas acima (high-pass) e abaixo (low-pass) de determinados limites de frequência. Eles são usados para limpar o áudio de ruídos de baixa frequência (como zumbidos) e de alta frequência (como chiados), melhorando a clareza geral do som.
stereowiden (Stereo Widening):

Esse filtro amplia a imagem estéreo do áudio, aumentando a separação entre os canais esquerdo e direito. Ele cria uma sensação mais ampla e espacializada de som, o que pode melhorar a experiência auditiva.
acontrast (Audio Contrast):

O acontrast é usado para ajustar o contraste do áudio, realçando diferenças de volume entre elementos sonoros específicos. Ele pode ajudar a destacar certos elementos musicais ou vocais em relação ao resto da mixagem.
alimiter (Audio Limiter):
Esse filtro limita o volume máximo do áudio para evitar distorção e estouro. Ele garante que o áudio permaneça dentro de limites seguros de volume, protegendo contra picos repentinos que possam causar danos aos alto-falantes ou prejudicar a qualidade do som.
aformat (Audio Format Conversion):
O aformat converte o formato do áudio para o desejado, especificando a taxa de amostragem, o formato de amostra e o layout de canal desejados.
aresample (Audio Resampling):
Esse filtro é usado para alterar a taxa de amostragem do áudio, garantindo que corresponda ao formato de saída desejado.
Após aplicar esses filtros ao áudio vocal e instrumental, eles são misturados usando o filtro amix, que combina os dois sinais de áudio com pesos especificados (80% para o vocal e 20% para o instrumental) para criar a mixagem final. O resultado é exportado como um arquivo MP3 com o nome ${1}_go.mp3.

Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas. Você pode fazer isso usando o filtro aresample do FFmpeg
 
Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado. Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
