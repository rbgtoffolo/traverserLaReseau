/********************************
**
**       TRAVERSER LA RÉSEAU
**
**
** Rael Bertarelli Gimenes Toffolo
**
** Violocelo e electrônica em tempo real
**
** Variáveis de Ambiente
**
** Versão 2026
**/


// ~leSacreNames = ["c2","f2","a2","c3","d#3","g#3","a3","c4","d#4","g#4","b4","g#5","b5"].namesMidi; tension = 2.4716
~leSacreMidi = [ 36, 41, 45, 48, 51, 56, 57, 60, 63, 68, 71, 80, 83 ];
~leSacreFreqs = [ 65.40639132515, 87.307057858251, 110, 130.8127826503, 155.56349186104, 207.65234878997, 220, 261.6255653006, 311.12698372208, 415.30469757995, 493.88330125612, 830.60939515989, 987.76660251225 ];
~fftBuffer = Buffer.alloc(s, 512);

// ~leSacreTransformedSoft = [ 36, 41, 46, 48, 50, 55, 58, 60, 62, 67, 69, 79, 81 ]; // 8 -> 7, 12 -> 12, 5 -> 5 tension = 1.7140
// ~leSacreTransformedHard = [ 38, 39, 44, 49, 54, 55, 55, 60, 65, 66, 71, 77, 82 ]; // 8 -> 6, 12 -> 11, 5 -> 1 tension = 3.0451

// com eliminação de notas repetidas e algumas duplicações a oitava eliminadas.

~envelopeSine = Buffer.sendCollection(s, (Env.sine(1)).discretize, 1);
~envelopePerc = Buffer.sendCollection(s, (Env.perc(0.001,0.05, curve: -8)).discretize, 1);

~leSacreTransformedSoft = [ 36, 41, 46, 50, 55, 58, 60, 62, 67, 69];
~leSacreTransformedHard = [ 38, 39, 44, 49, 54, 55, 60, 65, 66, 71, 77, 82 ];

~chelloFile = ~traverserPath ++ "soundfiles/cello_C4_mp_ordinario.wav";
~chelloPizzFile = ~traverserPath ++ "soundfiles/cello_C4_pizz.wav";
~crack1 = ~traverserPath ++ "soundfiles/crack01.wav";
~crack2 = ~traverserPath ++ "soundfiles/crack02.wav";

~crack01Buffer = Buffer.read(s, ~crack1);
~crack02Buffer = Buffer.read(s, ~crack2);
~chelloBuffer = Buffer.read(s, ~chelloFile);
~chelloPizzBuffer = Buffer.read(s, ~chelloPizzFile);

~section1OriginalNet = Pousseur(60, 8, 12, 5);
~myOriginalPath = ~section1OriginalNet.notes2path(~leSacreMidi); // find path in this configuration

~section1TransformedSoft = Pousseur(60,7,12,5);
~section1TransformedHard = Pousseur(60,6,11,1);
~section1TransformedCenter = Pousseur(60,8,12,5);

/*************************************************************************

Variáveis da segunda sessão

**************************************************************************/

~s3acordeInicial = [ 36, 41, 45, 48, 56, 57, 60, 63, 68, 71];
~s3eixoInicial = [60,8,12,5];
~s3posicoesInicial;
~s3arrayAcordes = Array.fill(1729,0);
~s3arrayEixos = Array.fill(1729,0);
~s3arrayTensao = Array.fill(1729,0);
~s3arrayOrdenacao = Array.fill(1729,0);
~s3arrayTemporario = Array.fill(1729,0);

~s3calculaTensao;

~s3notasTemporarias;
~s3contadorGeral = 0;

~s3eixoX;
~s3eixoY;
~s3eixoZ;

~s3redeOriginal;
~s3redeTransformada;

~s3tensaoMaxima;
~s3tensaoMinima;

~s3detectorAmplitude;


~s3criaArrays = {
	// Criação dos Arrays de acordes e tensão
	"calculando".postln;
	~s3redeOriginal = Pousseur.new(~s3eixoInicial[0],~s3eixoInicial[1],~s3eixoInicial[2],~s3eixoInicial[3]);
	~s3redeTransformada = Pousseur.new(~s3eixoInicial[0],~s3eixoInicial[1],~s3eixoInicial[2],~s3eixoInicial[3]);
	~s3posicoesInicial = ~s3redeOriginal.notes2path(~s3acordeInicial);

	~s3calculaTensao = HarmonicTension(~s3acordeInicial);
	~s3calculaTensao.nHarmonics= 6;
	~s3calculaTensao.multiply = true;


	~s3arrayEixos[~s3contadorGeral] = [~s3eixoInicial[0],~s3eixoInicial[1],~s3eixoInicial[2],~s3eixoInicial[3]];
	~s3arrayAcordes[~s3contadorGeral] = ~s3acordeInicial;
	~s3arrayTensao[~s3contadorGeral] = ~s3calculaTensao.roughness;
	~s3contadorGeral = 1;

	// looping 3;

	for (1,12,
		{ arg eixoX;

			for (1,12,
				{ arg eixoY;

					for (1,12,
						{ arg eixoZ;
							~s3redeTransformada.center = ~s3eixoInicial[0];
							~s3redeTransformada.int1 = eixoX;
							~s3redeTransformada.int2 = eixoY;
							~s3redeTransformada.int3 = eixoZ;

							~s3arrayEixos[~s3contadorGeral] = [~s3eixoInicial[0],eixoX,eixoY,eixoZ];
							~s3notasTemporarias = ~s3redeTransformada.path2notes(~s3posicoesInicial);
							~s3arrayAcordes[~s3contadorGeral] = ~s3notasTemporarias;
							~s3calculaTensao = HarmonicTension(~s3notasTemporarias);
							~s3arrayTensao[~s3contadorGeral] = ~s3calculaTensao.roughness;
							~s3contadorGeral = ~s3contadorGeral + 1;

						}
					)
				}
			)

	});

	// ~arrayAcordes.postln;
	// ~arrayTensao.postln;

	// ordenar acordes por tensão

	~s3arrayOrdenacao = ~s3arrayTensao.order;

	~s3arrayOrdenacao.do(
		{arg i,z;


			~s3arrayTemporario[z] = ~s3arrayAcordes[i];

	});

	~s3arrayAcordes = ~s3arrayTemporario;
	~s3arrayTensao.sort;
	//arrayAcordes.postln;

	//arrayTensao.plot;

	~s3tensaoMaxima = ~s3arrayTensao.last;
	~s3tensaoMinima = ~s3arrayTensao.first;

	//"tensao Minima = ".post; tensaoMinima.postln;
	//"tensao Maxima = ".post; tensaoMaxima.postln;
	"Done! ".postln;

};

