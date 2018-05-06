s.boot;

b = Buffer.read(s,"/Users/alessandro/Desktop/NOTE.aif");

{
var signal = PlayBuf.ar(2, b.bufnum);
var bpm = 134;   // BPM of the song
var time_quarter = 60/bpm;  // delay 1/4 after the note
var time_octave = 60/(2*bpm);  // delay 1/8 after the note
var rep = 4;
var feedback = rep*time_quarter;   // number of repetitions, range 1 - 4
var level = 0.5;     // level of the repetitions, range: 0 - 1
var tone = 3500;      // tone, low pass filter, range: 2Khz - 7 Khz

var delay_right = CombL.ar(signal, 1, time_quarter, feedback, level);
var delay_left = CombL.ar(signal, 1, time_octave, feedback, level);
var delay_right_lp = LPF.ar(delay_right, tone);
var delay_left_lp = LPF.ar(delay_left, tone);
var stereo_delay = [delay_left_lp, delay_right_lp];

signal + stereo_delay;
}.play;

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
.action_({ arg obj;
	       obj.value.postln;
           });

~time_knob = Knob(w, knob_dim@knob_dim);
~feedback_knob = Knob(w, knob_dim@knob_dim);
~tone_knob = Knob(w, knob_dim@knob_dim);

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












