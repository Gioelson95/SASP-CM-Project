s.boot;

b = Buffer.read(server:s, path:"/Users/gioelepozzi/Desktop/SASP-CM-Project/AudioSamples/CLEAN.aif");

// Creation of the Synths
(
/////////////// Synth for the WahWah /////////////////
~synth_wahwah = SynthDef("wahwah",
	{
		arg
		freq = 750;
		var signal = PlayBuf.ar(2, b.bufnum);
		//var signal = In.ar(2);

		var outputFreqBoost = BPeakEQ.ar(in: signal, freq: freq.lag(0.5), rq: 0.58, db: 12, mul: 1, add: 0);
		var outputHPF = HPF.ar(in: outputFreqBoost, freq: freq*0.8);
		var outputLPF = LPF.ar(in: outputHPF, freq: freq*1.6);
		var output = outputLPF + outputLPF.distort*0.25;

		Out.ar([0,1], channelsArray:output);
}).send;

/////////////// Synth for the Octaver OC2 /////////////////
~synth_octaverOC2 = SynthDef("octaverOC2",
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

/////////////// Synth for the Octaver M288 /////////////////
~synth_octaverM288 = SynthDef("octaverM288",
	{
		arg
		dry_level = 0.5,      // level of direct input, range 0 - 1
		growl_level = 0.5,    // level of first octave below, range 0 - 1
		girth_level = 0.5,    // level of second octave below, range 0 - 1
		mid_plus_switch = 0;   // select if mid+ switch is clicked, 1 if it is clicked, 0 otherwise

		var signal = PlayBuf.ar(2, b.bufnum)*0.6; //the multiplicative factor is to not exceeded 0dB in output
		//var signal = In.ar(2);
		var signal_octave = PitchShift.ar(in:signal,windowSize:0.05,pitchRatio:0.5);
		var signal_octave_LPF = LPF.ar(in: signal_octave,freq:220);
		var growl_signal = BBandPass.ar(in:signal_octave,freq:200,bw:3,mul:growl_level*2);
		var girth_signal = BBandPass.ar(in:signal_octave,freq:100,bw:3,mul:girth_level*1.5);
		var mid_plus_signal = BPeakEQ.ar(in:signal,freq:400,rq:2,db:10,mul:mid_plus_switch);
		var output = (signal*(1-mid_plus_switch) + mid_plus_signal)*dry_level + growl_signal + girth_signal;

		Out.ar([0,1], output);
}).send;

/////////////// Synth for the Stereo Delay /////////////////
~synth_stereoDelay = SynthDef("stereoDelay",
	{
		arg
		// delay parameters
		level = 0.3,  // level of the repetitions, range: 0 - 1
		bpm = 100,    // BPM of the song, range 40 - 200
		rep = 4,     // number of repetitions, range 1 - 8
		tone = 2500,   // tone, low pass filter, range: 1Khz - 6Khz

		// chorus parameters
		mix = 0.6,   // mix btw signal and chorus, range: 0 - 1
		rate = 0.3,    // speed of the modulation, range: 0hz - 1hz
		depth = 0.5,  // amount of modulation, range: 0.25 - 1 (7ms - 28ms)

		// reverb parameters
		blend = 0.3,   // mix btw signal and reverb, range: 0 - 1
		presence = 6500,  // brightness of the reverb, range: 1Khz - 8Khz
		decay = 10;   // time decay, range: 0 - 20

		//var signal = In.ar(1);   // input signal from the audio interface
		var signal = PlayBuf.ar(2, b.bufnum);

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
		var modulator = SinOsc.ar(0.3).linlin(-1,1,0,1.3);
		var delrd = LocalIn.ar(4);
		var reverb_output = reverb_input + delrd[[0,1]];
		var deltimes = [101, 143, 165, 177] * 0.001 - ControlDur.ir;
		var sig = [reverb_output[0]+reverb_output[1],
			reverb_output[0]-reverb_output[1],
			delrd[2]+delrd[3],
			delrd[2]-delrd[3]];
		sig = [ sig[0]+sig[2], sig[1]+sig[3], sig[0]-sig[2], sig[1]-sig[3] ];
		sig = sig * [0.4, 0.37, 0.333, 0.3];


		LocalOut.ar(DelayC.ar(sig, deltimes, deltimes));

		Out.ar(0, reverb_output);
		//Out.ar(0, delay_output);
}).send;

)

~synth_wahwah = Synth("wahwah");
~synth_octaverOC2 = Synth("octaverOC2");
~synth_octaverM288 = Synth("octaverM288");
~synth_stereoDelay = Synth("stereoDelay");

/////////////////////////////////////////////// GRAPHIC PART //////////////////////////////////////////

(
// Main window parameters
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 850;
var win_height = 950;
var left_pad = (screen_width - win_width)/2;
var top_pad = (screen_height - win_height)/2;
var win_color = Color(red:224, green:224, blue:224);  // Classic light grey

// Knob parameters
var knob_dim = 80;
var knob_inital_value = 0.5;

// Slider parameters
var slider_width = 50;
var slider_height = 80;
var slider_size = 15;   // dimension of the moving part of the slider
var slider_initial_value = 0.22;
var slider_color = Color.black;

// Label parameters
var label_font = "Monaco";
var label_size = 15;
var label_color = Color.white;

// Button parameters
var button_dim = 80;

// Initialization of main window
Window.closeAll;
w = Window(name:"Effects", bounds:Rect(left:left_pad, top:top_pad, width:win_width, height:win_height),resizable:true, border:true, server:s, scroll:false);
w.front;
w.view.decorator_(FlowLayout(bounds:w.bounds, margin:20@20, gap:10@10));
w.background_(win_color);

/////////////////// SETTINGS ///////////////////

~settings_view = CompositeView(parent:w, bounds:810@200)
.background_(Color.red)
.decorator_(FlowLayout(bounds:w.bounds, margin:20@20, gap:10@10));

~settings_label = StaticText(parent:~settings_view, bounds:Rect(width:80,height:20))
.string_("Settings")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align_(\center);

w.view.decorator.nextLine;

/////////////////// WAH-WAH ///////////////////

// WahWah view
~wahwah_view = CompositeView(parent:w, bounds:100@190)
.background_(Color.black)
.decorator_(FlowLayout(bounds:w.bounds, margin:20@20, gap:10@10));

~wahwah_label = StaticText(parent:~wahwah_view, bounds:Rect(width:75,height:20))
.string_("Wah-Wah")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align(\center);

~wahwah_view.decorator.nextLine;

// Slider for the WahWah effect
~freq_slider = Slider(parent:~wahwah_view, bounds:Rect(width:slider_width,height:slider_height))
.thumbSize_(pixels:slider_size)
.enabled_(true)  //TO CHANGE
.value_(slider_initial_value)
.background_(slider_color)
.action_({
	arg obj;
	var freq = obj.value.linlin(inMin:0, inMax:1, outMin:400, outMax:1600).round(1);
	~synth_wahwah.set(\freq, freq);
});

~wahwah_view.decorator.nextLine;

~freq_label = StaticText(parent:~wahwah_view, bounds:Rect(width:50,height:20))
.string_("FREQ")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align_(\center);

/////////////////// OCTAVER OC2 ///////////////////

// OctaaverOC2 view
~octaverOC2_view = CompositeView(parent:w, bounds:300@190)
.background_(Color.fromHexString("742a2a"))
.decorator_(FlowLayout(bounds:w.bounds, margin:20@20, gap:10@10));

~octaverOC2_label = StaticText(parent:~octaverOC2_view, bounds:Rect(width:250,height:20))
.string_("Octaver OC2")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align_(\center);

~octaverOC2_view.decorator.nextLine;

~direct_level_knob = Knob(~octaverOC2_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	var direct_level = obj.value.round(0.01);
	~synth_octaverOC2.set(\direct_level, direct_level);
});

~oc1_level_knob = Knob(~octaverOC2_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	var oc1_level = obj.value.round(0.01);
	~synth_octaverOC2.set(\oc1_level, oc1_level);
});

