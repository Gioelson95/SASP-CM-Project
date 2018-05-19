import SimpleOpenNI.*;
import themidibus.*; 

SimpleOpenNI kinect;

MidiBus myBus;

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  size(640, 480);
  fill(255, 0, 0);
  kinect.setMirror(true);

  /* start MIDI */
  MidiBus.list();
  myBus = new MidiBus(this, -1, "H9 Pedal");
}

void draw() {

  kinect.update();
  image(kinect.userImage(), 0, 0);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  if (userList.size() > 0) {
    int userId = userList.get(0);
    //If we detect one user we have to draw it
    if ( kinect.isTrackingSkeleton(userId)) {

      PVector torso = tracking(userId, SimpleOpenNI.SKEL_TORSO);

      float depth = depthNormalized(torso.z);
      float shift = shiftNormalized(torso.x);

      println("Depth: "+ depth);
      println("Shift: " + shift);

      drawSkeleton(userId);

      //Send MIDI message

      myBus.sendControllerChange(1, 1, int(depth*127));
      myBus.sendControllerChange(1, 2, int(shift*127));
    }
  }
}

float depthNormalized(float depth) {
  float depthNorm = (depth-1450)/1000;
  if (depthNorm >1) {
    return 1;
  } else if (depthNorm <0) {
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

/*float angle(PVector rightHand, PVector leftHand) {
  float angle = (rightHand.y - leftHand.y)/(rightHand.x - leftHand.x);
  angle = (angle - 0.4)/2.2;
  if (angle >1) {
    return 1;
  } else if (angle <0) {
    return 0;
  }
  return angle;
}

float heightNormalized(PVector head, PVector knee){
  float high = (head.y - knee.y);
  high = (high - 800)/200;
  if (high >1) {
    return 1;
  } else if (high <0) {
    return 0;
  }
  return high;
}

float headNormalized(PVector head){
  float high = (head.x);
  high = (high - 800)/200;
  if (high >1) {
    return 1;
  } else if (high <0) {
    return 0;
  }
  return high;
}*/

PVector tracking(int userId, int bodyPartConstant) {
  PVector bodyPart = new PVector();
  kinect.getJointPositionSkeleton(userId, bodyPartConstant, bodyPart);
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

  fill(255, 0, 0);
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

  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if (confidence < 0.5) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}

//Calibration not required
void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
}
