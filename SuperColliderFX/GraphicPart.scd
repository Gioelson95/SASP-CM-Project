// set the default I/O
Server.default.options.outDevice_("Soundflower (2ch)");
Server.default.options.inDevice_("ONE");
s.boot;

// Set up the server net
(
thisProcess.openUDPPort(52000);
NetAddr("192.168.2.5",52000);
)

/*(
thisProcess.openUDPPort(52000);
NetAddr("127.0.0.1",52000);
)*/

////// PLAY //////
(
~synth_wahwah = Synth("wahwah");
~synth_octaverM288 = Synth.after(~synth_wahwah,"octaverM288");
~synth_tubeScreamer = Synth.after(~synth_octaverM288,"tubeScreamer");
~synth_chorus = Synth.after(~synth_tubeScreamer,"stereoChorus");
~synth_stereoDelay = Synth.after(~synth_chorus,"stereoDelay");
)

/////////////////////////////////////////////// GRAPHIC PART //////////////////////////////////////////

(
// Main window parameters
var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 0.6747*screen_width;
var win_height = 0.627*screen_height;
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
var slider_width = 0.10*screen_width;
var slider_height = 0.23*screen_width;
var slider_size = 0.03*screen_height;   // dimension of the moving part of the slider
var slider_initial_value = 0.22;
var slider_color = Color.fromHexString("222222");

// Label parameters
var label_height = 0.022*screen_height;

// Font parameters
var font_type = "Monaco";
var font_size = 13;
var font_size_name = 13;
var font_color = Color.white;

// Button parameters
var button_width = 0.056*screen_width;
var button_height = 0.033*screen_height;
var button_setting_width = 0.12*screen_width;
var button_on_color = Color.red;
var button_color = Color.grey;

// Text parameters
var text_height = 0.018*screen_height;

// Background images
// Alessandro
var tubeScreamer_img = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/Images/TubeScreamer.png");
var stereoDelay_img = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/Images/StereoDelay.png");
var octaverM288_img = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/Images/OctaverM288.png");
var chorus_img = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/Images/StereoChorus.png");
var wah_img = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/Images/WahWah.png");
var ctrl_img = QImage.new("/Users/alessandro/OneDrive - Politecnico di Milano/Università/Quarto Anno/Computer Music/SASP-CM-Project/Images/Controls.png");

//Gioele
/*var tubeScreamer_img = QImage.new("/Users/gioelepozzi/Desktop/SASP-CM-Project/Images/TubeScreamer.png");
var stereoDelay_img = QImage.new("/Users/gioelepozzi/Desktop/SASP-CM-Project/Images/StereoDelay.png");
var octaverM288_img = QImage.new("/Users/gioelepozzi/Desktop/SASP-CM-Project/Images/OctaverM288.png");*/

/*var tubeScreamer_img = QImage.new("/Users/lucavilla/Desktop/SASP-CM-Project/Images/TubeScreamer.png");
var stereoDelay_img = QImage.new("/Users/lucavilla/Desktop/SASP-CM-Project/Images/StereoDelay.png");
var octaverM288_img = QImage.new("/Users/lucavilla/Desktop/SASP-CM-Project/Images/OctaverM288.png");
var chorus_img = QImage.new("/Users/lucavilla/Desktop/SASP-CM-Project/Images/StereoChorus.png");
var wah_img = QImage.new("/Users/lucavilla/Desktop/SASP-CM-Project/Images/WahWah.png");
var ctrl_img = QImage.new("/Users/lucavilla/Desktop/SASP-CM-Project/Images/Controls.png");*/


// Initialization of main window
Window.closeAll;
w = Window(name:"Effects", bounds:Rect(left:left_pad, top:top_pad, width:win_width, height:win_height),resizable:false, border:true, server:s, scroll:false);
w.front;
w.view.decorator_(FlowLayout(bounds:w.bounds, margin:win_margin@win_margin, gap:win_gap@win_gap));
w.background_(win_color);

/////////////////// SETTINGS ///////////////////
~settings_content_view = CompositeView(parent:w, bounds:(0.651*screen_width)@(0.09*screen_height))
.decorator_(FlowLayout(bounds:w.bounds));

~settings_view = CompositeView(parent:~settings_content_view, bounds:(0.646*screen_width)@(0.081*screen_height))
.backgroundImage_(ctrl_img)
.decorator_(FlowLayout(bounds:~settings_content_view.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~settings_view.decorator.nextLine;

~settings_label = StaticText(parent:~settings_view, bounds:(knob_dim*2@label_height))
.string_("KINECT SETTINGS")
.font_(Font(name:font_type,size:font_size_name+2))
.stringColor_(font_color);

~kinect_octave = Button(~settings_view, button_setting_width@button_height)
.states_([ ["OCTAVE KINECT OFF", font_color, button_color], ["OCTAVE KINECT ON", font_color, button_on_color] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {
			     ~kinect_tube.valueAction_(0);
			     ~kinect_chorus.valueAction_(0);
			     ~kinect_delay.valueAction_(0);
		        },
		        {}
	          );
           });

~kinect_tube = Button(~settings_view, button_setting_width@button_height)
.states_([ ["TS KINECT OFF", font_color, button_color], ["TS KINECT ON", font_color, button_on_color] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {
			     ~kinect_octave.valueAction_(0);
			     ~kinect_chorus.valueAction_(0);
			     ~kinect_delay.valueAction_(0);
		        },
		        {}
	          );
           });

~kinect_chorus = Button(~settings_view, button_setting_width@button_height)
.states_([ ["CHORUS KINECT OFF", font_color, button_color], ["CHORUS KINECT ON", font_color, button_on_color] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {
			     ~kinect_octave.valueAction_(0);
			     ~kinect_tube.valueAction_(0);
			     ~kinect_delay.valueAction_(0);
		        },
		        {}
	          );
           });

