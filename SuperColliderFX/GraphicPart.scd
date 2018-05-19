// set the default I/O
Server.default.options.outDevice_("Soundflower (2ch)");
Server.default.options.inDevice_("ONE");
s.boot;

// Set up the server net
(
thisProcess.openUDPPort(52000);
NetAddr("192.168.2.7",52000);
)

////// PLAY //////
(
~synth_wahwah = Synth("wahwah");
~synth_octaverM288 = Synth.after(~synth_wahwah,"octaverM288");
~synth_tubeScreamer = Synth.after(~synth_octaverM288,"tubeScreamer");
~synth_stereoDelay = Synth.after(~synth_tubeScreamer,"stereoDelay");
)

/////////////////////////////////////////////// GRAPHIC PART //////////////////////////////////////////

(
// Main window parameters
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 0.522*screen_width;
var win_height = 0.798*screen_height;
var left_pad = (screen_width - win_width)/2;
var top_pad = (screen_height - win_height)/2;
var win_color = Color(red:224, green:224, blue:224);  // Classic light grey
var win_margin = 0.01*screen_width;
var win_gap = 0.006*screen_width;

// Composite view parameters
var comp_view_margin = win_margin;
var comp_view_gap = win_gap;

// Knob parameters
var knob_dim = 0.056*screen_width;
var knob_inital_value = 0.5;

// Slider parameters
var slider_width = 0.035*screen_width;
var slider_height = 0.056*screen_width;
var slider_size = 0.017*screen_height;   // dimension of the moving part of the slider
var slider_initial_value = 0.22;
var slider_color = Color.black;

// Label parameters
var label_height = 0.022*screen_height;

// Font parameters
var font_type = "Monaco";
var font_size = 13;
var font_color = Color.white;

// Button parameters
var button_width = 0.056*screen_width;
var button_height = 0.033*screen_height;
var button_setting_width = 0.11*screen_width;
var button_on_color = Color.red;
var button_off_color = Color.grey;

// Text parameters
var text_height = 0.018*screen_height;

// Background images
var tubeScreamer_img = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/Images/TubeScreamer.png");
var stereoDelay_img = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/Images/StereoDelay.png");
var octaverM288_img = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/Images/OctaverM288.png");

// Initialization of main window
Window.closeAll;
w = Window(name:"Effects", bounds:Rect(left:left_pad, top:top_pad, width:win_width, height:win_height),resizable:false, border:true, server:s, scroll:false);
w.front;
w.view.decorator_(FlowLayout(bounds:w.bounds, margin:win_margin@win_margin, gap:win_gap@win_gap));
w.background_(win_color);

/////////////////// SETTINGS ///////////////////

~settings_view = CompositeView(parent:w, bounds:(win_width-(2*win_margin))@(win_height*0.12))
.background_(Color.blue)
.decorator_(FlowLayout(bounds:w.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~settings_label = StaticText(parent:~settings_view, bounds:(win_width-(2*win_margin))@label_height)
.string_("Settings")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align_(\center);

~settings_view.decorator.nextLine;

~on_off_wahwah = Button(~settings_view,(button_setting_width)@button_height)
.states_([ ["OFF Wah-Wah", font_color, button_off_color], ["ON Wah-Wah", font_color, button_on_color] ])
.font_(Font(name:font_type,size:font_size))
.action_({arg obj;
	if( obj.value == 1,
		{~synth_wahwah.set(\on_off,1);},
		{~synth_wahwah.set(\on_off,0);}
);});

~on_off_OctaverM288 = Button(~settings_view,(button_setting_width)@button_height)
.states_([ ["OFF OctaverM288", font_color, button_off_color], ["ON OctaverM288", font_color, button_on_color] ])
.font_(Font(name:font_type,size:font_size))
.action_({arg obj;
	if( obj.value == 1,
		{~synth_octaverM288.set(\on_off,1);},
		{~synth_octaverM288.set(\on_off,0);}
);});

~on_off_tubeScreamer = Button(~settings_view,(button_setting_width)@button_height)
.states_([ ["OFF Tube Screamer", font_color, button_off_color], ["ON Tube Screamer", font_color, button_on_color] ])
.font_(Font(name:font_type,size:font_size))
.action_({arg obj;
	if( obj.value == 1,
		{~synth_tubeScreamer.set(\on_off,1);},
		{~synth_tubeScreamer.set(\on_off,0);}
);});

~on_off_stereoDelay = Button(~settings_view,(button_setting_width)@button_height)
.states_([ ["OFF Stereo Delay", font_color, button_off_color], ["ON Stereo Delay", font_color, button_on_color] ])
.font_(Font(font_type,font_size))
.action_({arg obj;
	if( obj.value == 1,
		{~synth_stereoDelay.set(\on_off,1);},
		{~synth_stereoDelay.set(\on_off,0);}
);});

w.view.decorator.nextLine;

/////////////////// WAH-WAH ///////////////////

// WahWah view
~wahwah_view = CompositeView(parent:w, bounds:(0.054*screen_width)@(0.18*screen_height))
.background_(Color.black)
.decorator_(FlowLayout(bounds:w.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~wahwah_label = StaticText(parent:~wahwah_view, bounds:Rect(width:75,height:label_height))
.string_("WahWah")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align(\center);

~wahwah_view.decorator.nextLine;

// Slider for the WahWah effect
~freq_slider = Slider(parent:~wahwah_view, bounds:Rect(width:slider_width,height:slider_height))
.thumbSize_(pixels:slider_size)
.value_(slider_initial_value)
.background_(slider_color)
.action_({
	arg obj;
	var freq = obj.value.linlin(inMin:0, inMax:1, outMin:400, outMax:1600).round(1);
	~synth_wahwah.set(\freq, freq);
});

~wahwah_view.decorator.nextLine;

~freq_label = StaticText(parent:~wahwah_view, bounds:Rect(width:50,height:label_height))
.string_("FREQ")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align_(\center);

/////////////////// OCTAVER M288 ///////////////////

// OctaverM288 view
~octaverM288_view = CompositeView(parent:w, bounds:(0.235*screen_width)@(0.18*screen_height))
.backgroundImage_(octaverM288_img)
.decorator_(FlowLayout(bounds:w.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~octaverM288_label = StaticText(parent:~octaverM288_view, bounds:(0.26*screen_width-(2*comp_view_margin))@label_height)
.string_("Octaver M288")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align_(\center);

~octaverM288_view.decorator.nextLine;

~mid_plus_button = Button(~octaverM288_view,(button_width/2)@button_height)
.states_([ ["MID+", font_color, button_off_color], ["MID+", font_color, button_on_color] ])
.font_(Font(font_type,font_size))
.value_(0)
.action_({arg obj;
	if( obj.value == 1,
		{~synth_octaverM288.set(\mid_plus_switch,1);},
		{~synth_octaverM288.set(\mid_plus_switch,0);}
);});

~dry_level_knob = Knob(~octaverM288_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	var dry_level = obj.value.round(0.01);
	~synth_octaverM288.set(\dry_level, dry_level);
});

~growl_level_knob = Knob(~octaverM288_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	var growl_level = obj.value.round(0.01);
	~synth_octaverM288.set(\growl_level, growl_level);
});

~girth_level_knob = Knob(~octaverM288_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	var girth_level = obj.value.round(0.01);
	~synth_octaverM288.set(\girth_level, girth_level);
});

~octaverM288_view.decorator.nextLine;

~blank_label = StaticText(~octaverM288_view, (knob_dim/2)@label_height)
.string_("")
.font_(Font(name:font_type,size:font_size));

~dry_level_label = StaticText(~octaverM288_view, knob_dim@label_height)
.string_("DRY")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align_(\center);

~growl_level_label = StaticText(~octaverM288_view, knob_dim@label_height)
.string_("GROWL")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align_(\center);

~girth_level_label = StaticText(~octaverM288_view, knob_dim@label_height)
.string_("GIRTH")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align_(\center);

/////////////////// TUBE SCREAMER ///////////////////

// TubeScreamer view
~tubeScreamer_view = CompositeView(parent:w, bounds:(0.2*screen_width)@(0.18*screen_height))
.backgroundImage_(tubeScreamer_img)
.decorator_(FlowLayout(bounds:w.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~tubeScreamer_label = StaticText(parent:~tubeScreamer_view, bounds:(0.2*screen_width-(2*comp_view_margin))@label_height)
.string_("Green Poli Screamer")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align_(\center);

~tubeScreamer_view.decorator.nextLine;

~volume_knob = Knob(~tubeScreamer_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	       var volume = obj.value.linlin(0,1,0,2).round(0.01);
	       ~synth_tubeScreamer.set(\volume, volume);
           });

~tone_knob = Knob(~tubeScreamer_view, knob_dim@knob_dim)
.value_(knob_inital_value*2)
.action_({ arg obj;
	       var tone = obj.value.linlin(0,1,270,823).round(0.01);
	       ~synth_tubeScreamer.set(\tone, tone);
           });

~gain_knob = Knob(~tubeScreamer_view, knob_dim@knob_dim)
.value_(knob_inital_value)
.action_({ arg obj;
	       var gain = obj.value.round(0.01);
	       ~synth_tubeScreamer.set(\gain, gain);
           });

~tubeScreamer_view.decorator.nextLine;

~volume_label = StaticText(~tubeScreamer_view, knob_dim@label_height)
.string_("VOLUME")
.font_(Font(name:font_type,size:font_size))
.stringColor_(Color.white)
.align_(\center);

~bass_label = StaticText(~tubeScreamer_view, knob_dim@label_height)
.string_("TONE")
.font_(Font(name:font_type,size:font_size))
.stringColor_(Color.white)
.align_(\center);

~middle_label = StaticText(~tubeScreamer_view, knob_dim@label_height)
.string_("GAIN")
.font_(Font(name:font_type,size:font_size))
.stringColor_(Color.white)
.align_(\center);

~name_label = StaticText(~tubeScreamer_view, knob_dim*2@60)
.string_("GREEN POLI SCREAMER")
.font_(Font(name:font_type,size:font_size))
.stringColor_(Color.black)
.align_(\center);

w.view.decorator.nextLine;

/////////////////// STEREO DELAY ///////////////////

// Stereo Delay view
~stereoDelay_view = CompositeView(parent:w, bounds:(0.26*screen_width)@(0.47*screen_height))
.backgroundImage_(stereoDelay_img)
.decorator_(FlowLayout(bounds:w.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~stereoDelay_label = StaticText(parent:~stereoDelay_view, bounds:(0.26*screen_width-(2*comp_view_margin))@label_height)
.string_("Stereo Delay")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align_(\center);

~stereoDelay_view.decorator.nextLine;

~level_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	var level = obj.value.round(0.01);
	~synth_stereoDelay.set(\level, level);
	~level_text.string_(20*log(level).round(0.01)+"dB");
});

~time_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.375)
.action_({ arg obj;
	var bpm = obj.value.linlin(0,1,40,200).round(1);
	~synth_stereoDelay.set(\bpm, bpm);
	~time_text.value_(bpm);
});

~feedback_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	var rep = obj.value.linlin(0,1,0,8).round(1);
	~synth_stereoDelay.set(\rep, rep);
	~feedback_text.string_(rep+"Rep");
});

~tone_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.25)
.action_({ arg obj;
	var tone = obj.value.linlin(0,1,1000,7000).round(0.01);
	~synth_stereoDelay.set(\tone, tone);
	~tone_text.string_(tone+"Hz");
});

~stereoDelay_view.decorator.nextLine;

~level_text = StaticText(~stereoDelay_view, knob_dim@text_height)
.string_(20*log(~level_knob.value).round(0.01)+"dB")
.font_(Font(font_type,font_size-4))
.stringColor_(font_color)
.align_(\center);

~time_text = NumberBox(~stereoDelay_view, ((knob_dim-comp_view_gap)/2)@text_height)
.value_(100)
.clipLo_(40)
.clipHi_(200)
.font_(Font(font_type,font_size-4))
.normalColor_(Color.black)
.stringColor_(Color.black)
.typingColor_(Color.black)
.align_(\center)
.background_(Color.white)
.buttonsVisible_(false)
.action_({ arg obj;
	~time_knob.valueAction_(obj.value.linlin(40,200,0,1));
});
~blank_label = StaticText(~stereoDelay_view, ((knob_dim-comp_view_gap)/2)@text_height)
.string_("BPM")
.font_(Font(font_type,font_size-4))
.stringColor_(Color.white)
.align_(\left);

~feedback_text = StaticText(~stereoDelay_view, knob_dim@text_height)
.string_(~feedback_knob.value.linlin(0,1,0,8)+"Rep")
.font_(Font(font_type,font_size-4))
.stringColor_(Color.white)
.align_(\center);

~tone_text = StaticText(~stereoDelay_view, knob_dim@text_height)
.string_(~tone_knob.value.linlin(0,1,1000,7000)+"Hz")
.font_(Font(font_type,font_size-4))
.stringColor_(font_color)
.align_(\center);

~stereoDelay_view.decorator.nextLine;

~level_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("LEVEL")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~time_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("TIME")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~feedback_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("FEEDBACK")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~tone_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("TONE")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~stereoDelay_view.decorator.nextLine;

// chorus controls

~chorus_switch = Button(~stereoDelay_view, button_width@button_height)
.states_([ ["CHORUS", font_color, button_off_color], ["CHORUS", font_color, button_on_color] ])
.font_(Font(font_type,font_size))
.action_({ arg obj;
	if( obj.value == 1,
		{~synth_stereoDelay.set(\mix, ~mix_knob.value);
			~mix_knob.enabled_(true);},

		{~synth_stereoDelay.set(\mix, 0);
			~mix_knob.enabled_(false);} );
});

~mix_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.6)
.enabled_(false)
.action_({ arg obj;
	var mix = obj.value.round(0.01);
	~synth_stereoDelay.set(\mix, mix);
});

