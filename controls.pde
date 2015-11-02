
// Parameters:
boolean pSmoothSeries = true;
boolean pUseStabilizedPalmPosition = true;
boolean pSaveNextFrame = false;

int controlsW = 200;
int controlsH = 75;
int controlsTitleH = 10;

// ControlP5:
ControlP5 cp5;
//boolean showControls = false;

// *************************************************************************************************
// ControlP5 event handlers
// -------------------------------------------------------------------------------------------------

/**
 * Initialize the controls. This event handler is called by the ControlP5 library.
 */
void initControls() {
  cp5 = new ControlP5(this)
    .setColorActive(clrPrim1A)
    .setColorBackground(clrBG1)
    .setColorForeground(clrPrim4)
    .setColorCaptionLabel(clrPrim2)
    .setColorValueLabel(clrPrim3);

  ControlGroup controls = cp5.addGroup("controls")
    .setLabel("Settings")
    .setPosition(vMargin, height - controlsH - vMargin)
    .setSize(controlsW, controlsH)
    .setBackgroundColor(clrBG1)
    .setColorLabel(clrPrim3)
    .open();

  cp5.addToggle("pSmoothSeries")
    .setPosition(10, 10)
    .setSize(12, 12)
    .setLabel("Smooth series")
    .setGroup(controls)
    .getCaptionLabel().getStyle()
    .setMarginTop(-14)
    .setMarginLeft(20);

  cp5.addToggle("pUseStabilizedPalmPosition")
    .setPosition(10, 30)
    .setSize(12, 12)
    .setLabel("Use stabilized palm position")
    .setGroup(controls)
    .getCaptionLabel().getStyle()
    .setMarginTop(-14)
    .setMarginLeft(20);

  cp5.addButton("saveNextFrame")
    .setPosition(10, 50)
    .setLabel("Save Screen")
    .setSize(controlsW - 20, 15)
    .setGroup(controls);
}

/**
 * This event handler is called when the saveImage button is clicked.
 */
public void saveNextFrame(int theValue) {
  //println(">> theValue clicked: " + theValue);
  pSaveNextFrame = true;
}

//void toggleControls() {
//if (cp5.getGroup("controls").isOpen()) {
//  cp5.getGroup("controls").close();
//  showControls = false;
//} else {
//  cp5.getGroup("controls").open();
//  showControls = true;
//}
//}

void drawControls() {
  cp5.show();
  cp5.draw();
}