~oc2_level_knob = Knob(~octaverOC2_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	var oc2_level = obj.value.round(0.01);
	~synth_octaverOC2.set(\oc2_level, oc2_level);
});

~octaverOC2_view.decorator.nextLine;

~direct_level_label = StaticText(~octaverOC2_view, knob_dim@30)
.string_("DRY")
.font_(Font(label_font,label_size))
.stringColor_(label_color)
.align_(\center);

~oc1_level_label = StaticText(~octaverOC2_view, knob_dim@30)
.string_("OCT1")
.font_(Font(label_font,label_size))
.stringColor_(label_color)
.align_(\center);

~oc2_level_label = StaticText(~octaverOC2_view, knob_dim@30)
.string_("OCT2")
.font_(Font(label_font,label_size))
.stringColor_(label_color)
.align_(\center);

/////////////////// OCTAVER M288 ///////////////////

// OctaverM288 view
~octaverM288_view = CompositeView(parent:w, bounds:390@190)
.background_(Color.blue)
.decorator_(FlowLayout(bounds:w.bounds, margin:20@20, gap:10@10));

~octaverM288_label = StaticText(parent:~octaverM288_view, bounds:Rect(width:250,height:20))
.string_("Octaver M288")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align_(\center);

~octaverM288_view.decorator.nextLine;

