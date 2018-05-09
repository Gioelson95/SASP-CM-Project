s.boot;

b = Buffer.read(server:s, path:"/Users/gioelepozzi/Desktop/SASP-CM-Project/AudioSamples/CLEAN.aif");

// SynthDef for the wahwah
(
SynthDef.new("wahwah",
	{
		arg
		freq = 750;
		var signal = PlayBuf.ar(2, b.bufnum);
		//var signal = In.ar(2);

		var outputFreqBoost = BPeakEQ.ar(in: signal, freq: freq, rq: 0.58, db: 12, mul: 1, add: 0);
		var outputHPF = HPF.ar(in: outputFreqBoost, freq: freq*0.8);
		var outputLPF = LPF.ar(in: outputHPF, freq: freq*1.6);
		var output = outputLPF + outputLPF.distort*0.25;

		Out.ar([0,1], channelsArray:output);
    }).send;
)

f = Synth("wahwah");

// Synthdef for the octaverOC2
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
		var signal_oc2 = PitchShift.ar(in:signal,windowSize:0.05,pitchRatio:0.2,mul:oc2_level);


		var output = signal*direct_level + LPF.ar(signal_oc1,440) + LPF.ar(signal_oc2,220);

		Out.ar([0,1], output);
    }).send;
)

y = Synth("octaverOC2");

// Graphic part
(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_wahwah_width = 160;
var win_wahwah_height = 330;
var win_octaverOC2_width = 580;
var win_octaverOC2_height = 240;
var left_wahwah_padding = (screen_width - win_wahwah_width)/2;
var top_wahwah_padding = (screen_height - win_wahwah_height)/2;
var left_octaverOC2_padding = (screen_width - win_octaverOC2_width)/2;
var top_octaverOC2_padding = (screen_height - win_octaverOC2_height)/2;

var slider_dim_width = 120;
var slider_dim_height = 180;
var knob_dim = 120;

k = Window("Wah-Wah", Rect(left_wahwah_padding, top_wahwah_padding, win_wahwah_width, win_wahwah_height)).front;
k.view.decorator_(FlowLayout(k.bounds, 20@20, 20@20));
k.background = Color.black;

s = Window("OctaverOC2", Rect(left_octaverOC2_padding, top_octaverOC2_padding, win_octaverOC2_width, win_octaverOC2_height)).front;
s.view.decorator_(FlowLayout(s.bounds, 20@20, 20@20));
s.background = Color.fromHexString("742a2a");

///////////////////

~on_off_wahwah = Button(k,120@40)
.states_([ ["OFF Wah-Wah", Color.white, Color.red], ["ON Wah-Wah", Color.white, Color.green] ])
.font_(Font("Monaco",15))
.action_({arg obj;
	      if( obj.value == 1,
		        {f = Synth("wahwah");
			       ~freq_slider.enabled_(true);
		        },
	            {f.free;
			       ~freq_slider.enabled_(false);
			       ~freq_slider.value_(0.22);
		        }
	        );});

~on_off_OctaverOC2 = Button(s,120@40)
.states_([ ["OFF Octaver", Color.white, Color.red], ["ON Octaver", Color.white, Color.green] ])
.font_(Font("Monaco",15))
.action_({arg obj;
	      if( obj.value == 1,
		        {y = Synth("octaverOC2");
			       ~direct_level_knob.enabled_(true);
			       ~oc1_level_knob.enabled_(true);
			       ~oc2_level_knob.enabled_(true);
		           },
	            {y.free;
			       ~direct_level_knob.enabled_(false);
			       ~direct_level_knob.value_(0.5);
			       ~oc1_level_knob.enabled_(false);
			       ~oc1_level_knob.value_(0.5);
			       ~oc2_level_knob.enabled_(false);
			       ~oc2_level_knob.value_(0.5);
		          }
	        );});

//////////////////

~freq_slider = Slider(k, bounds:slider_dim_width@slider_dim_height)
.enabled_(false)
.value_(0.22)
.action_({ arg obj;
	       var freq = obj.value.linlin(inMin:0, inMax:1, outMin:400, outMax:1600).round(1);
	       f.set(\freq, freq);
           });

~freq_label = StaticText(parent:k, bounds:slider_dim_width@30)
.string_("FREQUENCE")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

////////////////////////

~direct_level_knob = Knob(s, knob_dim@knob_dim)
.enabled_(false)
.value_(0.5)
.action_({ arg obj;
	       var direct_level = obj.value.round(0.01);
	       y.set(\direct_level, direct_level);
           });

~oc1_level_knob = Knob(s, knob_dim@knob_dim)
.enabled_(false)
.value_(0.5)
.action_({ arg obj;
	       var oc1_level = obj.value.round(0.01);
	       y.set(\oc1_level, oc1_level);
           });

~oc2_level_knob = Knob(s, knob_dim@knob_dim)
.enabled_(false)
.value_(0.5)
.action_({ arg obj;
	       var oc2_level = obj.value.round(0.01);
	       y.set(\oc2_level, oc2_level);
           });

~blank_label = StaticText(s, knob_dim@30);

~direct_level_label = StaticText(s, knob_dim@30)
.string_("DRY")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~oc1_level_label = StaticText(s, knob_dim@30)
.string_("OCT1")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~oc2_level_label = StaticText(s, knob_dim@30)
.string_("OCT2")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);


)
