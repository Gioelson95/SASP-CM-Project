
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

		on = 0;

		var signal = In.ar(text,2);

		// delay
		var delay_input = signal;

		var time_quarter = 60/bpm;  // delay 1/4 after the note
		var time_octave = 60/(2*bpm);  // delay 1/8 after the note
		var feedback = rep*time_quarter;   // feedback of the delay in ms, range: 1/4 - 2 bars

		var delay_right = CombL.ar(delay_input, 1, time_quarter, feedback, level);
		var delay_left = CombL.ar(delay_input, 1, time_octave, feedback, level);
		var delay_right_lp = LPF.ar(delay_right, tone);
		var delay_left_lp = LPF.ar(delay_left, tone);
		var stereo_delay = [delay_left_lp, delay_right_lp];
		var delay_output = delay_input + stereo_delay;

		var output = (delay_output * on) + (signal * (1-on));

		Out.ar([0,1], output);
}).send;
)

~synth_stereoDelay = Synth("stereoDelay");


////// Graphic //////
(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 900;
var win_height = 450;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 200;

var text = 18;
var label_dim = 24;

var i = QImage.new("/Users/alessandro/Desktop/Images/StereoDelay.png");

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


~level_text = StaticText(w, knob_dim@text)
.string_(20*log(~level_knob.value).round(0.01)+"dB")
.font_(Font("Monaco",text))
.stringColor_(Color.white)
.align_(\center);

~blank_label = StaticText(w, 0@text);
~time_text = NumberBox(w, 90@text)
.value_(100)
.clipLo_(40)
.clipHi_(200)
.font_(Font("Monaco",text))
.normalColor_(Color.black)
.stringColor_(Color.black)
.typingColor_(Color.black)
.align_(\center)
.background_(Color.white)
.buttonsVisible_(false)
.action_({ arg obj;
	       ~time_knob.valueAction_(obj.value.linlin(40,200,0,1));
          });
~blank_label = StaticText(w, 62@text)
.string_("BPM")
.font_(Font("Monaco",text))
.stringColor_(Color.white)
.align_(\left);

~feedback_text = StaticText(w, knob_dim@text)
.string_(~feedback_knob.value.linlin(0,1,0,8)+"Repetitions")
.font_(Font("Monaco",text))
.stringColor_(Color.white)
.align_(\center);

~tone_text = StaticText(w, knob_dim@text)
.string_(~tone_knob.value.linlin(0,1,1000,7000)+"Hz")
.font_(Font("Monaco",text))
.stringColor_(Color.white)
.align_(\center);

~level_label = StaticText(w, knob_dim@label_dim)
.string_("LEVEL")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~time_label = StaticText(w, knob_dim@label_dim)
.string_("TIME")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~feedback_label = StaticText(w, knob_dim@label_dim)
.string_("FEEDBACK")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~tone_label = StaticText(w, knob_dim@label_dim)
.string_("TONE")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~name_label = StaticText(w, knob_dim*3@(knob_dim/2))
.string_("STEREO DIGITAL SARTYLEY")
.font_(Font("Monaco",30))
.stringColor_(Color.white)
.align_(\center);

~switch = Button(w, knob_dim@(knob_dim/2))
.states_([ ["", Color.white, Color.gray], ["", Color.white, Color.red] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {~synth_stereoDelay.set(\on, 1);},
	            {~synth_stereoDelay.set(\on, 0);} );
           });

)
