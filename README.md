#### V1.69 B


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

### explicação do comando da última versão

ffmpeg -y -hide_banner -i ${1}_voc.wav -i ${1}.wav -filter_complex "

# Aplicando filtros de processamento de áudio para o arquivo de voz (${1}_voc.wav):
'''
[0:a] # Stream de áudio de entrada (voz)
adeclip, # Remover clipe
anlmdn=s=55, # Redução de ruído usando anlmdn com uma sensibilidade de 55
compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7, # Compressão de amplitude
speechnorm=e=8:r=0.0001:l=1, # Normalização de volume de fala
ladspa=tap_autotalent:plugin=autotalent:c=440 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0.000 0 0.000 0.000 0.000 1.0, # Aplicação do filtro autotalent para ajuste fino do tom
aecho=0.8:0.9:45:0.3, # Adicionando um leve eco
treble=g=5, # Ajuste de tons altos
equalizer=f=150:width_type=h:width=100:g=3, # Equalização de frequência para tons baixos
equalizer=f=800:width_type=h:width=100:g=-3, # Equalização de frequência para tons médios
equalizer=f=5000:width_type=h:width=100:g=3, # Equalização de frequência para tons altos
afftdn=nr=12:nf=-50:nt=w:om=o:adaptivity=0.5:floor_offset=1.0:band_multiplier=1.25, # Denoiser FFT
ladspa=fast_lookahead_limiter_1913:plugin=fastLookaheadLimiter:c=-3 -3 0.1, # Limitador de antecipação rápida
ladspa=sc4_1882:plugin=sc4:c=0.5 50 100 -20 10 5 12, # Compressor SC4
loudnorm=I=-16:LRA=11:TP=-1.5, # Normalização de volume
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo, # Formatação do áudio de saída (taxa de amostragem, formato de áudio e layout de canal)
aresample=resampler=soxr:osf=s16[enhanced]; # Redimensionamento e resampling do áudio de saída
'''
# Adicionando efeitos ao arquivo de música (${1}.wav):
'''
[1:a] # Stream de áudio de entrada (música)
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo, # Formatação do áudio de entrada
aresample=resampler=soxr:osf=s16[audio]; # Redimensionamento e resampling do áudio de entrada
'''
# Misturando os streams de áudio de voz e música com pesos específicos:
'''
[audio][enhanced]amix=inputs=2:weights=0.4|0.6; # Mistura de áudio com pesos

" -ar 44100 ${1}_go.wav && mplayer ${1}_go.wav; # Taxa de amostragem final e reprodução do arquivo de saída
'''
O resultado final é salvo com o nome ${1}_go.wav com as melhorias especificadas aplicadas.

## explicação de cada filtro

adeclip: Remove distorções de clipe do áudio, melhorando a qualidade do som.

anlmdn: Aplica redução de ruído usando o algoritmo ANLMDN, com uma sensibilidade de 55, reduzindo o ruído indesejado no áudio.

compand: Aplica compressão e expansão de amplitude para suavizar as variações de volume no áudio.

speechnorm: Normaliza o volume da fala, garantindo que o nível de áudio seja consistente em toda a gravação.

ladspa=tap_autotalent: Aplica o filtro de autotalent para ajustar sutilmente o tom da voz para a nota A4 (440 Hz) sem alterar drasticamente a afinação.

aecho: Adiciona um leve eco ao áudio, criando um efeito espacial sutil.

treble: Ajusta os tons altos no áudio, melhorando a clareza e a nitidez.

equalizer: Aplica equalização de frequência para ajustar os tons baixos, médios e altos do áudio, melhorando o equilíbrio tonal.

afftdn: Usa a técnica FFT para remover o ruído do áudio, ajustando os parâmetros de redução de ruído, nível de ruído, tipo de ruído, entre outros.

ladspa=fast_lookahead_limiter_1913: Aplica um limitador de antecipação rápida para controlar os picos de volume, garantindo um áudio consistente e evitando distorções.

ladspa=sc4_1882: Aplica um compressor SC4 para ajustar a dinâmica do áudio, reduzindo a diferença entre os picos de volume e o volume médio.

loudnorm: Normaliza o volume do áudio para garantir que esteja dentro dos limites desejados, evitando que fique muito alto ou muito baixo.

aformat: Formata o áudio de saída para o formato desejado, especificando a taxa de amostragem, formato de áudio e layout de canal.

aresample: Redimensiona e faz resampling do áudio de saída para garantir a qualidade desejada.

amix: Mistura os streams de áudio de voz e música com pesos específicos para equilibrar os níveis de volume.

* Se os arquivos de áudio de entrada tiverem diferentes frequências de amostragem, é uma boa prática convertê-los para a mesma frequência antes de misturá-los, a fim de evitar distorções e outros problemas.
* Você pode fazer isso usando o filtro aresample do FFmpeg
 
* Essas são as operações realizadas no comando ffmpeg para processar o áudio vocal e instrumental. 
* Cada filtro desempenha um papel específico na manipulação do áudio para alcançar o resultado desejado.
* Os filtros na ordem errada podem prejudicar muito a qualidade do resultado!!!!!
