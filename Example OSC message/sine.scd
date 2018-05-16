//s = Server(\server,NetAddr(hostname:"192.168.0.101",port:52000));
s.boot;

(
SynthDef(\sine, { |amp = 0.5, freq = 440|
	var data = SinOsc.ar(freq, 0, amp);
	Out.ar(0, data ! 2);
}).send(s);
)

NetAddr.localAddr; // serve solo per vedere l'indirizzo del server
x = Synth(\sine);

// Definisco un ricevitore di messaggi OSC
thisProcess.openUDPPort(52000);
NetAddr(hostname:"192.168.0.101",port:52000);
(
OSCdef.new('prova1',{
	arg msg;
	msg[1].postln;
	x.set(\freq,msg[1].linlin(0,1,100,1000));
}
, path: "\mobile1/gyro"
, srcID:"192.168.0.101",recvPort:52000
);

)





