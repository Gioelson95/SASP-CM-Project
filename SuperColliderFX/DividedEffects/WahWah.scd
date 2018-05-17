s.boot;

// Set up the server
(
thisProcess.openUDPPort(52000);
NetAddr("192.168.2.7",52000);
)

////// Synth for the WahWah //////
(
~synth_wahwah = SynthDef("wahwah",
	{
		arg
		freq = 750,
		on_off = 0;

		//var signal = PlayBuf.ar(2, b.bufnum);
		var signal = In.ar(2,2);

		var outputFreqBoost = BPeakEQ.ar(in: signal, freq: freq.lag(0.5), rq: 0.58, db: 12, mul: 1, add: 0);
		var outputHPF = HPF.ar(in: outputFreqBoost, freq: freq*0.8);
		var outputLPF = LPF.ar(in: outputHPF, freq: freq*1.6);
		var output = outputLPF + outputLPF.distort*0.25;

		output = (output * on_off) + (signal * (1-on_off));

		Out.ar([10,11], channelsArray:output);
}).send;
)

~synth_wahwah = Synth("wahwah");

////// Graphic //////
(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 160;
var win_height = 280;
var left_padding = (screen_width - win_width)/2;
var top_padding = (screen_height - win_height)/2;

var slider_dim_width = 120;
var slider_dim_height = 200;


w = Window("Wah-Wah", Rect(left:left_padding, top:top_padding, width:win_width, height:win_height)).front;
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

~freq_slider = Slider(parent:w, bounds:slider_dim_width@slider_dim_height)
.background_(Color.black)
.value_(0.22)
.action_({ arg obj;
	       var freq = obj.value.linlin(inMin:0, inMax:1, outMin:400, outMax:1600).round(1);
	       ~synth_wahwah.set(\freq, freq);
           });


~freq_label = StaticText(parent:w, bounds:slider_dim_width@30)
.string_("FREQUENCE")
.font_(Font("Monaco",20))
.align_(\center);
)

////// OSC Receiver for mobile use //////
(
~wahwah_OSC_path = "/mobile1/rotation";

OSCdef('OSCreceiver',
	{
		arg msg;
		var freq;
		freq = msg[1].linlin(inMin:0, inMax:0.5, outMin:400, outMax:1600).round(1);
		~synth_wahwah.set(\freq,freq);
		Routine{
			~freq_slider.valueAction_(freq.linlin(400,1600,0,1));
		}.play(AppClock);
	},
	~wahwah_OSC_path);
)