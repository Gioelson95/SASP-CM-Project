import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup(){
  
  size(800, 200); // dimensione finestra grafica

  frameRate(125);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",57120); 
}
  
void draw ()
{
    background(0);
    stroke(255);
    
    OscMessage myMessage = new OscMessage("/pos");
    myMessage.add(mouseX/(float)width);
    myMessage.add(mouseY/(float)height);
    oscP5.send(myMessage,myRemoteLocation);
    myMessage.print();
}
