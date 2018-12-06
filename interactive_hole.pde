import remixlab.proscene.*; //<>//
import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;
import SimpleOpenNI.*;
import processing.sound.*;

SimpleOpenNI context;

Scene scene;
InteractiveTorus [] toruses, toruses1;
InteractiveTorus itxt;

String renderer = P3D;

int dist = 0;
Vec v,position;

PVector comLast = new PVector();
Vec vLast = new Vec();

int flag = 0, flagS = 0;
int ind,spd;

IntList indexes;
IntList t;

AudioIn input;
Amplitude loudness;
float vol;
	
void setup() {
  ///size(displayWidth, displayHeight, renderer);
  
  fullScreen(renderer);
  //size(800,600,renderer);
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  context.setMirror(true);
  context.enableDepth();
  context.enableUser();
  
  input = new AudioIn(this, 0);
  input.start();
  input.amp(1.0);
  loudness = new Amplitude(this);
  loudness.input(input);
  
  scene = new Scene(this);
  scene.setRadius(100);
  scene.showAll();
  
  //println(scene.camera().fieldOfView());
  scene.camera().setFieldOfView(1.5);
  //scene.eyeFrame().removeBindings();
  scene.motionAgent().disableTracking();
  scene.setAxesVisualHint(false); 
  scene.setGridVisualHint(false);
  
  toruses = new InteractiveTorus[500];
  //toruses1 = new InteractiveTorus[500];
  for (int i = 0; i < toruses.length; i++){
    toruses[i] = new InteractiveTorus(scene,i);
    //toruses1[i] = new InteractiveTorus(scene,-i);
  }
  
  itxt = new InteractiveTorus(scene,0);
  v = new Vec(0,0,-1);
  position = new Vec(0,0,100);
  scene.camera().setPosition(position);
  scene.camera().setViewDirection(v);
  scene.camera().setRotationSensitivity(0.0);
  smooth(8);
  
  indexes = new IntList();
  t = new IntList();
}

void draw() {
  context.update();
  background(0);
  // A. 3D drawing
  int[]   depthMap = context.depthMap();
  int[] userList= context.getUsers();
  PVector com = new PVector();
  //println(context.getNumberOfUsers());
  
  vol = loudness.analyze();
  itxt.drawText(false,0,0);
  
  for(int i=0;i<userList.length;i++){
    if(context.getCoM(userList[0],com)&&com.z<2500)
    {
      com = PVector.lerp(comLast,com,0.1);
      PVector x1 = new PVector(-displayWidth/2, com.y, 0);
      PVector y1 = new PVector(-displayHeight/2, com.x, 0);
      PVector x2 = new PVector(displayWidth/2, com.y, 0);
      PVector y2 = new PVector(displayHeight/2, com.x, 0);
      PVector v1x = PVector.sub(x1,com);
      PVector v2x = PVector.sub(x2,com);
      PVector v1y = PVector.sub(y1,com);
      PVector v2y = PVector.sub(y2,com);
      float angX = acos(v1x.normalize().dot(v2x.normalize()));
      float angY = acos(v1y.normalize().dot(v2y.normalize()));
      scene.camera().setHorizontalFieldOfView(angX);
      scene.camera().setFieldOfView(angY);
      Rect rect = new Rect(0,0,displayWidth,displayHeight);
      scene.camera().fitScreenRegion(rect);;
 
      PVector com2d = new PVector();
      context.convertRealWorldToProjective(com,com2d);

      position.setX(map(com2d.x,0,640,-displayWidth/105,displayWidth/105));
      position.setY(map(com2d.y,0,480,-displayHeight/105,displayHeight/105));
      position.setZ(map(com.z,500,3000,0,300)+10);
      
    
      scene.camera().setPosition(position);
      v.setX(com.x);
      v.setY(-com.y);
      v.setZ(com.z); 
      v.add(position);
      v.multiply(-1);
      v.lerp(vLast,0.3);
      v.normalize();
      scene.camera().setViewDirection(v);
    }      
    
  }
  
  
  

  for (int i = 0; i < toruses.length; i++){
    toruses[i].draw();
    //toruses1[i].draw();
    if(flag==1){
      for(int j=0; j<indexes.size(); j++){
        if(i<indexes.get(j)+t.get(j) && i>indexes.get(j)-t.get(j)-1) toruses[i].animate(i,indexes.get(j),t.get(j));
      }
      //if(i<ind+10 && i>ind-11) toruses[i].animate(i,ind);
      //else toruses[i].draw();
      if(indexes.get(indexes.size()-1) == 0){
        flag = 0;
        indexes.clear();
      }
      
    }
  }
  if(vol>0.1 && flagS == 0){
    flagS = 1;
    mapSound(vol);
  }
  if(vol<0.1 && flagS == 1)flagS = 0;
  
  if(flag == 1 && frameCount%1 == 0 && indexes.size()>0){
      for(int j=0; j<indexes.size(); j++){
        indexes.set(j,indexes.get(j)-1);
        if(indexes.get(j)<=2*t.get(j)+1) itxt.drawText(true,indexes.get(j),t.get(j));
      }
      //if(ind%5 == 0 && spd>1)spd--;
      //println(ind);
   }
  
  
  // C. Render text instructions.
  //scene.beginScreenDrawing();
  //if(onScreen)
  //  text("Press 'x' to handle 3d scene", 5, 17);
  //else
  //  text("Press 'x' to begin screen drawing", 5, 17);
  //if(additionalInstructions)
  //  text("Press 'y' to clear screen", 5, 35);
  //scene.endScreenDrawing();
  
  comLast = com;
  vLast = v;
}

void keyPressed() {
  if ((key == 'x') || (key == 'X')) {
    if(scene.isMotionAgentEnabled())
      scene.disableMotionAgent();
    else
      scene.enableMotionAgent();
    
  }
  
}

void onNewUser(SimpleOpenNI curContext,int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  context.startTrackingSkeleton(userId);
  if(userId > 1)context.init();
}

void onLostUser(SimpleOpenNI curContext,int userId)
{
  println("onLostUser - userId: " + userId);
  position.setX(0);
  position.setY(0);
  position.setZ(100);
  scene.camera().setPosition(position);
  v.setX(0);
  v.setY(0);
  v.setZ(-1);
  scene.camera().setViewDirection(v);
  context.init();
}



void mapSound(float volume){
  flag = 1;
  indexes.append(100);
  println(int(map(volume,0.1,0.5,10,30)));
  t.append(int(map(volume,0.1,0.5,10,30)));
}