~mid_plus_button = Button(~octaverM288_view,button_dim@button_dim)
.states_([ ["MID+", label_color, Color.gray], ["MID+", label_color, Color.red] ])
.font_(Font(label_font,label_size))
.value_(0)
.action_({arg obj;
	if( obj.value == 1,
		{~synth_octaverM288.set(\mid_plus_switch,1);},
		{~synth_octaverM288.set(\mid_plus_switch,0);}
);});

~dry_level_knob = Knob(~octaverM288_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	var dry_level = obj.value.round(0.01);
	~synth_octaverM288.set(\dry_level, dry_level);
});

~growl_level_knob = Knob(~octaverM288_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	var growl_level = obj.value.round(0.01);
	~synth_octaverM288.set(\growl_level, growl_level);
});

~girth_level_knob = Knob(~octaverM288_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	var girth_level = obj.value.round(0.01);
	~synth_octaverM288.set(\girth_level, girth_level);
});

~octaverM288_view.decorator.nextLine;

~blank_level_label = StaticText(~octaverM288_view, knob_dim@30)
.string_("")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align_(\center);

~dry_level_label = StaticText(~octaverM288_view, knob_dim@30)
.string_("DRY")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align_(\center);

~growl_level_label = StaticText(~octaverM288_view, knob_dim@30)
.string_("GROWL")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align_(\center);

~girth_level_label = StaticText(~octaverM288_view, knob_dim@30)
.string_("GIRTH")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align_(\center);

w.view.decorator.nextLine;

/////////////////// STEREO DELAY ///////////////////

// Stereo Delay view
~stereoDelay_view = CompositeView(parent:w, bounds:410@460)
.background_(Color.blue)
.decorator_(FlowLayout(bounds:w.bounds, margin:20@20, gap:10@10));

~stereoDelay_label = StaticText(parent:~stereoDelay_view, bounds:Rect(width:150,height:20))
.string_("Stereo Delay")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align(\center);

~stereoDelay_view.decorator.nextLine;

~level_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	       var level = obj.value.round(0.01);
	       x.set(\level, level);
	       ~level_text.string_(20*log(level).round(0.01)+"dB");
           });

~time_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.375)
.action_({ arg obj;
	       var bpm = obj.value.linlin(0,1,40,200).round(1);
	       x.set(\bpm, bpm);
	       ~time_text.value_(bpm);
           });

~feedback_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var rep = obj.value.linlin(0,1,0,8).round(1);
	       x.set(\rep, rep);
	       ~feedback_text.string_(rep+"Repetitions");
           });

~tone_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.25)
.action_({ arg obj;
	       var tone = obj.value.linlin(0,1,1000,7000).round(0.01);
	       x.set(\tone, tone);
	       ~tone_text.string_(tone+"Hz");
           });

~stereoDelay_view.decorator.nextLine;

~level_text = StaticText(~stereoDelay_view, knob_dim@14)
.string_(20*log(~level_knob.value).round(0.01)+"dB")
.font_(Font("Monaco",14))
.stringColor_(Color.white)
.align_(\center);

~time_text = NumberBox(~stereoDelay_view, 60@14)
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
~blank_label = StaticText(~stereoDelay_view, 40@14)
.string_("BPM")
.font_(Font("Monaco",14))
.stringColor_(Color.white)
.align_(\left);

