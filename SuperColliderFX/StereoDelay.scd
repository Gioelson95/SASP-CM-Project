s.boot;

b = Buffer.read(s,"/Users/alessandro/Desktop/CLEAN.aif");

(
SynthDef.new("stereo_delay",
	{
		arg
		// delay parameters
		level = 0.3,  // level of the repetitions, range: 0 - 1
		bpm = 100,    // BPM of the song, range 40 - 200
		rep = 4,     // number of repetitions, range 1 - 8
		tone = 2500,   // tone, low pass filter, range: 1Khz - 6Khz

		// chorus parameters
		mix = 0.75,   // mix btw signal and chorus, range: 0 - 1
		rate = 10,    // speed of the modulation, range: 1hz - 20hz
		depth = 0.5,  // amount of modulation, range: 0 - 1

		// reverb parameters
		blend = 0.3,   // mix btw signal and reverb, range: 0 - 1
		presence = 6500,  // brightness of the reverb, range: 1Khz - 8Khz
		decay = 10;   // time decay, range: 1 - 20

		//var signal = In.ar(2);   // input signal from the audio interface
		var signal = PlayBuf.ar(2, b.bufnum);

		// chorus
		var lfo = SinOsc.kr(freq:rate); // lfo oscillator
		var emphasis = BLowShelf.ar(signal, freq: 410, rs: 0.7, db: 15);  // emphasis filter
		var bbd = DelayL.ar(emphasis,1,depth*lfo);  // modulation
		var de_emphasis = BLowShelf.ar(signal, freq: 410, rs: 0.7, db: -15); // de-emphasis filter

		var chorus_output = signal + mix*de_emphasis;   // mix

		// delay
		// control the input, direct of from the chorus output if it's enabled
		var delay_input = if (~chorus_switch.value == 1,{ chorus_output },{ signal });

		var time_quarter = 60/bpm;  // delay 1/4 after the note
		var time_octave = 60/(2*bpm);  // delay 1/8 after the note
		var feedback = rep*time_quarter;   // feedback of the delay in ms, range: 1/4 - 2 bars

		var delay_right = CombL.ar(delay_input, 1, time_quarter, feedback, level);
		var delay_left = CombL.ar(delay_input, 1, time_octave, feedback, level);
		var delay_right_lp = LPF.ar(delay_right, tone);
		var delay_left_lp = LPF.ar(delay_left, tone);
		var stereo_delay = [delay_left_lp, delay_right_lp];
		var delay_output = delay_input + stereo_delay;

		// reverb
		var reverb_input = delay_output;   // take the input
		var input_lp = LPF.ar(reverb_input, presence);   // control brigthness
		var pre_delayed = DelayN.ar(input_lp, 0.1, 0.048);  // predelay

		// reflections
		var early_refl = Mix.ar(Array.fill(7,
			            { CombL.ar(pre_delayed, 0.05, rrand(0.03, 0.05),decay) }));
		var refl;
		var r = 6.do{ refl = AllpassN.ar(early_refl, 0.050, rrand(0.03, 0.05), decay/15) };

		var reverb_output = reverb_input + blend*refl;

		// output of the effects
		var output = if (~reverb_switch.value == 1, { reverb_output },{ delay_output });

		Out.ar(0, output);
    }).send;
)

x = Synth("stereo_delay");

(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 580;
var win_height = 580;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 120;

w = Window("Stereo Digital Delay", Rect(left_padding, top_padding, win_width, win_height)).front;
w.background = Color.blue;
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

// delay controls

~level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	       var level = obj.value.round(0.01);
	       x.set(\level, level);
           });

~time_knob = Knob(w, knob_dim@knob_dim)
.value_(0.375)
.action_({ arg obj;
	       var bpm = obj.value.linexp(0,1,40,200).round(1);
	       x.set(\bpm, bpm);
           });

~feedback_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var rep = obj.value.linexp(0,1,1,8).round(1);
	       x.set(\rep, rep);
           });

~tone_knob = Knob(w, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	       var tone = obj.value.linexp(0,1,1000,7000).round(0.01);
	       x.set(\tone, tone);
           });


~level_label = StaticText(w, knob_dim@30)
.string_("LEVEL")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~time_label = StaticText(w, knob_dim@30)
.string_("TIME")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~feedback_label = StaticText(w, knob_dim@30)
.string_("FEEDBACK")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~tone_label = StaticText(w, knob_dim@30)
.string_("TONE")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

// chorus controls

~chorus_switch = Button(w, knob_dim@30)
.states_([ ["CHORUS", Color.white, Color.gray],["CHORUS", Color.white, Color.red] ])
.font_(Font("Monaco",18));

~mix_knob = Knob(w, knob_dim@knob_dim)
.value_(0.75)
.action_({ arg obj;
	       var mix = obj.value.round(0.01);
	       x.set(\mix, mix);
           });

~rate_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var rate = obj.value.linexp(0,1,1,20).round(0.01);
	       x.set(\rate, rate);
           });

~depth_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var depth = obj.value.round(0.01);
	       x.set(\depth, depth);
           });

~blank_label = StaticText(w, knob_dim@30);

~mix_label = StaticText(w, knob_dim@30)
.string_("MIX")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~rate_label = StaticText(w, knob_dim@30)
.string_("RATE")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~depth_label = StaticText(w, knob_dim@30)
.string_("DEPTH")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

// reverb controls

~reverb_switch = Button(w, knob_dim@30)
.states_([ ["REVERB", Color.white, Color.gray],["REVERB", Color.white, Color.red] ])
.font_(Font("Monaco",18));

~blend_knob = Knob(w, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	       var blend = obj.value.round(0.01);
	       x.set(\blend, blend);
           });

~presence_knob = Knob(w, knob_dim@knob_dim)
.value_(0.9)
.action_({ arg obj;
	       var presence = obj.value.linexp(0,1,1000,8000).round(0.01);
	       x.set(\presence, presence);
           });

~decay_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var decay = obj.value.linexp(0,1,1,20).round(0.01);
	       x.set(\decay, decay);
           });

~blank_label = StaticText(w, knob_dim@30);

~blend_label = StaticText(w, knob_dim@30)
.string_("BLEND")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~presence_label = StaticText(w, knob_dim@30)
.string_("PRESENCE")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~decay_label = StaticText(w, knob_dim@30)
.string_("DECAY")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

)













