/********************************
**
**       TRAVERSER LA RÉSEAU
**
**
** Rael Bertarelli Gimenes Toffolo
**
** Violocelo e electrônica em tempo real
**
** Definições de Synth
**
** Versão 2026
**/


/**************************************************************************/
// Liga Synths
/**************************************************************************/


~busReverb = Bus.audio(s,2);
~mainIn = 0;
~mainOut = 0;

SynthDef.new(\Detector,

	{
		arg inChannel = ~mainIn,
		triggerSpeed = 5,
		limiar = 0.8,
		inputAmplitude = 1
		;

		var ampTrig, ampDb,
		input,
		freq,
		hasFreq,
		chain,
		onsets
		;

		input = SoundIn.ar(inChannel)*inputAmplitude;
		ampTrig = Amplitude.ar(input, attackTime: 0.05, releaseTime: 0.05); // Detecta Amplitude
		ampDb = ampTrig.ampdb.max(-90);
		# freq, hasFreq = Pitch.kr(input,22,60,1800,ampThreshold: 0.01) ; // [c2, a6] // Detecta Frequência

		chain = FFT(~fftBuffer, input);
		onsets = Onsets.kr(chain, limiar, \complex);

		// Quando detecta o ataque envia a frequência e amplitude para o cliente
		SendReply.kr(onsets, '/detector', [freq, hasFreq, ampTrig, ampDb]);


	}
).add;

SynthDef.new(\Detector2,

	{
		arg inChannel = ~mainIn,
		triggerSpeed = 8,
		inputAmplitude = 1
		;

		var ampTrig, ampDb,
		input,
		freq,
		hasFreq,
		onsets
		;

		input = SoundIn.ar(inChannel)*	inputAmplitude;
		ampTrig = Amplitude.ar(input); // Detecta Amplitude
		ampDb = ampTrig.ampdb.max(-90);
		# freq, hasFreq = Pitch.kr(input,22,60,1800,ampThreshold: 0.01) ; // [c2, a6] // Detecta Frequência

		SendReply.kr(Impulse.kr(triggerSpeed),'/detector2',[freq, hasFreq, ampTrig, ampDb]);

	}
).add;

SynthDef.new(\Calibre,

	{
		arg inChannel = ~mainIn,
		triggerSpeed = 20,
		inputAmplitude = 1
		;

		var ampTrig, ampDb,
		input,
		freq,
		hasFreq,
		chain,
		onsets
		;

		input = SoundIn.ar(inChannel)*inputAmplitude;
		ampTrig = Amplitude.ar(input, attackTime: 0.05, releaseTime: 0.05); // Detecta Amplitude
		ampDb = ampTrig.ampdb.max(-90);

		SendReply.kr(Impulse.kr(triggerSpeed), '/ampCalib', [ampTrig, ampDb]);
	}
).add;


SynthDef(\DelayCombo,
	{
		arg gate = 0,
		inChannel = ~mainIn,
		totalTime = 5,
		time1 = 2,
		time2 = 1.3,
		time3 = 0.8,
		inputAmplitude = 1,
		busOut = ~busReverb,
		synthOutAmp = 1
		;

		var input,
		signal,
		signal1,
		signal2,
		signal3,
		output,
		amplitude,
		envelope
		;

		input = SoundIn.ar(inChannel)*inputAmplitude;
		signal1 = Pan2.ar(DelayL.ar(input, totalTime, time1, 0.4), LFNoise1.kr(0.2));
		signal2 = Pan2.ar(DelayL.ar(input, totalTime, time2, 0.25), LFNoise1.kr(0.23));
		signal3 = Pan2.ar(DelayL.ar(input, totalTime, time3, 0.1), LFNoise1.kr(0.16));

		//signal = FreeVerb.ar(signal1+signal2+signal3, 0.7, 0.8, 0.6)*synthOutAmp;
		signal = Splay.ar([signal1, signal2, signal3]);
		Out.ar(busOut,signal*gate*synthOutAmp);
}).add;


