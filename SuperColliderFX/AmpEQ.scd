s.boot;
b = Buffer.read(s,"/Users/alessandro/Desktop/CHORUS.aif");

(
SynthDef.new("AmpEQ",
	{
		arg
		volume = 1,     // volume of the amp, range: 0 - 2
		bass = 0,      // active bass eq from -10dB to +8db
		middle = 0,   // active middle eq from -10dB to +8db
		treble = 0;  // active treble eq from -10dB to +8db

		var signal = PlayBuf.ar(2, b.bufnum);

		var sig_volume = signal*volume;

		var sig_comp = Compander.ar(sig_volume, sig_volume, slopeAbove: 1/volume,
			                         clampTime: 0.006, relaxTime: 0.3);
	    var blend = volume.linexp(0,2,0,1);
	    var sig = (sig_volume*(1-blend)) + (sig_comp*blend);

		var sig_treble = BHiShelf.ar(sig_volume, 1000, 1, treble);
		var sig_bass = BLowShelf.ar(sig_treble, 400, 1, bass);
		var sig_mid = BPeakEQ.ar(sig_bass, 550, 1, middle);

		Out.ar(0, sig_mid);

    }).send;
)

x = Synth("AmpEQ");

(

var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 580;
var win_height = 200;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 120;

w = Window("AmpEQ", Rect(left_padding, top_padding, win_width, win_height));
w.front;
w.background = Color.fromHexString("CA853E");
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

~volume_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var volume = obj.value.linlin(0,1,0,4).round(0.01);
	       x.set(\volume, volume);
           });

~bass_knob = Knob(w, knob_dim@knob_dim)
.value_(0.6)
.action_({ arg obj;
	       var bass = obj.value.linlin(0,1,-10,8).round(0.01);
	       x.set(\bass, bass);
           });

~middle_knob = Knob(w, knob_dim@knob_dim)
.value_(0.6)
.action_({ arg obj;
	       var middle = obj.value.linlin(0,1,-10,8).round(0.01);
	       x.set(\middle, middle);
           });

~treble_knob = Knob(w, knob_dim@knob_dim)
.value_(0.6)
.action_({ arg obj;
	       var treble = obj.value.linlin(0,1,-10,8).round(0.01);
	       x.set(\treble, treble);
           });

~volume_label = StaticText(w, knob_dim@30)
.string_("VOLUME")
.font_(Font("Monaco",20))
.stringColor_(Color.black)
.align_(\center);

~bass_label = StaticText(w, knob_dim@30)
.string_("BASS")
.font_(Font("Monaco",20))
.stringColor_(Color.black)
.align_(\center);

~middle_label = StaticText(w, knob_dim@30)
.string_("MIDDLE")
.font_(Font("Monaco",20))
.stringColor_(Color.black)
.align_(\center);

~treble_label = StaticText(w, knob_dim@30)
.string_("TREBLE")
.font_(Font("Monaco",20))
.stringColor_(Color.black)
.align_(\center);

)

