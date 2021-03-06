
////// Synth for the WahWah //////

(
~synth_wahwah = SynthDef("wahwah",
	{
		arg
		freq = 750,
		on = 0;

		var signal = In.ar(2,2);

		var outputFreqBoost = BPeakEQ.ar(in: signal, freq: freq.lag(0.5), rq: 0.58, db: 12, mul: 1, add: 0);
		var outputHPF = HPF.ar(in: outputFreqBoost, freq: freq*0.8);
		var outputLPF = LPF.ar(in: outputHPF, freq: freq*1.6);
		var output = outputLPF + outputLPF.distort*0.25;

		output = (output*4 * on) + (signal * (1-on));

		Out.ar([10,11], channelsArray:output);
}).send;
)

~synth_wahwah = Synth("wahwah");

////// Graphic //////
(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 280;
var win_height = 615;
var left_padding = (screen_width - win_width)/2;
var top_padding = (screen_height - win_height)/2;

var slider_dim_width = 240;
var slider_dim_height = 500;

var i = QImage.new("/Users/alessandro/Desktop/Images/WahWah.png");

w = Window("Wah-Wah", Rect(left:left_padding, top:top_padding, width:win_width, height:win_height)).front;
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));
w.view.backgroundImage_(i);

~freq_slider = Slider(parent:w, bounds:slider_dim_width@slider_dim_height)
.background_(Color.black)
.value_(0.22)
.action_({ arg obj;
	       var freq = obj.value.linlin(inMin:0, inMax:1, outMin:400, outMax:1600).round(1);
	       ~synth_wahwah.set(\freq, freq);
           });


~freq_label = StaticText(parent:w, bounds:130@30)
.string_("SGNAH SGNAH")
.font_(Font("Monaco",18))
.stringColor_(Color.white)
.align_(\center);

~switch = Button(w, 90@60)
.states_([ ["", Color.white, Color.gray], ["", Color.white, Color.red] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {~synth_wahwah.set(\on, 1);},
	            {~synth_wahwah.set(\on, 0);} );
           });
)

////// OSC //////

(
~smartphone_receiver = OSCdef('OSCreceiverPhone',
	{
		arg msg;
		var freq = msg[1].linlin(inMin:(-0.05), inMax:0.005, outMin:1600, outMax:400).round(1);
		Routine{
			~freq_slider.valueAction_(freq.linlin(400,1600,0,1));
		}.play(AppClock);
		msg.postln;
	},
	"/mobile1/rotation");
)