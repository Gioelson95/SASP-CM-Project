
////// Synth for the OctaverM288 //////
(
~synth_octaverM288 = SynthDef("octaverM288",
	{
		arg
		dry_level = 0.5,      // level of direct input, range 0 - 1
		growl_level = 0.5,    // level of first octave below, range 0 - 1
		girth_level = 0.5,    // level of second octave below, range 0 - 1
		mid_plus_switch = 0,   // select if mid+ switch is clicked, 1 if it is clicked, 0 otherwise
		on = 0;

		var signal = In.ar(10,2);
		var signal_octave = PitchShift.ar(in:signal,windowSize:0.05,pitchRatio:0.5);
		var signal_octave_LPF = LPF.ar(in: signal_octave,freq:220);
		var growl_signal = BBandPass.ar(in:signal_octave,freq:200,bw:3,mul:growl_level*2);
		var girth_signal = BBandPass.ar(in:signal_octave,freq:100,bw:3,mul:girth_level*1.5);
		var mid_plus_signal = BPeakEQ.ar(in:signal,freq:400,rq:2,db:10,mul:mid_plus_switch);
		var output = (signal*(1-mid_plus_switch) + mid_plus_signal)*dry_level + growl_signal + girth_signal;

		output = (output * on) + (signal * (1-on));

		Out.ar([12,13], output);
}).send;
)

~synth_octaverM288 = Synth("octaverM288");

////// Graphic //////
(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 580;
var win_height = 320;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var knob_dim = 140;
var button_dim = 60;

w = Window("MXR BASS OCTAVE DELUXE", Rect(left_padding, top_padding, win_width, win_height)).front;
w.background = Color.blue;
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

~blank_label = StaticText(w, 220@30);

~on_button = Button(w,button_dim@button_dim)
.states_([ ["OFF", Color.white, Color.red], ["ON", Color.white, Color.green] ])
.font_(Font("Monaco",18))
.action_({arg obj;
	      if( obj.value == 1,
		        {~synth_octaverM288 = Synth("octaverM288");
			     ~synth_octaverM288.set(\dry_level,~dry_level_knob.value.round(0.01));
				 ~synth_octaverM288.set(\growl_level,~growl_level_knob.value.round(0.01));
				 ~synth_octaverM288.set(\girth_level,~girth_level_knob.value.round(0.01));
				 ~synth_octaverM288.set(\mid_plus_switch,~mid_plus_button.value);
		        },
	            {~synth_octaverM288.free;}
	        );});

~blank_label = StaticText(w, 220@30);

~mid_plus_button = Button(w,button_dim@button_dim)
.states_([ ["MID+", Color.white, Color.gray], ["MID+", Color.white, Color.red] ])
.font_(Font("Monaco",18))
.value_(0)
.action_({arg obj;
	      if( obj.value == 1,
		        {~synth_octaverM288.set(\mid_plus_switch,1);},
	            {~synth_octaverM288.set(\mid_plus_switch,0);}
	        );});

~dry_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var dry_level = obj.value.round(0.01);
	       ~synth_octaverM288.set(\dry_level, dry_level);
           });

~growl_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var growl_level = obj.value.round(0.01);
	       x.set(\growl_level, growl_level);
           });

~girth_level_knob = Knob(w, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	       var girth_level = obj.value.round(0.01);
	       ~synth_octaverM288.set(\girth_level, girth_level);
           });

~blank_label = StaticText(w, button_dim@30);

~dry_level_label = StaticText(w, knob_dim@30)
.string_("DRY")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~growl_level_label = StaticText(w, knob_dim@30)
.string_("GROWL")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

~girth_level_label = StaticText(w, knob_dim@30)
.string_("GIRTH")
.font_(Font("Monaco",20))
.stringColor_(Color.white)
.align_(\center);

w.front;

w.onClose={~synth_octaverM288.free;};
)