~rate_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	var rate = obj.value.round(0.001);
	~synth_stereoDelay.set(\rate, rate);
});

~depth_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.625)
.action_({ arg obj;
	var depth = obj.value.obj.value.linlin(0,1,0.25,1).round(0.01);
	~synth_stereoDelay.set(\depth, depth);
});

~stereoDelay_view.decorator.nextLine;

~blank_label = StaticText(~stereoDelay_view, knob_dim@label_height);

~mix_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("MIX")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~rate_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("RATE")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~depth_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("DEPTH")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~stereoDelay_view.decorator.nextLine;

// reverb controls

~reverb_switch = Button(~stereoDelay_view, button_width@button_height)
.states_([ ["REVERB", font_color, button_off_color],["REVERB", font_color, button_on_color] ])
.font_(Font(font_type,font_size))
.action_({ arg obj;
	if( obj.value == 1,
		{~synth_stereoDelay.set(\blend, ~blend_knob.value);
			~blend_knob.enabled_(true);},

		{~synth_stereoDelay.set(\blend, 0);
			~blend_knob.enabled_(false);} );
});

~blend_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.enabled_(false)
.value_(0.3)
.action_({ arg obj;
	var blend = obj.value.round(0.01);
	~synth_stereoDelay.set(\blend, blend);
});

