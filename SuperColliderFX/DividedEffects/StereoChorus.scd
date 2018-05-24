
////// Synth for the Stereo Delay //////
(
~synth_stereoChorus = SynthDef("stereoChorus",
	{
		arg
		on = 0,

		// chorus parameters
		mix = 0.6,   // mix btw signal and chorus, range: 0 - 1
		rate = 0.3,    // speed of the modulation, range: 0hz - 1hz
		depth = 0.5;  // amount of modulation, range: 0.25 - 1 (7ms - 28ms)

		var signal = In.ar(2,2);

		// chorus
		var chorus_input = signal;
		var lfo_left = (SinOsc.ar(rate) + 1);  // left oscillator
		var lfo_right = (SinOsc.ar(rate,2) + 1);  // right oscillator
		var min_delay = 0.007;
		var max_delay = 0.028*depth;
		var wet_left = DelayC.ar(chorus_input, 1, lfo_left.linlin(0, 2, min_delay, max_delay));
		var wet_right = DelayC.ar(chorus_input, 1, lfo_right.linlin(0, 2, min_delay, max_delay));
		var chorus_output = (signal) + ([wet_left, wet_right]*mix);   // mix

		var output = (chorus_output * on) + (signal * (1-on));

		Out.ar([0,1], output);
}).send;
)

~synth_stereoChorus = Synth("stereoChorus");


////// Graphic //////
(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 700;
var win_height = 430;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 200;

var label_dim = 26;

var i = QImage.new("/Users/alessandro/Desktop/Images/StereoChorus.png");

w = Window("Stereo Chorus", Rect(left_padding, top_padding, win_width, win_height));
w.front;
w.view.backgroundImage_(i);
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

// chorus controls

~mix_knob = Knob(w, knob_dim@knob_dim)
.value_(0.6)
.action_({ arg obj;
	       var mix = obj.value.round(0.01);
	       ~synth_stereoChorus.set(\mix, mix);
	       ~mix_label.string_("MIX"+(mix*100)+"%")
           });

~rate_knob = Knob(w, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	       var rate = obj.value.round(0.001);
	       ~synth_stereoChorus.set(\rate, rate);
           });

~depth_knob = Knob(w, knob_dim@knob_dim)
.value_(0.625)
.action_({ arg obj;
	       var depth = obj.value.linlin(0,1,0.25,1).round(0.01);
	       ~synth_stereoChorus.set(\depth, depth);
           });


~mix_label = StaticText(w, knob_dim@label_dim)
.string_("MIX"+(~mix_knob.value.round(0.01)*100)+"%")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~rate_label = StaticText(w, knob_dim@label_dim)
.string_("RATE")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~depth_label = StaticText(w, knob_dim@label_dim)
.string_("DEPTH")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~name_label = StaticText(w, knob_dim*2@90)
.string_("STEREO POLYCHORUS")
.font_(Font("Monaco",30))
.stringColor_(Color.white)
.align_(\center);

~switch = Button(w, knob_dim@(knob_dim/2))
.states_([ ["", Color.white, Color.gray], ["", Color.white, Color.red] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {~synth_stereoChorus.set(\on, 1);},
	            {~synth_stereoChorus.set(\on, 0);} );
           });
)

////// OSC //////

(
~kinect_chorus_receiver = OSCdef.new('OSCKinectChorus',
	{
		arg msg;

		Routine{
				~rate_knob.valueAction_(msg[1]);
				~mix_knob.valueAction_(msg[2]);
		}.play(AppClock);
	},
	\KinectOSC);
)

