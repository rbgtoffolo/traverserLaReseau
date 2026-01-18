/********************************
**
**       TRAVERSER LA RÉSEAU
**
**
** Rael Bertarelli Gimenes Toffolo
**
** Violocelo e electrônica em tempo real
**
** Main Code
**
** Versão 2026
**/

(
~mainWindow = Window.new("Traverser la Réseau", Rect(10,800,400,300), resizable: false);
~mainWindow.alwaysOnTop = true;
~section1 = Button.new();
~section1.states = [
	["P01", Color.black, Color.white ],
	["P01", Color.white, Color.red ]
];

~section2 = Button.new();
~section2.states = [
	["P02", Color.black, Color.white ],
	["P02", Color.white, Color.red ]
];

~section3 = Button.new();
~section3.states = [
	["P03", Color.black, Color.white ],
	["P03", Color.white, Color.red ]
];

~section4 = Button.new();
~section4.states = [
	["P04", Color.black, Color.white ],
	["P04", Color.white, Color.red ]
];

~section5 = Button.new();
~section5.states = [
	["P05", Color.black, Color.white ],
	["P05", Color.white, Color.red ]
];

~section6 = Button.new();
~section6.states = [
	["P06", Color.black, Color.white ],
	["P06", Color.white, Color.red ]
];

~btnCapturar = Button().states_([
	["Calibrar", Color.white, Color.red(0.6)],
	["Ouvindo", Color.black, Color.yellow]
]).font_((Font(size: 9)));

~btnCapturar.action = {
	if(~detector.isNil or: { ~detector.isRunning.not }, {
		~detector = Synth(\Calibre, [\inChannel, 0]); // Ajuste o 0 para seu canal
	});
	~funcaoCapturar.value;
};


~txtMaxDisplay = StaticText().string_(~maxChelloLevel.asString ++ " dB")
.font_(Font(size:12, bold: true))
.align_(\center)
.background_(Color.grey(0.9));

~inputVU = LevelIndicator.new().style_(\led).stepWidth_(2);
~inputVU.warning_(0.7); // Aproximadamente -6dB
~inputVU.critical_(0.9); // Aproximadamente -3dB

~outputSlider = Slider().value_(1.0);
~inputLevel = Slider().value_(1.0);
~cleanSlider = Slider().value_(1.0);
~sensorSlider = Slider().value_(0.4);


~inputLevel.action = { arg slider;
	~globalInput = slider.value;
	if(~detector.notNil, { ~detector.set(\inputAmplitude, slider.value) });
};

~calibResponder = OSCFunc({ |msg|
	var ampDb = msg[4];

	if (~isCapturando) {
		if (ampDb > ~peakTemporario) { ~peakTemporario = ampDb };
	};

	{
		~inputVU.value = ampDb.linlin(-60, ~maxChelloLevel, 0, 1);
	}.defer;
}, '/ampCalib');

~inputLevel.action = { arg slider;
	~globalInput = slider.value;
};

~cleanSlider.action = { arg slider;
	~cleanSynthOutput.set(\cleanAmp, slider.value);
	~globalClean = slider.value;
};

~outputSlider.action = { arg slider;
	~globalSynthOutputAmp = slider.value;
};

~sensorSlider.action = { arg slider;
	~sensor = slider.value;
};

~mainWindow.layout_(
	HLayout(
		VLayout(~section1.minWidth_(65), ~section2.minWidth_(65), ~section3.minWidth_(65), ~section4.minWidth_(65), ~section5.minWidth_(65), ~section6.minWidth_(65),
			StaticText().string_("__________").align_(\center).minWidth_(65),
			StaticText().string_("Nível Máx:").align_(\center).font_(Font(size:10, bold:true)).minWidth_(65),
			~txtMaxDisplay.minWidth_(65)), // Exibe o valor capturado
		VLayout(StaticText().string_("VU").align_(\center), ~inputVU.minHeight_(200).maxWidth_(50), ~btnCapturar.maxWidth_(50)),

		VLayout(StaticText().string_("in amp").font_(Font(size:10)).align_(\center).minWidth_(38), ~inputLevel),
		VLayout(StaticText().string_("synth").align_(\center).font_(Font(size:10)).align_(\center).minWidth_(38), ~outputSlider),
		VLayout(StaticText().string_("clean").align_(\center).font_(Font(size:10)).align_(\center).minWidth_(38), ~cleanSlider),
		VLayout(StaticText().string_("atk sens").align_(\center).font_(Font(size:10)).align_(\center).minWidth_(38), ~sensorSlider)
	).spacing_(10);
);

if(~vexWin.notNil) { ~vexWin.close };
~mainWindow.front;

~mainWindow.onClose = {
	s.freeAll;
	Window.closeAll;
	OSCdef.freeAll;
	thisProcess.stop;
	//0.exit;
};

~synthReverb = Synth(\reverb, addAction: \addToTail);
~cleanSynthOutput = Synth(\cleanOut, [\cleanAmp, ~globalClean], addAction: \addToTail);

~section1.action = { arg button;
	if (button.value == 1,
		{
			s.unmute;
			s.volume = 0;
			~s1detector = Synth(\Detector, [\limiar, ~sensor.value, \inputAmplitude, ~globalInput]);

			// variaveis globais para controlar o chelloPad

			~sweepScape = 1; // não é necessário mudar. Apenas para looping infinito do Routine. Routine.clear = stop;

			~sweepSpread = 0;
			~sweepPanPosition = 0;
			~sweepAmp = 0.01;
			~density = 10;
			~sweepAmpLevels = [0.1, 0.1, 0.2, 0.25, 0.3, 0.3, 0.3, 0.3, 0.35, 0.35, 0.35]/5; // valores de amplitude do sweep para configurar em um lugar só.
			~fraseAmpLevels = [0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0, 1.0, 1.0]-0.5; // valores de amplitude das 11 frases para configurar em um lugar só.

			// cria o chelloPad - camada principal da seção.
			~playChord =
			Routine
			({
				while ( {~sweepScape == 1},
					{ var
						note,
						amp,
						dur,
						waitTime,
						pan,
						spread
						;

						amp = ~sweepAmp;
						dur = (20).rand;
						note = ~leSacreFreqs.choose;
						waitTime = ~density;
						pan = ~sweepPanPosition;
						spread = ~sweepSpread;

						// For Debug

						//"amp ".post; amp.postln;
						// "dur ".post; dur.postln;
						// "note ".post; note.postln;
						// "waitTime ".post; waitTime.postln;

						//

						Synth(\air, [\freq, note*4, \amp, amp, \dur, dur, \synthOutAmp, ~globalSynthOutputAmp]);
						Synth(\chelloSweep,[\gate, 1, \freq, note, \amp, amp, \dur, dur, \panPosition, pan, \spreadLevel, spread, \synthOutAmp, ~globalSynthOutputAmp]);
						(waitTime).rand.wait;
				});
			});

			~playChord.play; // inicia o chelloPad

			// recebe dados do instrumentista: amplitude e frequência.
			~s1freqSensor = OSCFunc
			(
				{
					arg msg;
					{
						var tempFreq,
						hasFreq,
						amplitude,
						midiFreq,
						freq,
						noteSequence, panPosition
						;

						tempFreq = msg[3];
						hasFreq = msg[4];
						amplitude = msg[6];

						midiFreq = tempFreq.cpsmidi.round;
						freq = midiFreq.midicps;
						panPosition = amplitude.explin(~dinamicLevels[0], ~dinamicLevels[9], 0.0, 1.0);

						// For Debug
						//
						//"midiFreq = ".post;
						//midiFreq.postln;
						//"freq = ".post;
						//freq.postln;
						//	"amplitude = ".post;
						//amplitude.postln;

						case
						{amplitude < ~dinamicLevels[1] }
						{
							~section1TransformedSoft.center = midiFreq;
							noteSequence = ~section1TransformedSoft.path2notes(~myOriginalPath);

							~sweepSpread = 0;
							~sweepPanPosition = -1;
							~density = 10;
							~sweepAmp = ~sweepAmpLevels[0];

							~frase1 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size),
								\dur, Pseq([1.1],noteSequence.size),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[0]).play;

						}

						{ (amplitude > ~dinamicLevels[1]) && (amplitude < ~dinamicLevels[2]) }
						{
							~section1TransformedSoft.center = midiFreq;
							noteSequence = ~section1TransformedSoft.path2notes(~myOriginalPath);

							~sweepSpread = 0.2;
							~sweepPanPosition = -1;
							~density = 9;
							~sweepAmp = ~sweepAmpLevels[1];

							~frase2 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size),
								\dur, Pseq([0.9],noteSequence.size),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[1]).play;
						}

						{ (amplitude > ~dinamicLevels[2]) && (amplitude < ~dinamicLevels[3]) }
						{
							~section1TransformedSoft.center = midiFreq;
							noteSequence = ~section1TransformedSoft.path2notes(~myOriginalPath);

							~sweepSpread = 0.3;
							~sweepPanPosition = -0.5;
							~density = 9;
							~sweepAmp = ~sweepAmpLevels[2];

							~frase3 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size),
								\dur, Pseq([0.9],noteSequence.size),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[2]).play;
						}

						{ (amplitude > ~dinamicLevels[3]) && (amplitude < ~dinamicLevels[4]) }
						{
							~section1TransformedSoft.center = midiFreq;
							noteSequence = ~section1TransformedSoft.path2notes(~myOriginalPath);

							~sweepSpread = 0.4;
							~sweepPanPosition = -0.5;
							~density = 8;
							~sweepAmp = ~sweepAmpLevels[3];

							~frase4 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size),
								\dur, Pseq([0.8],noteSequence.size),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[3]).play;

						}

						{ (amplitude > ~dinamicLevels[4]) && (amplitude < ~dinamicLevels[5]) }
						{

							~section1TransformedCenter.center = midiFreq;
							noteSequence = ~section1TransformedCenter.path2notes(~myOriginalPath);

							~sweepSpread = 0.5;
							~sweepPanPosition = 0;
							~density = 6;
							~sweepAmp = ~sweepAmpLevels[4];

							~frase5 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size),
								\dur, Pseq(Array.fill(noteSequence.size, {1.0.rand}),1),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[4]).play;
						}

						{ (amplitude > ~dinamicLevels[5]) && (amplitude < ~dinamicLevels[6]) }
						{
							~section1TransformedCenter.center = midiFreq;
							noteSequence = ~section1TransformedCenter.path2notes(~myOriginalPath);

							~sweepSpread = 0.5;
							~sweepPanPosition = 0;
							~density = 6;
							~sweepAmp = ~sweepAmpLevels[5];

							~frase6 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size),
								\dur, Pseq(Array.fill(noteSequence.size, {0.9.rand}),1),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[5]).play;
						}

						{ (amplitude > ~dinamicLevels[6]) && (amplitude < ~dinamicLevels[7]) }
						{
							~section1TransformedCenter.center = midiFreq;
							noteSequence = ~section1TransformedCenter.path2notes(~myOriginalPath);

							~sweepSpread = 0.5;
							~sweepPanPosition = 0;
							~density = 6;
							~sweepAmp = ~sweepAmpLevels[6];

							~frase7 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size),
								\dur, Pseq(Array.fill(noteSequence.size, {0.8.rand}),1),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[6]).play;
						}

						{ (amplitude > ~dinamicLevels[7]) && (amplitude < ~dinamicLevels[8]) }
						{
							~section1TransformedCenter.center = midiFreq;
							noteSequence = ~section1TransformedCenter.path2notes(~myOriginalPath);

							~sweepSpread = 0.5;
							~sweepPanPosition = 0;
							~density = 6;
							~sweepAmp = ~sweepAmpLevels[7];

							~frase8 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size),
								\dur, Pseq(Array.fill(noteSequence.size, {0.5.rand}),1),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[7]).play;
						}

						{ (amplitude > ~dinamicLevels[8]) && (amplitude < ~dinamicLevels[9]) }
						{
							~section1TransformedHard.center = midiFreq;
							noteSequence = ~section1TransformedHard.path2notes(~myOriginalPath);

							~sweepSpread = 0.8;
							~sweepPanPosition = 0.6;
							~density = 5;
							~sweepAmp = ~sweepAmpLevels[8];

							~frase9 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size/2),
								\dur, Pseq(Array.fill(noteSequence.size/2, {0.3.rand}),1),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[8]).play;
						}
						{ (amplitude > ~dinamicLevels[9]) && (amplitude < ~dinamicLevels[10]) }
						{
							~section1TransformedHard.center = midiFreq;
							noteSequence = ~section1TransformedHard.path2notes(~myOriginalPath);

							~sweepSpread = 0.8;
							~sweepPanPosition = 0.8;
							~density = 4;
							~sweepAmp = ~sweepAmpLevels[9];

							~frase10 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size/2),
								\dur, Pseq(Array.fill(noteSequence.size/2, {0.2.rand}),1),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[9]).play;
						}

						{ (amplitude > ~dinamicLevels[10])}
						{
							~section1TransformedHard.center = midiFreq;
							noteSequence = ~section1TransformedHard.path2notes(~myOriginalPath);

							~sweepSpread = 1;
							~sweepPanPosition = 1;
							~density = 3;
							~sweepAmp = ~sweepAmpLevels[10];

							~frase11 = Pbind(
								\instrument, \chelloPizz,
								\freq, Pseq((noteSequence.scramble.midicps),noteSequence.size/2),
								\dur, Pseq(Array.fill(noteSequence.size/2, {0.1.rand}),1),
								\panPosition, Pwhite(panPosition*(-1), panPosition),
								\synthOutAmp, ~globalSynthOutputAmp,
								\amp, ~fraseAmpLevels[10]).play;
						}

					}.defer;

				},'/detector'
			)
		},

		{   ~s1detector.free;
			~s1freqSensor.free;
			~playChord.clear;
		}
	);
};// end of button 1

