(
SynthDef(\sine, { |amp = 0.5, freq = 440|
	var data = SinOsc.ar(freq, 0, amp);
	Out.ar(0, data ! 2);
}).send(s);
)

NetAddr.localAddr; // serve solo per vedere l'indirizzo del server

x = Synth(\sine);

// Definisco un ricevitore di messaggi OSC

(
OSCdef.new('prova1' /*nome dell'OSCdef'*/,{
	arg msg; // è il messaggio OSC, è un vettore che contiene i valori inviati
	msg[1].postln; // l'array parte da 1 :(
	x.set(\freq,msg[1].linlin(0,1,100,1000)); // uso il valore per variare il valore del sinthdef
},\pos /* è il percorso del messaggio OSC*/);
)





