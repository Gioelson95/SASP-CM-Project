s.boot;

// Set up the server
(
thisProcess.openUDPPort(52000);
NetAddr("192.168.2.7",52000);
)

////// Synth for the OctaverOC2 //////
(
~synth_octaverOC2 = SynthDef("octaverOC2",
	{
		arg
		direct_level = 0.5,  // level of direct input, range 0 - 1
		oc1_level = 0.5,     // level of first octave below, range 0 - 1
		oc2_level = 0.5,     // level of second octave below, range 0 - 1
		on_off = 0;

		//var signal = PlayBuf.ar(2, b.bufnum);
		var signal = In.ar(10,2);
		var signal_oc1 = PitchShift.ar(in:signal,windowSize:0.05,pitchRatio:0.5,mul:oc1_level*1.5);
		var signal_oc2 = PitchShift.ar(in:signal,windowSize:0.05,pitchRatio:0.2,mul:oc2_level);

		var output = signal*direct_level + LPF.ar(signal_oc1,440) + LPF.ar(signal_oc2,220);

		output = (output * on_off) + (signal * (1-on_off));

		Out.ar([12,13], output);
}).send;
)

~synth_octaverOC2 = Synth("octaverOC2");

////// Graphic //////
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
	       ~synth_octaverOC2.set(\direct_level, direct_level);
           });

~oc1_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var oc1_level = obj.value.round(0.01);
	       ~synth_octaverOC2.set(\oc1_level, oc1_level);
           });

~oc2_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var oc2_level = obj.value.round(0.01);
	       ~synth_octaverOC2.set(\oc2_level, oc2_level);
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

////// OSC Receiver for mobile use //////
(
~octaverOC2_direct_level_OSC_path = "/mobile1/rotation";
~octaverOC2_oc1_OSC_path = "";
~octaverOC2_oc2_OSC_path = "";
~octaverOC2_direct_OSC_num = 1;
~octaverOC2_oc1_OSC_num = 2;
~octaverOC2_oc2_OSC_num = 3;

OSCdef('OSCreceiver',
	{
		arg msg;
		var direct_level = msg[~octaverOC2_direct_OSC_num].round(0.01);
		//~synth_octaverOC2.set(\direct_level, direct_level);
		Routine{
			~direct_level_knob.valueAction_(direct_level);
		}.play(AppClock);
	},
	~octaverOC2_direct_OSC_path);
OSCdef('OSCreceiver',
	{
		arg msg;
		var oc1_level = msg[~octaverOC2_oc1_level_OSC_num].round(0.01);
		//~synth_octaverOC2.set(\oc1_level, oc1_level);
		Routine{
			~oc1_level_knob.valueAction_(oc1_level);
		}.play(AppClock);
	},
	~octaverOC2_oc1_OSC_path);
OSCdef('OSCreceiver',
	{
		arg msg;
		var oc2_level = msg[~octaverOC2_oc2_level_OSC_num].round(0.01);
		//~synth_octaverOC2.set(\oc2_level, oc2_level);
		Routine{
			~oc2_level_knob.valueAction_(oc2_level);
		}.play(AppClock);
	},
	~octaverOC2_oc2_OSC_path);
)