~kinect_delay = Button(~settings_view, button_setting_width@button_height)
.states_([ ["DELAY KINECT OFF", font_color, button_color], ["DELAY KINECT ON", font_color, button_on_color] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {
			     ~kinect_tube.valueAction_(0);
			     ~kinect_chorus.valueAction_(0);
			     ~kinect_octave.valueAction_(0);
		        },
		        {}
	          );
           });

w.view.decorator.nextLine;

// Effect content view
~effect_content_view = CompositeView(parent:w, bounds:(0.475*screen_width)@(0.495*screen_height))
.decorator_(FlowLayout(bounds:w.bounds));

/////////////////// STEREO DELAY ///////////////////

// Stereo Delay view
~stereoDelay_view = CompositeView(parent:~effect_content_view, bounds:(0.265*screen_width)@(0.24*screen_height))
.backgroundImage_(stereoDelay_img)
.decorator_(FlowLayout(bounds:~effect_content_view.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

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

~name_label = StaticText(~stereoDelay_view, knob_dim*3@label_height)
.string_("STEREO DIGITAL SARTYLEY")
.font_(Font(font_type,font_size_name))
.stringColor_(font_color)
.align_(\center);

~switch = Button(~stereoDelay_view, button_width@button_height)
.states_([ ["", font_color, button_color], ["", font_color, button_on_color] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {~synth_stereoDelay.set(\on, 1);},
	            {~synth_stereoDelay.set(\on, 0);} );
           });

/////////////////// CHORUS ///////////////////

// Chorus view
~chorus_view = CompositeView(parent:~effect_content_view, bounds:(0.2*screen_width)@(0.24*screen_height))
.backgroundImage_(chorus_img)
.decorator_(FlowLayout(bounds:~effect_content_view.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~chorus_view.decorator.nextLine;

~mix_knob = Knob(~chorus_view, knob_dim@knob_dim)
.value_(0.6)
.action_({ arg obj;
	       var mix = obj.value.round(0.01);
	       ~synth_chorus.set(\mix, mix);
	       ~mix_label.string_("MIX"+(mix*100)+"%")
           });

~rate_knob = Knob(~chorus_view, knob_dim@knob_dim)
.value_(0.3)
.action_({ arg obj;
	       var rate = obj.value.round(0.001);
	       ~synth_chorus.set(\rate, rate);
           });

~depth_knob = Knob(~chorus_view, knob_dim@knob_dim)
.value_(0.625)
.action_({ arg obj;
	       var depth = obj.value.linlin(0,1,0.25,1).round(0.01);
	       ~synth_chorus.set(\depth, depth);
           });

~chorus_view.decorator.nextLine;

~mix_label = StaticText(~chorus_view, knob_dim@label_height)
.string_("MIX"+(~mix_knob.value.round(0.01)*100)+"%")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~rate_label = StaticText(~chorus_view, knob_dim@label_height)
.string_("RATE")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~depth_label = StaticText(~chorus_view, knob_dim@label_height)
.string_("DEPTH")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\center);

~chorus_view.decorator.nextLine;

~blankLabel = StaticText(~chorus_view, knob_dim@label_height)
.string_("")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\left);

~chorus_view.decorator.nextLine;

~name_label = StaticText(~chorus_view, knob_dim*2@label_height)
.string_("STEREO POLYCHORUS")
.font_(Font(font_type,font_size_name))
.stringColor_(font_color)
.align_(\center);

~switch = Button(~chorus_view, button_width@button_height)
.states_([ ["", font_color, button_color], ["", font_color, button_on_color] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {~synth_chorus.set(\on, 1);},
	            {~synth_chorus.set(\on, 0);} );
           });


/////////////////// OCTAVER M288 ///////////////////