~section2.action = { arg button;
	if (button.value == 1,
		{
			var section2TempFreq = 0;
			~section1.valueAction = 0;
			~density = 10;
			~sweepScape = 0;

			~s2detector = Synth(\Detector2, [\inputAmplitude, ~globalInput, \triggerSpeed, 8]);

			~s2freqSensor = OSCFunc
			(
				{
					arg msg;
					{
						var tempFreq,
						hasFreq,
						amplitude,
						midiFreq,
						freq,
						s2myNote,
						s2myPath
						;

						tempFreq = msg[3];
						hasFreq = msg[4];
						amplitude = msg[6];
						midiFreq = (tempFreq.cpsmidi).round;

						case
						{ (amplitude < ~dinamicLevels[1]) }
						{ // do nothing
						}

						{ (amplitude > ~dinamicLevels[1]) && (amplitude < ~dinamicLevels[4]) }
						{
							if ( midiFreq == section2TempFreq,
								{},
								{

									Synth(\granule,[\gate, 1, \freq, midiFreq.midicps, \density, 20, \graos, 512, \envelope, ~envelopeSine, \amp, 1, \synthOutAmp, ~globalSynthOutputAmp]);
									//		"amp 1 myNote ".post; " - ".post; midiFreq.postln;
									section2TempFreq = midiFreq;
							});
						}

						{ (amplitude > ~dinamicLevels[4]) && (amplitude < ~dinamicLevels[7]) }
						{
							if ( midiFreq == section2TempFreq,
								{},
								{
									s2myPath = ~section1OriginalNet.notes2path([midiFreq]);
									s2myNote = ~section1TransformedSoft.path2notes(s2myPath);
									//		"amp 2 myNote ".post; s2myNote.post; " - ".post; midiFreq.postln;
									Synth(\granule,[\gate, 1, \freq, s2myNote.midicps, \density, 10, \graos, 250, \envelope, -1, \amp, 1, \synthOutAmp, ~globalSynthOutputAmp]);
									section2TempFreq = midiFreq;
							});
						}

						{ (amplitude > ~dinamicLevels[7] ) }
						{
							if ( midiFreq == section2TempFreq,
								{},
								{
									s2myPath = ~section1OriginalNet.notes2path([midiFreq]);
									s2myNote = ~section1TransformedHard.path2notes(s2myPath);
									//		"amp 3 myNote ".post; s2myNote.post; " - ".post; midiFreq.postln;
									Synth(\granule,[\gate, 1, \freq, s2myNote.midicps, \density, 3, \graos, 500, \envelope, ~envelopePerc, \amp, 1, \synthOutAmp, ~globalSynthOutputAmp]);
									section2TempFreq = midiFreq;
							});
						}
					}.defer;

				},'/detector2'
			)
		},

		{
			~s2detector.free;
			~s2freqSensor.free;

		}
	)
}; // end of button 2

