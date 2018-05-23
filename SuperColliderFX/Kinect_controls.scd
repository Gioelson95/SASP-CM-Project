// buttons that control the kinect

(

var screen_width = Window.screenBounds.width;
var screen_height = Window.screenBounds.height;
var win_width = 580;
var win_height = 100;
var left_pad = (screen_width - win_width)/2;
var top_pad = (screen_height - win_height)/2;

Window.closeAll;
w = Window(name:"Controls", bounds:Rect(left:left_pad, top:top_pad, width:win_width, height:win_height),resizable:false, border:true, server:s, scroll:false);
w.front;
w.view.decorator_(FlowLayout(bounds:w.bounds, margin:20@20, gap:20@20));

~kinect_octave = Button(w, 120@60)
.states_([ ["OCT KINECT OFF", Color.white, Color.gray], ["OCT KINECT ON", Color.white, Color.red] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {
			     ~kinect_tube.valueAction_(0);
			     ~kinect_chorus.valueAction_(0);
			     ~kinect_delay.valueAction_(0);
			     ~kinect_octave_receiver = OSCFunc("OSCKinectOctave");
		        },
		        {
			     ~kinect_octave_receiver.free;
		        }
	          );
           });

~kinect_tube = Button(w, 120@60)
.states_([ ["TS KINECT OFF", Color.white, Color.gray], ["TS KINECT ON", Color.white, Color.red] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {
			     ~kinect_octave.valueAction_(0);
			     ~kinect_chorus.valueAction_(0);
			     ~kinect_delay.valueAction_(0);
			     ~kinect_tube_receiver = OSCFunc("OSCKinectTS");
		        },
		        {
			     ~kinect_tube_receiver.free;
		        }
	          );
           });

~kinect_chorus = Button(w, 120@60)
.states_([ ["CH KINECT OFF", Color.white, Color.gray], ["CH KINECT ON", Color.white, Color.red] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {
			     ~kinect_octave.valueAction_(0);
			     ~kinect_tube.valueAction_(0);
			     ~kinect_delay.valueAction_(0);
			     ~kinect_chorus_receiver = OSCFunc("OSCKinectChorus");
		        },
		        {
			     ~kinect_chorus_receiver.free;
		        }
	          );
           });

~kinect_delay = Button(w, 120@60)
.states_([ ["DL KINECT OFF", Color.white, Color.gray], ["DL KINECT ON", Color.white, Color.red] ])
.action_({ arg obj;
	       if( obj.value == 1,
		        {
			     ~kinect_tube.valueAction_(0);
			     ~kinect_chorus.valueAction_(0);
			     ~kinect_octave.valueAction_(0);
		         ~kinect_delay_receiver = OSCFunc("OSCKinectDelay");
		        },
		        {
			     ~kinect_delay_receiver.free;
		        }
	          );
           });

)


(
~kinect_octave_receiver = OSCdef.new('OSCKinectOctave',
	{
		arg msg;

		Routine{

		}.play(AppClock);
    },
	\KinectOSC);

~kinect_tube_receiver = OSCdef.new('OSCKinectTS',
	{
		arg msg;

		Routine{

		}.play(AppClock);
    },
	\KinectOSC);

~kinect_chorus_receiver = OSCdef.new('OSCKinectChorus',
	{
		arg msg;

		Routine{

		}.play(AppClock);
    },
	\KinectOSC);

~kinect_delay_receiver = OSCdef.new('OSCKinectDelay',
	{
		arg msg;

		Routine{

		}.play(AppClock);
    },
	\KinectOSC);


)





