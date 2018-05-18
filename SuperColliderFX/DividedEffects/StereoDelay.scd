Server.default.options.outDevice_("Soundflower (2ch)");
s.boot;

// Set up the server
(
thisProcess.openUDPPort(52000);
NetAddr("192.168.2.7",52000);
)

b = Buffer.read(s,"/Users/alessandro/Desktop/GUIT_NO_AMP.aif");

////// Synth for the Stereo Delay //////
(
~synth_stereoDelay = SynthDef("stereoDelay",
	{
		arg
		// delay parameters
		level = 0.3,  // level of the repetitions, range: 0 - 1
		bpm = 100,    // BPM of the song, range 40 - 200
		rep = 4,     // number of repetitions, range 1 - 8
		tone = 2500,   // tone, low pass filter, range: 1Khz - 6Khz

		// chorus parameters
		mix = 0,   // mix btw signal and chorus, range: 0 - 1
		rate = 0.3,    // speed of the modulation, range: 0hz - 1hz
		depth = 0.5,  // amount of modulation, range: 0.25 - 1 (7ms - 28ms)

		// reverb parameters
		blend = 0,   // mix btw signal and reverb, range: 0 - 1
		presence = 6500,  // brightness of the reverb, range: 1Khz - 8Khz
		decay = 10,   // time decay, range: 0 - 20

		on_off = 0;

		var signal = PlayBuf.ar(2, b.bufnum);
		//var signal = In.ar(13,2);
		//var output;

		// chorus
		var chorus_input = LPF.ar(signal, 4000);
		var lfo_left = (SinOsc.ar(rate) + 1);  // left oscillator
		var lfo_right = (SinOsc.ar(rate,2) + 1);  // right oscillator
		var min_delay = 0.007;
		var max_delay = 0.028*depth;
		var wet_left = DelayC.ar(chorus_input, 1, lfo_left.linlin(0, 2, min_delay, max_delay));
		var wet_right = DelayC.ar(chorus_input, 1, lfo_right.linlin(0, 2, min_delay, max_delay));
		var chorus_output = (signal) + ([wet_left, wet_right]*mix);   // mix

		// delay
		var delay_input = chorus_output;

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
		var reverb_input = delay_output;
		var rev = LPF.ar(reverb_input, presence);
		var reverb_output;

		// stereo reverb
		5.do{ rev[0] = AllpassN.ar(rev[0], 0.06, Rand(0.001,0.04), decay+Rand(0,1)) };
		5.do{ rev[1] = AllpassN.ar(rev[1], 0.06, Rand(0.001,0.04), decay+Rand(0,1)) };
		reverb_output = (reverb_input) + (rev*blend);

		//output = (reverb_output * on_off) + (signal * (1-on_off));

		Out.ar([0,1], reverb_output);
}).send;
)

~synth_stereoDelay = Synth("stereoDelay");


////// Graphic //////
(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 580;
var win_height = 600;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 120;

var i = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/SuperColliderFX/DividedEffects/blue.png");

w = Window("Stereo Digital Delay", Rect(left_padding, top_padding, win_width, win_height));
w.front;
w.view.backgroundImage_(i);
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

// delay controls

~level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	       var level = obj.value.round(0.01);
	       ~synth_stereoDelay.set(\level, level);
	       ~level_text.string_(20*log(level).round(0.01)+"dB");
           });

~time_knob = Knob(w, knob_dim@knob_dim)
.value_(0.375)
.action_({ arg obj;
	       var bpm = obj.value.linlin(0,1,40,200).round(1);
	       ~synth_stereoDelay.set(\bpm, bpm);
	       ~time_text.value_(bpm);
           });

~feedback_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var rep = obj.value.linlin(0,1,0,8).round(1);
	       ~synth_stereoDelay.set(\rep, rep);
	       ~feedback_text.string_(rep+"Repetitions");
           });

~tone_knob = Knob(w, knob_dim@knob_dim)
.value_(0.25)
.action_({ arg obj;
	       var tone = obj.value.linlin(0,1,1000,7000).round(0.01);
	       ~synth_stereoDelay.set(\tone, tone);
	       ~tone_text.string_(tone+"Hz");
           });


~level_text = StaticText(w, knob_dim@14)
.string_(20*log(~level_knob.value).round(0.01)+"dB")
.font_(Font("Monaco",14))
.stringColor_(Color.white)
.align_(\center);