~section3.action = { arg button;
	if (button.value == 1,
		{
			~section2.valueAction = 0;

			~s3detector = Synth(\Detector2, [\inputAmplitude, ~globalInput, \triggerSpeed, 8 ]);

			~isPlaying = 0;
			~s3ampSensor = OSCFunc(
				{ arg msg;
					{
						var amplitude,
						pegaAcorde;

						amplitude = msg[6];
						pegaAcorde = amplitude.linlin(~dinamicLevels[1],~dinamicLevels[9],0,1728).asInteger;

						if (amplitude < ~dinamicLevels[1],
							{~s3arrayToPlay = [0];
								if (~isPlaying == 1, {},{

									Synth(\crack,
										[\gate, 1,\dur, [5,7,9,10].choose,\amp, [0.5,0.8,1.0].choose,
											\file, [~crack01Buffer, ~crack02Buffer].choose,
											\start, (120.0).rand,\transpose, [0.4,0.5,0.6,0.7].choose, \panstart, rrand(-1.0,1.0), \panend, rrand(-1.0,1.0), \room, rrand(0.3, 0.9)] );
									~isPlaying = 1

								});

							},
							{~s3arrayToPlay = ~s3arrayAcordes[pegaAcorde] ?? [60];
						});

						~s3old = 0;
						~s3arrayToPlay = ~s3arrayToPlay.asSet.asArray;

						~s3arrayToPlay.do({
							arg new;
							var pan;
							pan = amplitude.linlin(~dinamicLevels[1], ~dinamicLevels[9], 0.0, 1.0); // quando mais forte mais longe do centro;
							pan = pan * [-1,1].choose; // escolhe mais a esquerda ou direita.
							if (new != 60 ,{
								if (new != ~s3old, {
									Synth(\chelloSweep, [\gate,1,\freq, new.midicps, \dur, [5,3,2,1].choose, \amp,amplitude.dbamp, \synthOutAmp, ~globalSynthOutputAmp, \panPosition, pan]); ~isPlaying = 0;
								}
								,{~s3old=new;});
							},{});
						});
					}.defer;
			},'/detector2', s.addr);
		},

		{
			~s3detector.free;
			~s3ampSensor.free;
		}
	)
};  	//end of button 3

