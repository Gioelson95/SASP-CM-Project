s.boot;

// simulation of a Boss OC2

b = Buffer.read(s,"/Users/lucavilla/Desktop/CLEAN.aif");

(
SynthDef.new("octaverOC2",
	{
		arg
		direct_level = 0.5,  // level of direct input, range 0 - 1
		oc1_level = 0.5,     // level of first octave below, range 0 - 1
		oc2_level = 0.5;     // level of second octave below, range 0 - 1

		var signal = PlayBuf.ar(2, b.bufnum);
		//var signal = In.ar(2);
		var signal_oc1 = PitchShift.ar(in:signal,windowSize:0.05,pitchRatio:0.5,mul:oc1_level*1.5);
		var signal_oc2 = PitchShift.ar(in:signal,windowSize:0.05,pitchRatio:0.25,mul:oc2_level*2);


		var output = signal*direct_level + LPF.ar(signal_oc1,440) + LPF.ar(signal_oc2,220);

		Out.ar([0,1], output);
    }).send;
)

x = Synth("octaverOC2");


(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 510;
var win_height = 240;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 140;

w = Window("Octaver", Rect(left_padding, top_padding, win_width, win_height)).front;
w.background = Color.fromHexString("742a2a");
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

~direct_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var direct_level = obj.value.round(0.01);
	       x.set(\direct_level, direct_level);
           });

~oc1_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var oc1_level = obj.value.round(0.01);
	       x.set(\oc1_level, oc1_level);
           });

~oc2_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var oc2_level = obj.value.round(0.01);
	       x.set(\oc2_level, oc2_level);
           });


~direct_level_label = StaticText(w, knob_dim@30)
.string_("DRY")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~oc1_level_label = StaticText(w, knob_dim@30)
.string_("OCT1")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~oc2_level_label = StaticText(w, knob_dim@30)
.string_("OCT2")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);
)










