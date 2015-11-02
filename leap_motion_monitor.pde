// The LeapMotion library must be installed. To install this library, select
// Sketch in the Processing menu, then Import Library... and Add Library... .
// Now select The LeapMotion library and click on the Install button.
// This library is documented at https://github.com/heuermh/leap-motion-processing
// This library provides a simple integration of the Leap Motion Java API in
// Processing. You will need to use this API to process Leap Motion sensor data.
// This API is documented at https://developer.leapmotion.com/documentation/java/api/Leap_Classes.html
import com.leapmotion.leap.Controller;
import com.leapmotion.leap.Frame;
import com.leapmotion.leap.Gesture;
import com.leapmotion.leap.Hand;
import com.leapmotion.leap.Vector;
import com.leapmotion.leap.processing.LeapMotion;

// The ControlP5 library must also be installed.
// To install this library, select Sketch in the Processing menu. Select Import
// Library... and Add Library... . Now select The ControlP5 library and click
// on the Install button.
// This library is documented at http://www.sojamo.de/libraries/controlP5/reference/
import controlP5.*;

// The LeapMotion object represents the Leap Motion device.
LeapMotion leapMotion;

// *************************************************************************************************
// Processing event handlers
// -------------------------------------------------------------------------------------------------

void setup() {
  fullScreen(2);
  background(0);
  frameRate(15);

  leapMotion = new LeapMotion(this);  // initialize the LeapMotion object:
  initView();                         // initialize the view
  initControls();                     // initialize the GUI controls
}

void draw() {
  updateView();    // draw the graphs
  drawControls();  // draw the GUI controls
  
  // Save the frame when requested:
  if (pSaveNextFrame) {
    saveImage();
    pSaveNextFrame = false;
  }
}

void keyReleased() {
  if (key == 'm' || key == 'M') {
    //toggleControls();
  } else if (key == 's' || key == 'S') {
    pSaveNextFrame = true;
  }
}

// *************************************************************************************************
// Support
// -------------------------------------------------------------------------------------------------

/**
 * Save the current frame as a png image.
 */
public void saveImage() {
  File imagesDir = new File(dataPath("../images"));
  int number = 1;
  if (imagesDir.exists()) {
    number = imagesDir.listFiles().length + 1;
  }
  save("images/screen_" + number + ".png");
}