~section4.action = { arg button;
	if (button.value == 1,
		{
			~section3.valueAction = 0;

			~s4detector = Synth(\Detector, [\inputAmplitude, ~globalInput, \triggerSpeed, 5]);

			~s4freqSensor = OSCFunc
			(
				{
					arg msg;
					{
						var tempFreq,
						hasFreq,
						amplitude,
						midiFreq,
						freq,
						noteSequence
						;

						tempFreq = msg[3];
						hasFreq = msg[4];
						amplitude = msg[6];

						midiFreq = tempFreq.cpsmidi.round;
						freq = midiFreq.midicps;

						// for Debug
						//"midiFreq = ".post;
						//midiFreq.postln;
						//"freq = ".post;
						//freq.postln;
						// "amplitude = ".post;
						// amplitude.postln;

						case
						{amplitude <= ~dinamicLevels[5] }
						{
							~leSacreTransformedSoft.do({ arg i;
								var tempFreq;
								tempFreq = ([0.5,1,2,4].choose)*(i.midicps);
								Synth(\air, [\freq, tempFreq, \amp, amplitude.dbamp*10, \dur, amplitude.linlin(~dinamicLevels[1],~dinamicLevels[10],15,5), \synthOutAmp, ~globalSynthOutputAmp])
							});

						}

						{ (amplitude > ~dinamicLevels[5]) && (amplitude < ~dinamicLevels[7]) }
						{
							~leSacreMidi.do({ arg i;
								var tempFreq;
								tempFreq = ([0.5,1,2,4].choose)*(i.midicps);
								Synth(\air, [\freq, tempFreq, \amp, amplitude.dbamp*5, \dur, amplitude.linlin(~dinamicLevels[1],~dinamicLevels[10],10,5), \synthOutAmp, ~globalSynthOutputAmp])
							});
						}

						{ (amplitude >= ~dinamicLevels[7]) }
						{
							~leSacreTransformedHard.do({ arg i;
								var tempFreq;
								tempFreq = ([0.5,1,2,4].choose)*(i.midicps);
								Synth(\air, [\freq, tempFreq, \amp, amplitude.dbamp*3, \dur, amplitude.linlin(~dinamicLevels[1],~dinamicLevels[10],10,3), \synthOutAmp, ~globalSynthOutputAmp])
							});

						}
					}.defer;
				},'/detector'
			)
		},

		{
			~s4detector.free;
			~s4freqSensor.free;
	});
}; //end of button 4


