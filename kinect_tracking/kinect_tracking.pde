import SimpleOpenNI.*;
SimpleOpenNI kinect;


void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();

  // turn on user tracking
  kinect.enableUser(SimpleOpenNI.SKEL_HEAD);
  kinect.setMirror(true);
  size(640, 480);
  fill(255,0,0);
}

void draw() {
  kinect.update();
  PImage depth = kinect.depthImage();
  image(depth, 0, 0);

  // make a vector of ints to store the list of users
  IntVector userList = new IntVector();
  
  // write the list of detected users
  // into our vector
  kinect.getUsers(userList);

  // if we found any users
  if (userList.size() > 0) {
    // get the first user
    int userId = userList.get(0);
    
    // if we're successfully calibrated
    if ( kinect.isTrackingSkeleton(userId)) {
      // make a vector to store the right hand
      PVector rightHand = new PVector();
      // put the position of the right hand into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
      
      // make a vector to store the left hand
      PVector leftHand = new PVector();
      // put the position of the right hand into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
 
      float angleInRadians = PVector.angleBetween(rightHand, leftHand);
      float angleInDegrees = degrees(angleInRadians);      
      
      print("angle: "+ angleInDegrees);
   
      PVector head = new PVector();
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, head);
      
      float dist = head.z;
      
      print("distance: "+ dist);
    }
  }
}


/*
void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();

  // turn on user tracking
  kinect.enableUser(SimpleOpenNI.SKEL_HEAD);
  kinect.setMirror(true);
  size(640, 480);
  fill(255,0,0);
}

void draw() {
  kinect.update();
  PImage depth = kinect.depthImage();
  image(depth, 0, 0);

  // make a vector of ints to store the list of users
  IntVector userList = new IntVector();
  
  // write the list of detected users
  // into our vector
  kinect.getUsers(userList);

  // if we found any users
  if (userList.size() > 0) {
    // get the first user
    int userId = userList.get(0);
    
    // if we're successfully calibrated
    if ( kinect.isTrackingSkeleton(userId)) {
      // make a vector to store the right hand
      PVector rightHand = new PVector();
      // put the position of the right hand into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
      
      // make a vector to store the left hand
      PVector leftHand = new PVector();
      // put the position of the right hand into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
 
      float angleInRadians = PVector.angleBetween(rightHand, leftHand);
      float angleInDegrees = degrees(angleInRadians);
       
       // leftHand.x
       // leftHand.y
       // leftHand.z
       
       // rightHand.x
       // rightHand.y
       // rightHand.z
       
       // float xPos = (rightHand.x + leftHand.x) / 2
      
      // convert the detected hand position
      // to "projective" coordinates
      // that will match the depth image
      
      PVector convertedRightHand = new PVector();
      kinect.convertRealWorldToProjective(rightHand, convertedRightHand);
      
      // and display it      
            
      ellipse(convertedRightHand.x, convertedRightHand.y, 10, 10);       
    }
  }
}

// user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.startPoseDetection("Psi", userId);
}

void onEndCalibration(int userId, boolean successful) {
  if (successful) { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);

  } else { 
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
}*/