SynthDef.new(\chelloSweep,
	{
		arg freq = 65.40639132515,// c2
		amp = 1,
		dur = 1,
		gate = 0,
		panPosition = 0,
		busOut = ~busReverb,
		synthOutAmp = 1
		;

		var output,
		envelope,
		originalFreq = 261.6255653006,
		transposition = 1
		;

		transposition = freq/originalFreq;

		envelope = EnvGen.kr(Env.linen(0,dur/2,dur/2,1), gate: gate, doneAction: 2);
		output =
			PitchShift.ar(
				PlayBuf.ar(1,~chelloBuffer, doneAction:2),
				0.1,
				transposition
				);
		output = output*envelope * amp;

		Out.ar(busOut, Pan2.ar(output,panPosition,synthOutAmp));
}).add;

SynthDef.new(\chelloPizz,
	{
		arg freq = 65.40639132515,// c2
		amp = 1,
		dur = 1,
		panPosition = 0,
		busOut = ~busReverb,
		synthOutAmp = 1
		;

		var output,
		envelope,
		originalFreq = 261.6255653006,
		transposition = 1
		;

		transposition = freq/originalFreq;

		envelope = EnvGen.kr(Env.perc(0.05,dur*2,1,-8), levelScale: 2, doneAction: 2);
		output =

			PitchShift.ar(
				PlayBuf.ar(1,~chelloPizzBuffer, doneAction:2),
				0.1,
				transposition
				);

		output = output * envelope * amp;

		Out.ar(busOut, Pan2.ar(output, panPosition, synthOutAmp));
}).add;

SynthDef(\crack,
	{
		arg file,
		amp = 1,
		gate = 0,
		dur = 5,
		start = 0,
		transpose = 1,
		room = 1,
		synthOutAmp = 1,
		panstart = (-1),
		panend = 1
		;

		var signal,
		envelope,
		panline
		;

		envelope = EnvGen.kr(Env.new([0,1,0],[dur/2,dur/2]), gate, amp, doneAction:2);
		panline = Line.kr(panstart, panend, dur);
		signal = PlayBuf.ar(1, file, transpose, 1,start, doneAction: 2);
		signal = signal *envelope;
		signal = FreeVerb.ar(signal, 0.6, room, 0.3);
		signal = Pan2.ar(signal, panline);
		Out.ar(~mainOut,signal*synthOutAmp);

	}
).add;

SynthDef(\air,
	{
		arg freq = 65.40,
		amp = 1,
		dur = 10,
		busOut = ~busReverb,
		synthOutAmp = 1
		;

		var signal,
		output,
		envelope,
		panPosition
		;

		panPosition = LFNoise1.kr(0.8);

		signal = PinkNoise.ar(1);
		envelope = EnvGen.kr(Env.linen(0.2, dur * 0.7, dur * 0.1), doneAction: 2);
		output = Resonz.ar(signal, freq, 0.005, 30) * amp;
		output = output * envelope;

		Out.ar(busOut, Pan2.ar(output,panPosition, synthOutAmp));
}).add;

SynthDef(\cleanOut, {
	arg cleanAmp=1;

	var sig;
	sig = SoundIn.ar(0);
	Out.ar(~mainOut, Pan2.ar(sig)*cleanAmp)
}).add;

SynthDef(\granule,
	{
		arg	freq = 65.40639132515,
		amp = 1,
		inChannel = 2,
		dur = 4,
		gate = 0,
		density = 20,
		grainSize = 0.2,
		graos = 512,
		envelope = ~envelopeSine,
		busOut = ~busReverb,
		synthOutAmp = 1
		;

		var signal,
		originalFreq = 261.6255653006,
		output,
		env,
		transposition = 1,
		triggerDuration,
		pan
		;

		pan = LFNoise0.kr(1);
		transposition = freq/originalFreq;
		triggerDuration = Dust.kr(density);

		env = EnvGen.kr(Env.linen(0,dur/2,dur/2,1), gate: gate, doneAction: 2);

		signal = GrainBuf.ar(2, triggerDuration, grainSize, ~chelloBuffer, rate: transposition, pos: 0, interp: 2, pan: pan, envbufnum: envelope, maxGrains: graos);
		signal = signal * env * amp;

		Out.ar(busOut,signal*synthOutAmp);
}).add;


SynthDef(\reverb,
	{
		arg inBus = ~busReverb;
		var signal, output;

		signal = In.ar(inBus, 2);
		output = FreeVerb2.ar(signal[0],signal[1],
			mix: 0.7,
			room: 1,
			damp: 0.5,
			mul: 1,
			add: 0)
		;

	Out.ar(~mainOut,output);
}).add;


s.sync;



/**************************************************************************/

"Synths Compilados!".postln;