~section5.action = { arg button;
	if (button.value == 1,
		{
			~section4.valueAction = 0;
			~s5Delay.free;
			~s5ploted = 0;
			~s5detector = Synth(\Detector, [\limiar, ~sensor.value, \inputAmplitude, ~globalInput]);
			~s5freqSensor = OSCFunc
			(
				{
					arg msg;
					{
						var pegaAcorde,
						amplitude
						;

						if (~s5ploted == 0, {

							~s5ploted = 1;
							amplitude = msg[6];
							pegaAcorde = amplitude.linlin(~dinamicLevels[0],~dinamicLevels[9],0,1728);
							~s5acorde = ~s3arrayAcordes[pegaAcorde].asSet.asArray.sort;

							if (amplitude < ~dinamicLevels[1], {}, {
								if(~vexWin.notNil) { ~vexWin.close };
								~drawScore.value(~s5acorde);

							});

						}, {});
					}.defer;
				},'/detector'
			)
		},

		{
			~s5detector.free;
			~s5freqSensor.free;
			~s5Delay = Synth(\DelayCombo, [\gate, 1, \inputAmplitude, ~globalInput, \synthOutAmp, ~globalSynthOutputAmp]);
	});
}; // end of button 5

~section6.action = { arg button;
	if (button.value == 1,
		{
			~s5detector.free;
			~s5freqSensor.free;
			~s5Delay.free;
			if(~vexWin.notNil) { ~vexWin.close };

			~s6detector = Synth(\Detector, [\limiar, ~sensor.value, \inputAmplitude, ~globalInput]);
			~s6freqSensor = OSCFunc(
				{
					arg msg;
					{
						var pegaAcorde,
						amplitude,
						tempFreq
						;
						~s5ploted = 1;
						tempFreq = msg[3];
						amplitude = msg[6];

						Synth(\air, [\freq, tempFreq*2, \amp, amplitude.dbamp*5, \dur, amplitude.linlin(~dinamicLevels[1],~dinamicLevels[10],10,3), \synthOutAmp, ~globalSynthOutputAmp]);

					}.defer;

				},'/detector'
			)

		},

		{
			~s6detector.free;
			~s6freqSensor.free;
			s.mute;
		};
	)
}
// end of code
)