~feedback_text = StaticText(~stereoDelay_view, knob_dim@14)
.string_(~feedback_knob.value.linlin(0,1,0,8)+"Repetitions")
.font_(Font("Monaco",14))
.stringColor_(Color.white)
.align_(\center);

~tone_text = StaticText(~stereoDelay_view, knob_dim@14)
.string_(~tone_knob.value.linlin(0,1,1000,7000)+"Hz")
.font_(Font("Monaco",14))
.stringColor_(Color.white)
.align_(\center);

~stereoDelay_view.decorator.nextLine;

~level_label = StaticText(~stereoDelay_view, knob_dim@20)
.string_("LEVEL")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~time_label = StaticText(~stereoDelay_view, knob_dim@20)
.string_("TIME")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~feedback_label = StaticText(~stereoDelay_view, knob_dim@20)
.string_("FEEDBACK")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~tone_label = StaticText(~stereoDelay_view, knob_dim@20)
.string_("TONE")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~stereoDelay_view.decorator.nextLine;

// chorus controls

~chorus_switch = Button(~stereoDelay_view, knob_dim@30)
.states_([ ["CHORUS", Color.white, Color.gray], ["CHORUS", Color.white, Color.red] ])
.font_(Font("Monaco",18))
.action_({ arg obj;
	       if( obj.value == 1,
		        {x.set(\mix, ~mix_knob.value);
		        ~mix_knob.enabled_(true);},

	            {x.set(\mix, 0);
		        ~mix_knob.enabled_(false);} );
           });

~mix_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.enabled_(false)
.value_(0.6)
.action_({ arg obj;
	       var mix = obj.value.round(0.01);
	       x.set(\mix, mix);
           });

~rate_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	       var rate = obj.value.round(0.001);
	       x.set(\rate, rate);
           });

~depth_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.625)
.action_({ arg obj;
	       var depth = obj.value.obj.value.linlin(0,1,0.25,1).round(0.01);
	       x.set(\depth, depth);
           });

~stereoDelay_view.decorator.nextLine;

~blank_label = StaticText(~stereoDelay_view, knob_dim@30);

~mix_label = StaticText(~stereoDelay_view, knob_dim@30)
.string_("MIX")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~rate_label = StaticText(~stereoDelay_view, knob_dim@30)
.string_("RATE")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~depth_label = StaticText(~stereoDelay_view, knob_dim@30)
.string_("DEPTH")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~stereoDelay_view.decorator.nextLine;

// reverb controls

~reverb_switch = Button(~stereoDelay_view, knob_dim@30)
.states_([ ["REVERB", Color.white, Color.gray],["REVERB", Color.white, Color.red] ])
.font_(Font("Monaco",18))
.action_({ arg obj;
	       if( obj.value == 1,
		        {x.set(\blend, ~blend_knob.value);
		        ~blend_knob.enabled_(true);},

	            {x.set(\blend, 0);
		        ~blend_knob.enabled_(false);} );
           });

~blend_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.enabled_(false)
.value_(0.3)
.action_({ arg obj;
	       var blend = obj.value.round(0.01);
	       x.set(\blend, blend);
           });

~presence_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.9)
.action_({ arg obj;
	       var presence = obj.value.linlin(0,1,1000,8000).round(0.01);
	       x.set(\presence, presence);
           });

~decay_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var decay = obj.value.round(0.01);
	       x.set(\decay, decay);
           });

~stereoDelay_view.decorator.nextLine;

~blank_label = StaticText(~stereoDelay_view, knob_dim@30);

~blend_label = StaticText(~stereoDelay_view, knob_dim@30)
.string_("BLEND")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~presence_label = StaticText(~stereoDelay_view, knob_dim@30)
.string_("PRESENCE")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~decay_label = StaticText(~stereoDelay_view, knob_dim@30)
.string_("DECAY")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

/////////////////// KINECT ///////////////////

// Kinect view
~kinect_view = CompositeView(parent:w, bounds:390@460)
.background_(Color.grey)
.decorator_(FlowLayout(bounds:w.bounds, margin:20@20, gap:10@10));

~kinect_label = StaticText(parent:~kinect_view, bounds:Rect(width:150,height:20))
.string_("Kinect View")
.font_(Font(name:label_font,size:label_size))
.stringColor_(label_color)
.align(\center);



/////////////////// BTN ///////////////////

/*
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
*/
//////////////////
)