import java.util.LinkedList;

// *************************************************************************************************
// TimeSeries Class
// -------------------------------------------------------------------------------------------------

class TimeSeries {

  public String label;
  public String labelUC;
  public int size = 0;
  public int maxSize = 0;
  public float min;
  public float max;
  public float maxDelta;
  public float baseValue;
  private boolean hasCyclicValue = false;
  private float cyclicValue = 0;
  public float[] ticks;
  public String[] tickLabels;
  public color primColor = clrPrim1A;
  private LinkedList<Float> data = new LinkedList<Float>();
  private LinkedList<Boolean> pure = new LinkedList<Boolean>();

  /**
   * Constructor.
   * @param label    A string that can be used as label.
   * @param maxSize  The (maximum) numer of values in the series.
   * @param min      The lower bound of the typical value range.
   * @param max      The upper bound of the typical value range.
   * @param base     The typical value that will be used when an empty value is added.
   * @param maxDelta The largest delta with which the value may increase or decrease.
   */
  TimeSeries(String label, int maxSize, float min, float max, float baseValue, float maxDelta) {
    this.label = label;
    this.labelUC = label.toUpperCase();
    this.maxSize = maxSize;
    this.min = min;
    this.max = max;
    this.baseValue = baseValue;
    this.maxDelta = maxDelta;
  }

  /**
   * Call this method for series with cyclic values. The range bound by
   * the min and max arguments given to the constructor will be taken
   * as the cyclic range. Values outside of this range will be cycled to
   * fit.
   */
  public void hasCyclicValue() {
    hasCyclicValue = true;
    cyclicValue = max - min;
  }

  /**
   * Specifies the values for which (horizontal) ticks should be drawn in the graph.
   * @param ticks      Array with numerical values.
   */
  public void setTicks(float[] ticks) {
    this.ticks = ticks;
  }

  /**
   * Specifies the values for which (horizontal) ticks should be drawn in the graph.
   * @param ticks      Array with numerical values.
   * @param tickLabels Optional array with string labels. This array must have the same size
   *                   as the ticks array. When null is given then the values in the ticks
   *                   are taken as the labels.
   */
  public void setTicks(float[] ticks, String[] tickLabels) {
    this.ticks = ticks;
    this.tickLabels = tickLabels;
  }
  
  /**
   * Set the primary color for this series.
   */
  public void setColor(color primColor) {
    this.primColor = primColor;
  }

  /**
   * Add a new value in the series. Trim the series when needed.
   */
  public void add(float value) {
    add(value, true);
  }

  /**
   * Add a new value in the series. Trim the series when needed.
   * @param value  The new value to add.
   * @param isPure True when this value is an unmodified observed value.
   */
  public synchronized void add(float value, boolean isPure) {
    // Keep cyclic values within min-max range:
    if (hasCyclicValue) {
      while (value > max) value -= cyclicValue;
      while (value < min) value += cyclicValue;
    }

    // Stabilize the value when the pSmoothSeries parameter is true and
    // this is not the first value:
    if (pSmoothSeries && size > 0) {
      float prev = data.getFirst();  // the previous value

      // Add as given when the value equals the previous value:
      if (value != prev) {
        float delta = value - prev;

        // Check delta in other direction, it might be smaller:
        if (hasCyclicValue) {
          if (value > prev) {
            float delta2 = value - cyclicValue - prev;
            if (Math.abs(delta2) < Math.abs(delta)) delta = delta2;
          } else {
            float delta2 = value + cyclicValue - prev;
            if (Math.abs(delta2) < Math.abs(delta)) delta = delta2;
          }
        }
        
        // Keep delta within bounds:
        if (delta > maxDelta) {
          value = prev + maxDelta;
          if (hasCyclicValue && value > max) value -= cyclicValue;
          isPure = false;
        } else if (delta < -maxDelta) {
          value = prev - maxDelta;
          if (hasCyclicValue && value < min) value += cyclicValue;
          isPure = false;
        }
      }
    }

    // Add the value and the pure-classification:
    data.addFirst(value);
    pure.addFirst(isPure);

    // trim the queues:
    if (data.size() > maxSize) {
      data.removeLast();
      pure.removeLast();
    }
    size = data.size();
  }

  /**
   * Add a base value when no value is available to add.
   */
  public void addBaseValue() {
    add(baseValue, false);
  }

  /**
   * Returns the value at index i.
   * @param i The index of the value to return.
   */
  public synchronized float get(int i) {
    if (i >= size) {
      throw new Error("The given index (" + i + ") is too large. The size is "
        + data.size() + ".");
    }
    return data.get(i);
  }

