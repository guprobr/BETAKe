

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

