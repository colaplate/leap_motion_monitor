
// Layout:
int vMarginTop = 40;
int vMargin = 25;
int vGapH = 30;
int vGapV = 10;

// Columns:
int vCol1 = 0;
int vCol2 = 0;
int vColW = 0;

// Rows:
int vRowCnt = 9;
int vRowH1 = 100;
int[] vRowYs = new int[vRowCnt];

// Graph settings:
int topBarH = 12;

// Colors:
color clrPrim1A = color(255, 204, 0);
color clrPrim1B = color(0, 0, 190);
color clrPrim1C = color(0, 190, 0);

color clrPrim2 = color(200);
color clrPrim3 = color(150);
color clrPrim4 = color(100);
color clrBG1 = color(255, 30);


color clrGraphBg = clrBG1;
color clrGraphTicks = color(60);
color clrGraphMarks = clrPrim1A;
color clrGraphText = clrPrim2;

PFont openSansRegular;

/**
 * Initialize the view. Called from the setup function.
 */
void initView() {
  vCol1 = vMargin;
  vColW = (width - vMargin - vMargin - vGapH) / 2;
  vCol2 = vMargin + vColW + vMargin;
  
  vRowH1 = (height - vMarginTop - vMargin - controlsH - controlsTitleH) / 9 - vGapV;
  
  vRowYs[0] = vMarginTop;
  for (int i = 1; i < vRowCnt; i++) {
    vRowYs[i] = vRowYs[i - 1] + vRowH1 + vGapV;
  }

  openSansRegular = createFont("openSans/OpenSans-Regular.ttf", 32);
}

/**
 * This function is called once for each frame:
 */
void updateView() {
  background(0);

  // Hide cursor when the mouse is not moving:
  if (mouseX != pmouseX || mouseY != pmouseY) cursor(ARROW);
  else noCursor();

  // Draw left-hand/right-hand labels:
  fill(clrGraphText);
  textFont(openSansRegular, 14);
  text("LEFT HAND", vMargin + 3, vMargin);
  text("RIGHT HAND", vCol2 + 3, vMargin);
  
  // Draw the time series graphs:
  if (lmReady) {
    drawTimeSeriess(handDataL, vCol1);
    drawTimeSeriess(handDataR, vCol2);
  }
}

void drawTimeSeriess(HandData handData, int colX) {
    drawTimeSeries(handData.palmX, colX, vRowYs[0], vColW, vRowH1);
    drawTimeSeries(handData.palmY, colX, vRowYs[1], vColW, vRowH1);
    drawTimeSeries(handData.palmZ, colX, vRowYs[2], vColW, vRowH1);
    drawTimeSeries(handData.palmPitch, colX, vRowYs[3], vColW, vRowH1);
    drawTimeSeries(handData.palmYaw, colX, vRowYs[4], vColW, vRowH1);
    drawTimeSeries(handData.palmRoll, colX, vRowYs[5], vColW, vRowH1);
    drawTimeSeries(handData.grabStrength, colX, vRowYs[6], vColW, vRowH1);
    drawTimeSeries(handData.pinchStrength, colX, vRowYs[7], vColW, vRowH1);
    drawTimeSeries(handData.extFingerCount, colX, vRowYs[8], vColW, vRowH1);
}

/**
 * Draw a single time series graph.
 * @param ts The time series to visualise
 * @param gx The graph's top-left x-pos
 * @param gy The graph's top-left y-pos
 * @param gw The width of the graph
 * @param gw The height of the graph
 */
void drawTimeSeries(TimeSeries ts, int gx, int gy, int gw, int gh) {
  pushMatrix();
  translate(gx, gy);

  // draw background:
  fill(clrGraphBg);
  noStroke();
  rect(0, topBarH, gw, gh - topBarH);

  // draw ticks:
  stroke(clrGraphTicks);
  strokeWeight(1);
  fill(clrGraphText);
  textFont(openSansRegular, 11);
  for (int i = 0; i < ts.ticks.length; i++) {
    float y = map(ts.ticks[i], ts.min, ts.max, gh, topBarH);
    line(0, y, gw, y);
    if (ts.tickLabels != null) {
      text(ts.tickLabels[i], 3, y - 2);
    } else {
      text(floor(ts.ticks[i]), 3, y - 2);
    }
  }

  // draw graph title:
  fill(clrGraphText);
  textFont(openSansRegular, 11);
  text(ts.labelUC, 50, topBarH - 2);

  // draw values:
  strokeWeight(2.5);
  for (int i = 0; i < ts.size; i++) {
    if (ts.pure(i)) stroke(ts.primColor);
    else stroke(190, 0, 0);
    float x = map(i, 0, ts.maxSize - 1, 0, gw);
    float y = map(ts.get(i), ts.min, ts.max, gh, topBarH);
    point(x, y);
  }

  popMatrix();
}