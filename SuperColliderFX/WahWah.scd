s.boot;

b = Buffer.read(s,"/Users/gioelepozzi/Desktop/SASP-CM-Project/AudioSamples/NOTE.aif");

//wahwah -> bandpass filterwith resonant peak at its low-pass roll-off frequency

(
SynthDef.new("wahwah",
	{
		arg
		freq = 750;
		var signal = PlayBuf.ar(2, b.bufnum);
		//var signal = In.ar(2);

		var outputHPF = HPF.ar(in:signal,freq:freq);
		var outputRHPF = RHPF.ar(in:outputHPF,freq:freq,rq:2);
		var output = LPF.ar(in:outputRHPF,freq:freq);

		Out.ar([0,1], channelsArray:output);
    }).send;
)

x = Synth("wahwah");

(
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 160;
var win_height = 280;
var left_padding = (screen_width-win_width)/2;
var top_padding = (screen_height-win_height)/2;

var slider_dim_width = 120;
var slider_dim_height = 200;


w = Window("Wah-Wah", Rect(left_padding, top_padding, win_width, win_height)).front;
w.view.decorator_(FlowLayout(w.bounds, 20@20, 20@20));

~freq_slider = Slider(w, slider_dim_width@slider_dim_height)
.value_(0.5)
.action_({ arg obj;
	       var freq = obj.value.linlin(0,1,450,1600).round(1);
	       x.set(\freq, freq);
           });

~freq_label = StaticText(w, slider_dim_width@30)
.string_("FREQUENCE")
.font_(Font("Monaco",20))
.align_(\center);
)