// OctaverM288 view
~octaverM288_view = CompositeView(parent:~effect_content_view, bounds:(0.265*screen_width)@(0.24*screen_height))
.backgroundImage_(octaverM288_img)
.decorator_(FlowLayout(bounds:~effect_content_view.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~octaverM288_view.decorator.nextLine;

~mid_plus_button = Button(~octaverM288_view,(button_width)@button_height)
.states_([ ["MID+", font_color, button_color], ["MID+", font_color, button_on_color] ])
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

~blank_label = StaticText(~octaverM288_view, (knob_dim)@label_height)
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

~octaverM288_view.decorator.nextLine;

~blankLabel = StaticText(~octaverM288_view, knob_dim@label_height)
.string_("")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\left);

~octaverM288_view.decorator.nextLine;

~name_label = StaticText(~octaverM288_view, knob_dim*3@label_height)
.string_("M288 OCTO-JOE")
.font_(Font(font_type,font_size_name))
.stringColor_(font_color)
.align_(\center);

~switch = Button(~octaverM288_view, button_width@button_height)
.states_([ ["", font_color, button_color], ["", font_color, button_on_color] ])
.action_({ arg obj;
	       if( obj.value == 1,
		{~synth_octaverM288.set(\on, 1);},
	            {~synth_octaverM288.set(\on, 0);} );
           });

/////////////////// TUBE SCREAMER ///////////////////

// TubeScreamer view
~tubeScreamer_view = CompositeView(parent:~effect_content_view, bounds:(0.2*screen_width)@(0.24*screen_height))
.backgroundImage_(tubeScreamer_img)
.decorator_(FlowLayout(bounds:~effect_content_view.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

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

~tubeScreamer_view.decorator.nextLine;

~blankLabel = StaticText(~tubeScreamer_view, knob_dim@label_height)
.string_("")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\left);

~tubeScreamer_view.decorator.nextLine;

~name_label = StaticText(~tubeScreamer_view, knob_dim*2.1@label_height)
.string_("GREEN POLYSCREAMER")
.font_(Font(font_type,font_size_name))
.stringColor_(font_color)
.align_(\center);

~switch = Button(~tubeScreamer_view, button_width@button_height)
.states_([ ["", Color.white, button_color], ["", Color.white, button_on_color] ])
.action_({ arg obj;
	       if( obj.value == 1,
		{~synth_tubeScreamer.set(\on, 1);},
	            {~synth_tubeScreamer.set(\on, 0);} );
           });


// WahWah content view
~wahwah_content_view = CompositeView(parent:w, bounds:(0.17*screen_width)@(0.495*screen_height))
.decorator_(FlowLayout(bounds:w.bounds));

/////////////////// WAH-WAH ///////////////////

// WahWah view
~wahwah_view = CompositeView(parent:~wahwah_content_view, bounds:(0.165*screen_width)@(0.485*screen_height))
.backgroundImage_(wah_img)
.decorator_(FlowLayout(bounds:~wahwah_content_view.bounds, margin:comp_view_margin@comp_view_margin, gap:comp_view_gap@comp_view_gap));

~wahwah_view.decorator.nextLine;

// Slider for the WahWah effect

~blankLabel = StaticText(~wahwah_view, 25@label_height)
.string_("")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\left);

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

~blankLabel = StaticText(~wahwah_view, knob_dim@label_height)
.string_("")
.font_(Font(font_type,font_size))
.stringColor_(font_color)
.align_(\left);

~wahwah_view.decorator.nextLine;

~name_label = StaticText(~wahwah_view, knob_dim*1.5@label_height)
.string_("SGNAH SGNAH")
.font_(Font(font_type,font_size_name))
.stringColor_(font_color)
.align_(\center);

~switch = Button(~wahwah_view, button_width@button_height)
.states_([ ["", font_color, button_color], ["", font_color, button_on_color] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {~synth_wahwah.set(\on, 1);},
	            {~synth_wahwah.set(\on, 0);} );
           });

)

/////////////////////////////////////////////// OSC //////////////////////////////////////////

(

~smartphone_receiver = OSCdef('OSCreceiverPhone',
	{
		arg msg;
		var freq = msg[1].linlin(inMin:(-0.15), inMax:0.04, outMin:1600, outMax:400).round(1);
		Routine{
			~freq_slider.valueAction_(freq.linlin(400,1600,0,1));
		}.play(AppClock);
	},
	"/mobile1/rotation");

~kinect_octave_receiver = OSCdef.new('OSCKinectOctave',
	{
		arg msg;

		Routine{
			if(~kinect_octave.value == 1,{
				~dry_level_knob.valueAction_(msg[1]);
			},{});
		}.play(AppClock);
	},
	\KinectOSC);

~kinect_tube_receiver = OSCdef.new('OSCKinectTS',
	{
		arg msg;

		Routine{
			if(~kinect_tube.value == 1,{
				~gain_knob.valueAction_(msg[1]);
				~volume_knob.valueAction_(msg[1].linlin(0,1,1,0.5));
			},{});

		}.play(AppClock);
	},
	\KinectOSC);

~kinect_chorus_receiver = OSCdef.new('OSCKinectChorus',
	{
		arg msg;

		Routine{
			if(~kinect_chorus.value == 1,{
				~rate_knob.valueAction_(msg[1]);
				~mix_knob.valueAction_(msg[2]);
			},{});
		}.play(AppClock);
	},
	\KinectOSC);

~kinect_delay_receiver = OSCdef.new('OSCKinectDelay',
	{
		arg msg;

		Routine{
			if(~kinect_delay.value == 1,{
				~level_knob.valueAction_(msg[1]);
				~feedback_knob.valueAction_(msg[2]);
			},{});
		}.play(AppClock);
	},
	\KinectOSC);
)