s.boot;

// simulation of an Electro Harmonix Micro Pog

b = Buffer.read(s,"/Users/alessandro/Desktop/NOTE.aif");

(
SynthDef.new("octaver",
	{
		arg
		direct_level = 0.5,  // level of direct input, range 0 - 1
		oc_down_level = 0.5,     // level of first octave below, range 0 - 1
		oc_up_level = 0.5;     // level of second octave below, range 0 - 1

		//var signal = In.ar(2);  // input signal from the audio interface
		var signal = PlayBuf.ar(2, b.bufnum);

		var signal_oc_down = PitchShift.ar(in:signal,windowSize:0.2,pitchRatio:0.5,mul:oc_down_level);
		var oc_down = LPF.ar(signal_oc_down, 440)*2;

		var signal_oc_up = LPF.ar(signal)
		var oc_up = PitchShift.ar(in:signal,windowSize:0.2,pitchRatio:2,mul:oc_up_level);
		var output = signal*direct_level + signal_oc_down + signal_oc_up;

		Out.ar([0,1], output);
    }).send;
)

x = Synth("octaver");

(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 640;
var win_height = 280;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 180;

w = Window("Octaver", Rect(left_padding, top_padding, win_width, win_height)).front;
w.background = Color.red;
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

~direct_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var direct_level = obj.value.round(0.01);
	       x.set(\direct_level, direct_level);
           });

~oc_down_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var oc_down_level = obj.value.round(0.01);
	       x.set(\oc_down_level, oc_down_level);
           });

~oc_up_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var oc_up_level = obj.value.round(0.01);
	       x.set(\oc_up_level, oc_up_level);
           });


~direct_level_label = StaticText(w, knob_dim@30)
.string_("DRY")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~oc1_level_label = StaticText(w, knob_dim@30)
.string_("SUB OCTAVE")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~oc2_level_label = StaticText(w, knob_dim@30)
.string_("OCTAVE UP")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);
)










