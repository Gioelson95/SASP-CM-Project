Server.default.options.outDevice_("Soundflower (2ch)");
s.boot;

b = Buffer.read(s,"/Users/alessandro/Desktop/GUIT_NO_AMP.aif");

(
SynthDef.new("TubeScreamer",
	{
		arg
		volume = 2,   // volume of the pedal, range: 0 - 1
		gain = 0.5,    // amount of distortion
		tone = 723;   // tone of the pedal (low pass)

		var signal = PlayBuf.ar(2, b.bufnum);

		var hp_input = HPF.ar(signal,720);

		var clipping = ( hp_input*(((gain**2)+0.02)*50) ).softclip;
		var clipped = clipping*((volume**2) * (1 - (gain/2.6)));

		var output = LPF.ar(clipped,tone);

		Out.ar([0,1], output);

    }).send;
)

x = Synth("TubeScreamer");

(

var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 440;
var win_height = 200;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 120;

var i = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/SuperColliderFX/DividedEffects/green.png");

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
	       var tone = obj.value.linlin(0,1,400,723).round(0.01);
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

)

