s.boot;

SynthDef.new("stereo_delay",
	{
		arg
		level = 0.5,  // level of the repetitions, range: 0 - 1
		bpm = 80,    // BPM of the song, range 40 - 200
		rep = 4,     // number of repetitions, range 1 - 8
		tone = 2500;   // tone, low pass filter, range: 1Khz - 6Khz

		var signal = In.ar(2);   // input signal from the audio interface
		var time_quarter = 60/bpm;  // delay 1/4 after the note
		var time_octave = 60/(2*bpm);  // delay 1/8 after the note
		var feedback = rep*time_quarter;   // feedback of the delay in ms, range: 1/4 - 2 bars

		var delay_right = CombL.ar(signal, 1, time_quarter, feedback, level);
		var delay_left = CombL.ar(signal, 1, time_octave, feedback, level);
		var delay_right_lp = LPF.ar(delay_right, tone);
		var delay_left_lp = LPF.ar(delay_left, tone);
		var stereo_delay = [delay_left_lp, delay_right_lp];

		Out.ar(0, signal + stereo_delay);
    }).send;

x = Synth("stereo_delay");

(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 820;
var win_height = 280;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 180;

w = Window("Stereo Digital Delay", Rect(left_padding, top_padding, win_width, win_height)).front;
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

~level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var level = obj.value.round(0.01);
	       x.set(\level, level);
           });

~time_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
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
.align_(\center);

~time_label = StaticText(w, knob_dim@30)
.string_("TIME")
.font_(Font("Monaco",20))
.align_(\center);

~feedback_label = StaticText(w, knob_dim@30)
.string_("FEEDBACK")
.font_(Font("Monaco",20))
.align_(\center);

~tone_label = StaticText(w, knob_dim@30)
.string_("TONE")
.font_(Font("Monaco",20))
.align_(\center);
)