~s3criaArrays.value;

~tempWindow.close;

~globalInput = 1;
~globalClean = 1;
~globalSynthOutputAmp = 1;

~sensor = 0.4;
// Funções responsáveis por criar partituras em p5.

~vexWin = nil;
~vexWeb = nil;

~drawScore = { |midiArray|
	// Usamos a variável global que você já definiu no Setup inicial
	var htmlPath = "file://" ++ ~traverserPath ++ "index.html";

	if(~vexWin.isNil or: { ~vexWin.isClosed }) {
		~vexWin = Window("Traverser la reseau - Rael B. Gimenes", Rect(100, 100, 620, 420)).front;
		~vexWeb = WebView(~vexWin, Rect(0, 0, 620, 420));

		~vexWeb.onJavaScriptMsg = { |view, msg|
			("WEB CONSOLE: " ++ msg).postln;
		};

		~vexWeb.url = htmlPath;

		fork {
			0.8.wait; // Aumentei levemente para estabilidade no Linux
			{ ~vexWeb.runJavaScript("drawScore(" ++ midiArray.asString ++ ")") }.defer;
		};
	} {
		~vexWeb.runJavaScript("drawScore(" ++ midiArray.asString ++ ")");
		~vexWin.front;
	};
};

~closeScore = {
	if(~vexWin.notNil && { ~vexWin.isClosed.not }) {
		~vexWin.close;
		"Janela de partitura fechada.".postln;
	} {
		"A janela já está fechada ou não existe.".postln;
	};
};


// variáveis e função do calibrador

~maxChelloLevel = -14;
~isCapturando = false;
~peakTemporario = -90;

/*~funcaoCapturar = {
    ~peakTemporario = -90;
    ~isCapturando = true;

    {
        ~btnCapturar.states_([["OUVINDO...", Color.black, Color.yellow]]);
        ~txtMaxDisplay.string = "---";
    }.defer;

    fork {
        3.wait;
        ~isCapturando = false;

        // Proteção: só atualiza se detectou algo acima do silêncio (-60dB)
        if (~peakTemporario > -60) {
            ~maxChelloLevel = ~peakTemporario;
        } {
            "Aviso: Sinal muito baixo detectado. Verifique o microfone.".warn;
        };

        {
            ~btnCapturar.states_([["CAPTURAR MÁXIMO", Color.white, Color.red(0.6)]]);
            ~txtMaxDisplay.string = ~maxChelloLevel.round(0.1).asString ++ " dB";
            "--- CAPTURA CONCLUÍDA ---".postln;
            "Novo Máximo: % dB".format(~maxChelloLevel).postln;
        }.defer;
    };
};*/

~funcaoCapturar = {
    ~peakTemporario = -90;
    ~isCapturando = true;

    {
      //  ~btnCapturar.states_([["Ouvindo", Color.black, Color.yellow]]);
        ~txtMaxDisplay.string = "---";
    }.defer;

    fork {
        3.wait;
        ~isCapturando = false;

        if (~peakTemporario > -60) {
            ~maxChelloLevel = ~peakTemporario;

            // --- CRIAÇÃO DOS 10 PATAMARES ---
            // Criamos um array de 10 valores distribuídos linearmente
            // entre o silêncio (-70dB) e o máximo captado (~maxChelloLevel)
            ~dinamicLevels = Array.interpolation(11, -70, ~maxChelloLevel);

        } {
            "Aviso: Sinal muito baixo detectado. Verifique o microfone.".warn;
            // Fallback caso a captura falhe, para não quebrar o código
            ~dinamicLevels = Array.interpolation(11, -70, -14);
        };

        {
          //  ~btnCapturar.states_([["Calibrar", Color.white, Color.red(0.6)]]);
			~btnCapturar.value_(0);
			~txtMaxDisplay.string = ~maxChelloLevel.round(0.1).asString ++ " dB";

            "--- CAPTURA CONCLUÍDA ---".postln;
            "Novo Máximo: % dB".format(~maxChelloLevel.round(0.1)).postln;
            "Array de Patamares (~dinamicLevels):".postln;
            ~dinamicLevels.round(0.1).postcln; // Imprime o array formatado
        }.defer;
		//~detector.free;
      //  ~detector = nil;
    };

};

s.sync;
// carrega próximos arquivos

(~traverserPath ++ "synths.scd").load;
(~traverserPath ++ "traverser_main_code.scd").load;