~time_text = NumberBox(w, 60@14)
.value_(100)
.clipLo_(40)
.clipHi_(200)
.font_(Font("Monaco",14))
.normalColor_(Color.black)
.stringColor_(Color.black)
.typingColor_(Color.black)
.align_(\center)
.background_(Color.white)
.buttonsVisible_(false)
.action_({ arg obj;
	       ~time_knob.valueAction_(obj.value.linlin(40,200,0,1));
          });
~blank_label = StaticText(w, 40@14)
.string_("BPM")
.font_(Font("Monaco",14))
.stringColor_(Color.white)
.align_(\left);

~feedback_text = StaticText(w, knob_dim@14)
.string_(~feedback_knob.value.linlin(0,1,0,8)+"Repetitions")
.font_(Font("Monaco",14))
.stringColor_(Color.white)
.align_(\center);

~tone_text = StaticText(w, knob_dim@14)
.string_(~tone_knob.value.linlin(0,1,1000,7000)+"Hz")
.font_(Font("Monaco",14))
.stringColor_(Color.white)
.align_(\center);

~level_label = StaticText(w, knob_dim@20)
.string_("LEVEL")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~time_label = StaticText(w, knob_dim@20)
.string_("TIME")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~feedback_label = StaticText(w, knob_dim@20)
.string_("FEEDBACK")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~tone_label = StaticText(w, knob_dim@20)
.string_("TONE")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

// chorus controls

~chorus_switch = Button(w, knob_dim@30)
.states_([ ["CHORUS", Color.white, Color.gray], ["CHORUS", Color.white, Color.red] ])
.font_(Font("Monaco",18))
.action_({ arg obj;
	       if( obj.value == 1,
		        {~synth_stereoDelay.set(\mix, ~mix_knob.value);
		        ~mix_knob.enabled_(true);},

	            {~synth_stereoDelay.set(\mix, 0);
		        ~mix_knob.enabled_(false);} );
           });

~mix_knob = Knob(w, knob_dim@knob_dim)
.enabled_(false)
.value_(0.6)
.action_({ arg obj;
	       var mix = obj.value.round(0.01);
	       ~synth_stereoDelay.set(\mix, mix);
	       ~mix_label.string_("MIX"+(mix*100)+"%")
           });

~rate_knob = Knob(w, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	       var rate = obj.value.round(0.001);
	       ~synth_stereoDelay.set(\rate, rate);
           });

~depth_knob = Knob(w, knob_dim@knob_dim)
.value_(0.625)
.action_({ arg obj;
	       var depth = obj.value.obj.value.linlin(0,1,0.25,1).round(0.01);
	       ~synth_stereoDelay.set(\depth, depth);
           });

~blank_label = StaticText(w, knob_dim@30);

~mix_label = StaticText(w, knob_dim@30)
.string_("MIX"+(~mix_knob.value.round(0.01)*100)+"%")
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
.font_(Font("Monaco",18))
.action_({ arg obj;
	       if( obj.value == 1,
		        {~synth_stereoDelay.set(\blend, ~blend_knob.value);
		        ~blend_knob.enabled_(true);},

	            {~synth_stereoDelay.set(\blend, 0);
		        ~blend_knob.enabled_(false);} );
           });

~blend_knob = Knob(w, knob_dim@knob_dim)
.enabled_(false)
.value_(0.3)
.action_({ arg obj;
	       var blend = obj.value.round(0.01);
	       ~synth_stereoDelay.set(\blend, blend);
	       ~blend_label.string_("BLEND"+(blend*100)+"%")
           });

~presence_knob = Knob(w, knob_dim@knob_dim)
.value_(0.9)
.action_({ arg obj;
	       var presence = obj.value.linlin(0,1,1000,8000).round(0.01);
	       ~synth_stereoDelay.set(\presence, presence);
           });

~decay_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var decay = obj.value.round(0.01);
	       ~synth_stereoDelay.set(\decay, decay);
           });

~blank_label = StaticText(w, knob_dim@30);

~blend_label = StaticText(w, knob_dim@30)
.string_("BLEND"+(~blend_knob.value.round(0.01)*100)+"%")
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

ServerOptions.outDevices
o = Server.local.options
o.outDevice = "Soundflower (2ch)";