~presence_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.9)
.action_({ arg obj;
	var presence = obj.value.linlin(0,1,1000,8000).round(0.01);
	~synth_stereoDelay.set(\presence, presence);
});

~decay_knob = Knob(~stereoDelay_view, knob_dim@knob_dim)
.value_(0.5)
.action_({ arg obj;
	var decay = obj.value.round(0.01);
	~synth_stereoDelay.set(\decay, decay);
});

~stereoDelay_view.decorator.nextLine;

~blank_label = StaticText(~stereoDelay_view, knob_dim@label_height);

~blend_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("BLEND")
.font_(Font(font_type,(font_size)))
.stringColor_(font_color)
.align_(\center);

~presence_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("PRESENCE")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~decay_label = StaticText(~stereoDelay_view, knob_dim@label_height)
.string_("DECAY")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

/////////////////// KINECT ///////////////////

// Kinect view
~kinect_view = CompositeView(parent:w, bounds:(0.235*screen_width)@(0.47*screen_height))
.background_(Color.grey)
.decorator_(FlowLayout(bounds:w.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~kinect_label = StaticText(parent:~kinect_view, bounds:Rect(width:150,height:label_height))
.string_("Kinect View")
.font_(Font(name:font_type,size:font_size))
.stringColor_(font_color)
.align(\center);

)

/////////////////////////////////////////////// OSC //////////////////////////////////////////

(

~wahwah_OSC_path = "/mobile1/rotation";
~wahwah_OSC_num = 1;

OSCdef('OSCreceiverPhone',
	{
		arg msg;
		var freq = msg[~wahwah_OSC_num].linlin(inMin:(-0.15), inMax:0.04, outMin:400, outMax:1600).round(1);
		Routine{
			~freq_slider.valueAction_(freq.linlin(400,1600,0,1));
		}.play(AppClock);
	},
	~wahwah_OSC_path);

)

(
OSCdef.new('OSCreceiverKinect',
	{
		arg msg;

		Routine{
			~level_knob.valueAction_(msg[1]);
			~feedback_knob.valueAction_(msg[2]);
		}.play(AppClock);
    },
	\KinectOSC);
)
