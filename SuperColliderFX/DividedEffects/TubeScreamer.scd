
////// Synth for the TubeScreamer //////

(
~synth_tubeScreamer = SynthDef.new("tubeScreamer",

	{
		arg
		on = 0,   // bypass control
		volume = 1,    // volume of the pedal, range: 0 - 2
		gain = 0.5,   // amount of distortion
		tone = 823;  // tone of the pedal (low pass)

		var input = In.ar(12,2);

		var hp_input = HPF.ar(input,720);  // only the mid/high freq are clipped
		var clipping = ( hp_input*(((gain**2)+0.02)*50) ).softclip;  // overdrive
		var clipped = clipping*((volume**2) * (1 - (gain/2.6)));  // volume control
		var dist_output = (LPF.ar(clipped,tone)*0.9) + (input*0.1);  // tone control + clean blend
		var output = (dist_output*on) + (input*(1-on));

		Out.ar([14,15], output);
    }).send;
)

~synth_tubeScreamer = Synth("tubeScreamer");

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

var i = QImage.new("/Users/alessandro/Desktop/Images/TubeScreamer.png");

w = Window("TubeScreamer", Rect(left_padding, top_padding, win_width, win_height));
w.front;
w.view.backgroundImage_(i);
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

~volume_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var volume = obj.value.linlin(0,1,0,2).round(0.01);
	       ~synth_tubeScreamer.set(\volume, volume);
           });

~tone_knob = Knob(w, knob_dim@knob_dim)
.value_(1)
.action_({ arg obj;
	       var tone = obj.value.linlin(0,1,270,823).round(0.01);
	       ~synth_tubeScreamer.set(\tone, tone);
           });

~gain_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var gain = obj.value.round(0.01);
	       ~synth_tubeScreamer.set(\gain, gain);
           });


~volume_label = StaticText(w, knob_dim@label_dim)
.string_("VOLUME")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~tone_label = StaticText(w, knob_dim@label_dim)
.string_("TONE")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~gain_label = StaticText(w, knob_dim@label_dim)
.string_("GAIN")
.font_(Font("Monaco",label_dim))
.stringColor_(Color.white)
.align_(\center);

~name_label = StaticText(w, knob_dim*2@90)
.string_("GREEN POLISCREAMER")
.font_(Font("Monaco",30))
.stringColor_(Color.white)
.align_(\center);

~switch = Button(w, knob_dim@(knob_dim/2))
.states_([ ["", Color.white, Color.gray], ["", Color.white, Color.red] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {~synth_tubeScreamer.set(\on, 1);},
	            {~synth_tubeScreamer.set(\on, 0);} );
           });

)

////// OSC //////

(
~kinect_tube_receiver = OSCdef.new('OSCKinectTS',
	{
		arg msg;

		Routine{
				~gain_knob.valueAction_(msg[1]);
				~volume_knob.valueAction_(msg[1].linlin(0,1,1,0.65));
		}.play(AppClock);
	},
	\KinectOSC);
)

