public class InteractiveTorus {
  InteractiveFrame iFrame;
  int c;
  int count;
  Scene scene;
  Vec m = new Vec(0,0,1);

  InteractiveTorus(Scene scn, int cnt) {
    count = cnt;
    scene = scn;  
    
    iFrame = new InteractiveFrame(scene);
    //iFrame.clearMouseGrabberPool();
    iFrame.setPickingPrecision(InteractiveFrame.PickingPrecision.ADAPTIVE);
    iFrame.setGrabsInputThreshold(scene.radius()/1000);
    setColor();
    setPosition((count*2));
  }

  // don't draw local axis
  public void draw() {
    draw(false);
  }

  public void draw(boolean drawAxes) {
    
    pushMatrix();  
    //scene.beginScreenDrawing();
    pushStyle();
    // Multiply matrix to get in the frame coordinate system.
    //applyMatrix(Scene.toPMatrix(iFrame.matrix())); // is handy but inefficient
    iFrame.applyTransformation(); // optimum
    if (drawAxes)
      scene.drawAxes(20 * 1.3f);
    //noStroke();
    strokeWeight(5);
    stroke(255);
    //fill(255, 0, 0);

    //if (iFrame.grabsInput())
    //  fill(255, 0, 0);
    //else
    //  fill(getColor());
    noFill();
    //scene.drawHollowCylinder(4,50,5,m,m);
    //box(displayWidth/25,displayHeight/25,5);
    float lngth = displayWidth/50;
    float breadth = displayHeight/50;
    rect(-lngth/2,-breadth/2,lngth,breadth);
    //ellipse(0,0, breadth, breadth);
    
    
    popStyle();
    //scene.endScreenDrawing();
    popMatrix();
    
  }
  
  public void animate(int count, int index, int thick){
    int dif = (abs(index-count));
    pushMatrix();  
    pushStyle();
    iFrame.applyTransformation(); 
    strokeWeight(5);
    stroke(map(dif,0,thick,0,255));
    noFill();
    float lngth = displayWidth/50;
    float breadth = displayHeight/50;
    rect(-lngth/2,-breadth/2,lngth,breadth);
    //int f = 1;
    //beginShape();
    //vertex(-lngth/2,-breadth/2);
    //quadraticVertex(dif*f, 0, -lngth/2, breadth/2);
    //vertex(-lngth/2, breadth/2);
    //quadraticVertex(0, breadth/2-dif*f, lngth/2, breadth/2);
    //vertex(lngth/2, breadth/2);
    //quadraticVertex(lngth/2-dif*f, 0, lngth/2, -breadth/2);
    //vertex(lngth/2, -breadth/2);
    //quadraticVertex(0, dif*f, -lngth/2,-breadth/2);
    //endShape();
    popStyle();
    popMatrix();
  }
  public void drawText(boolean light, int index, int thk) {
    strokeWeight(5);
    stroke(255);
    int diff = abs(thk+1-index);
    if(light)fill(map(diff,0,thk,255,0));
    else noFill();
    float lngth = displayWidth/50;
    float breadth = displayHeight/50;
    beginShape();
    vertex(-lngth/2,-breadth/2);
    vertex(-lngth/2+10,-breadth/2);
    vertex(0,-5*breadth/(2*(lngth/2-5)));
    vertex(lngth/2-10,-breadth/2);
    vertex(lngth/2,-breadth/2);
    vertex(5,0);
    vertex(lngth/2,breadth/2);
    vertex(lngth/2-10,breadth/2);
    vertex(0,5*breadth/(2*(lngth/2-5)));
    vertex(-lngth/2+10,breadth/2);
    vertex(-lngth/2,breadth/2);
    vertex(-5,0);
    endShape(CLOSE);
    
  }

  public int getColor() {
    return c;
  }

  // sets color randomly
  public void setColor() {
    c = color(255,255,255);
  }

  public void setColor(int myC) {
    c = myC;
  }

  public Vec getPosition() {
    return iFrame.position();
  }

  // sets position randomly
  public void setPosition(int ct) {
    Vec pos = new Vec(0,0,ct);
    //Vec pos = scene.is3D() ? new Vec(random(low, high), random(low, high), random(low, high)) 
    //                       : new Vec(random(low, high), random(low, high));
    iFrame.setPosition(pos);
  }

  public void setPosition(Vec pos) {
    iFrame.setPosition(pos);
  }

  public Rotation getOrientation() {
    return iFrame.orientation();
  }
}
