import SimpleOpenNI.*;
import oscP5.*;
import netP5.*;

SimpleOpenNI kinect;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  size(640, 480);
  fill(255, 0, 0);
  kinect.setMirror(true);
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("192.168.43.69",52000);
  //myRemoteLocation = new NetAddress("127.0.0.1",52000); 

}

void draw() {

  kinect.update();
  image(kinect.userImage(),0,0);
  
  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  if (userList.size() > 0) {
    int userId = userList.get(0);
    //If we detect one user we have to draw it
    if ( kinect.isTrackingSkeleton(userId)) {
      
      PVector torso = tracking(userId,SimpleOpenNI.SKEL_TORSO);
      
      float depth = depthNormalized(torso.z);
      float shift = shiftNormalized(torso.x);
      
      println("Deepth: "+ depth);
      println("Shift: " + shift);
      
      drawSkeleton(userId);
      
      //Send OSC message
      OscMessage myMessage = new OscMessage("/KinectOSC");
      myMessage.add(depth);
      myMessage.add(shift);
      oscP5.send(myMessage,myRemoteLocation);
      myMessage.print();
    }
  }
}

float depthNormalized(float depth){
  float depthNorm = (depth-1450)/1800;
  if (depthNorm >1){
    return 1;
  }else if (depthNorm <0){
    return 0;
  }
  return depthNorm;
}

float shiftNormalized(float shift){
  float shiftNorm = (shift + 1000)/1600;
  if (shiftNorm >1) {
    return 1;
  } else if (shiftNorm <0) {
    return 0;
  }
  return shiftNorm;
}

PVector tracking(int userId, int bodyPartConstant){
  PVector bodyPart = new PVector();
  kinect.getJointPositionSkeleton(userId,bodyPartConstant,bodyPart);
  PVector convertedBodyPart = new PVector();
  kinect.convertRealWorldToProjective(bodyPart, convertedBodyPart);
  ellipse(convertedBodyPart.x, convertedBodyPart.y, 10, 10);
  return bodyPart;
}

void drawSkeleton(int userId) {
  stroke(0);
  strokeWeight(5);
   
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
   
  noStroke();
   
  fill(255,0,0);
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD); 
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
}

void drawJoint(int userId, int jointID) { 
PVector joint = new PVector();
 
float confidence = kinect.getJointPositionSkeleton(userId, jointID,joint);
  if(confidence < 0.5){
    return; 
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}

//Calibration not required
void onNewUser(SimpleOpenNI kinect, int userID){
  println("Start tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId){
  println("onLostUser - userId: " + userId);
}
