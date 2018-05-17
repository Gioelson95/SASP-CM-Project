s.boot;

b = Buffer.read(s,"/Users/alessandro/Desktop/WAHWAH.aif");

//set the server
(
thisProcess.openUDPPort(52000);
NetAddr("192.168.2.7",52000);
)

(
SynthDef.new("wahwah",
	{
		arg
		freq = 750;
		var signal = PlayBuf.ar(2, b.bufnum);
		//var signal = In.ar(2);

		var outputFreqBoost = BPeakEQ.ar(in: signal, freq: freq, rq: 0.58, db: 12, mul: 1, add: 0);
		var outputHPF = HPF.ar(in: outputFreqBoost, freq: freq*0.8);
		var outputLPF = LPF.ar(in: outputHPF, freq: freq*1.6);
		var output = outputLPF + outputLPF.distort*0.25;

		Out.ar([0,1], channelsArray:output);
    }).send;
)

x = Synth("wahwah");

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
	       x.set(\freq, freq);
           });


~freq_label = StaticText(parent:w, bounds:slider_dim_width@30)
.string_("FREQUENCE")
.font_(Font("Monaco",20))
.align_(\center);
)

(

OSCdef('OSCreceiver',
	{
		arg msg;
		var freq;

		freq = msg[1].linlin(inMin:0, inMax:0.5, outMin:400, outMax:1600).round(1);
		freq.postln;
		x.set(\freq,freq);
		Routine{
			~freq_slider.valueAction_(freq.linlin(400,1600,0,1));
		}.play(AppClock);
	},
	"/mobile1/rotation");
)


// "/mobile1/rotation" for android with Eyw application








