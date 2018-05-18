Server.default.options.outDevice_("Soundflower (2ch)");
Server.default.options.inDevice_("ONE");
s.boot;

b = Buffer.read(s,"/Users/alessandro/Desktop/GUIT_NO_AMP.aif");

(
SynthDef.new("TubeScreamer",
	{
		arg
		on = 0,   // bypass control

		volume = 2,    // volume of the pedal, range: 0 - 4
		gain = 0.5,   // amount of distortion
		tone = 723;  // tone of the pedal (low pass)

		//var input = PlayBuf.ar(2, b.bufnum);
		var input = In.ar(2);

		var hp_input = HPF.ar(input,720);  // only the mid/high freq are clipped

		var clipping = ( hp_input*(((gain**2)+0.02)*50) ).softclip;  // overdrive
		var clipped = clipping*((volume**2) * (1 - (gain/2.6)));  // volume control

		var dist_output = (LPF.ar(clipped,tone)*0.85) + (input*0.15);  // tone control + clean blend

		//var output = (dist_output*on) + input*(1-on);

		Out.ar([0,1], dist_output);

    }).send;
)

x = Synth("TubeScreamer");

(

var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 440;
var win_height = 280;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 120;

var i = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/SuperColliderFX/DividedEffects/metal.png");

w = Window("TubeScreamer", Rect(left_padding, top_padding, win_width, win_height));
w.front;
w.view.backgroundImage_(i);
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

~volume_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var volume = obj.value.linlin(0,1,0,4).round(0.01);
	       x.set(\volume, volume);
           });

~tone_knob = Knob(w, knob_dim@knob_dim)
.value_(1)
.action_({ arg obj;
	       var tone = obj.value.linlin(0,1,200,723).round(0.01);
	       x.set(\tone, tone);
           });

~gain_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var gain = obj.value.round(0.01);
	       x.set(\gain, gain);
           });


~volume_label = StaticText(w, knob_dim@30)
.string_("VOLUME")
.font_(Font("Monaco",22))
.stringColor_(Color.white)
.align_(\center);

~bass_label = StaticText(w, knob_dim@30)
.string_("TONE")
.font_(Font("Monaco",22))
.stringColor_(Color.white)
.align_(\center);

~middle_label = StaticText(w, knob_dim@30)
.string_("GAIN")
.font_(Font("Monaco",22))
.stringColor_(Color.white)
.align_(\center);

~name_label = StaticText(w, knob_dim*2@60)
.string_("GREEN POLI SCREAMER")
.font_(Font("Monaco",22))
.stringColor_(Color.black)
.align_(\center);

~switch = Button(w, knob_dim@60)
.states_([ ["", Color.white, Color.gray], ["", Color.white, Color.red] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {x.set(\on, 1);},
	            {x.set(\on, 0);} );
           });

)