  /**
   * Returns true when the value at index i is the original value.
   * @param i The index of the value for which to return the pure classification.
   */
  public synchronized Boolean pure(int i) {
    if (i >= size) {
      throw new Error("The given index (" + i + ") is too large. The size is "
        + data.size() + ".");
    }
    return pure.get(i);
  }
}

// *************************************************************************************************
// HandData Class
// -------------------------------------------------------------------------------------------------

class HandData {
  //public float palmRoll = 0;
  //public float extFingerCnt = 0;
  public TimeSeries palmX;
  public TimeSeries palmY;
  public TimeSeries palmZ;
  public TimeSeries palmPitch; // x-axis
  public TimeSeries palmYaw;   // y-axis
  public TimeSeries palmRoll;  // z-axis
  public TimeSeries grabStrength;
  public TimeSeries pinchStrength;
  public TimeSeries extFingerCount; // extended finger count
  private ArrayList<TimeSeries> timeSeriess = new ArrayList<TimeSeries>();

  /**
   * Constructor
   * @param size The size of the time series.
   */
  public HandData(int size) {
    float[] t1 = { -300, -150, 0, 150, 300 };
    palmX = new TimeSeries("Palm X", size, -300, 300, 0, 5);
    palmX.setTicks(t1);
    timeSeriess.add(palmX);

    float[] t2 = { 0, 250, 500, 750 };
    palmY = new TimeSeries("Palm Y", size, 0, 750, 0, 5);
    palmY.setTicks(t2);
    timeSeriess.add(palmY);

    palmZ = new TimeSeries("Palm Z", size, -300, 300, 0, 5);
    palmZ.setTicks(t1);
    timeSeriess.add(palmZ);

    float[] angleTicks = { -PI, -HALF_PI, 0, HALF_PI, PI };
    String[] angleLabels = { "-π", "", "0", "", "π" };

    palmPitch = new TimeSeries("Palm pitch", size, -PI, PI, -HALF_PI, .05);
    palmPitch.hasCyclicValue();
    palmPitch.setTicks(angleTicks, angleLabels);
    palmPitch.setColor(clrPrim1B);
    timeSeriess.add(palmPitch);

    palmYaw = new TimeSeries("Palm yaw", size, -PI, PI, 0, .05);
    palmYaw.hasCyclicValue();
    palmYaw.setTicks(angleTicks, angleLabels);
    palmYaw.setColor(clrPrim1B);
    timeSeriess.add(palmYaw);

    palmRoll = new TimeSeries("Palm roll", size, -PI, PI, 0, .05);
    palmRoll.hasCyclicValue();
    palmRoll.setTicks(angleTicks, angleLabels);
    palmRoll.setColor(clrPrim1B);
    timeSeriess.add(palmRoll);
    
    float[] t7 = { 0, .5, 1 };
    String[] l7 = { "0", "0.5", "1" };
    
    grabStrength = new TimeSeries("Grab strength", size, 0, 1, 0, .25);
    grabStrength.setTicks(t7, l7);
    grabStrength.setColor(clrPrim1C);
    timeSeriess.add(grabStrength);
    
    pinchStrength = new TimeSeries("Pinch strength", size, 0, 1, 0, .25);
    pinchStrength.setTicks(t7, l7);
    pinchStrength.setColor(clrPrim1C);
    timeSeriess.add(pinchStrength);
    
    float[] t9 = { 0, 1, 2, 3, 4, 5 };
    extFingerCount = new TimeSeries("Extended finger count", size, 0, 5, 0, 5);
    extFingerCount.setTicks(t9);
    extFingerCount.setColor(255);
    timeSeriess.add(extFingerCount);
  }
  
  /**
   * Update this hand data object with the new data in the given hand
   * object from the Leap Motion library.
   * @param hand The Leap Motion hand. This may be null when this hand is not available.
   *             In that case base value are added in the series.
   */
  public void update(Hand hand) {
    if (hand == null) {
      for (TimeSeries timeSeries : timeSeriess) {
        timeSeries.addBaseValue();
      }
    } else {
      Vector pn = hand.palmNormal();
      palmPitch.add(pn.pitch());
      palmYaw.add(pn.yaw());
      palmRoll.add(pn.roll());

      Vector pp = pUseStabilizedPalmPosition ? hand.stabilizedPalmPosition() : hand.palmPosition();
      palmX.add(pp.getX());
      palmY.add(pp.getY());
      palmZ.add(pp.getZ());
      
      grabStrength.add(hand.grabStrength());
      pinchStrength.add(hand.pinchStrength());
      extFingerCount.add(hand.fingers().extended().count());
    }
  }
}