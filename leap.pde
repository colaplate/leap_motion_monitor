
// True when the Leap Motion is ready.
boolean lmReady = false;

// The size of the time series in the hand data objects.
int seriesSize = 200;

// The hand data objects.
HandData handDataL;
HandData handDataR;

// The total number of extended fingers.
float extFingerCnt = 0;

// *************************************************************************************************
// LeapMotion Event handling
// -------------------------------------------------------------------------------------------------

/**
 * This event handler function is called by the Leap Motion library when the Leap Motion
 * is ready.
 * See https://developer.leapmotion.com/documentation/java/api/Leap.Listener.html for more details.
 */
void onInit(final Controller controller) {
  println("Connecting with the Leap Motion");

  // enable background policy
  controller.setPolicyFlags(Controller.PolicyFlag.POLICY_BACKGROUND_FRAMES);

  handDataL = new HandData(seriesSize);
  handDataR = new HandData(seriesSize);
  lmReady = true;
}

/**
 * This event handler function is called by the Leap Motion library when a new frame of hand an
 * finger tracking data is available.
 * See https://developer.leapmotion.com/documentation/java/api/Leap.Listener.html for more details.
 */
void onFrame(final Controller controller) {
  Frame frame = controller.frame();

  // Update the extended fingers count:
  extFingerCnt = frame.fingers().extended().count();
  
  // Add available data in the hand data objects:
  Hand handL = null;
  Hand handR = null;
  for (int i = 0; i < frame.hands().count(); i++) {
    Hand hand = frame.hands().get(i);
    if (hand.isLeft()) handL = hand;
    else handR = hand;
  }
  handDataL.update(handL);
  handDataR.update(handR);

  // - pitch (x) - range: -1.5 (fingers down) to 1.4 (fingers up)
  // - yaw   (y) - range: -1.1 (fingers to the left) to 1.1 (fingers to the right)
  // - roll  (x) - range: -1.1 (counterclockwise) to 1.1 (clockwise)
  // - palmPosition.x - range: 
  // - palmPosition.y - range: 50 (low) to 400 (high)
  // - palmPosition.z - range: -150 (close) to 150 (far)
  // - grabStrength is not very reliable
}