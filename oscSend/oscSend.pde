import ddf.minim.*;
import oscP5.*;
import netP5.*;
Minim minim;
AudioSample[] pianoSound;
int dragX, dragY, moveX, moveY;
ArrayList<Piano> keys=new ArrayList<Piano>();
ArrayList<ClickPt> pts=new ArrayList<ClickPt>();
int numCirclePt=100;
PVector[] circlePts=new PVector[numCirclePt];
int circleLen;

OscP5 oscP5;
NetAddress dest;
void setup() {
  size(500, 500);
  minim = new Minim(this);
  circleLen=height/5;
  pianoSound=new AudioSample[7];
  for (int i=0; i<7; i++) {
    keys.add(new Piano(i*width/7, height*2/3, 1*width/7, height/3));
    pianoSound[i]=minim.loadSample(str(i+1)+".mp3");
  }
  for (int i=0; i<circlePts.length; i++) {
    circlePts[i]=new PVector(circleLen*cos(i*TWO_PI/numCirclePt), circleLen*sin(i*TWO_PI/numCirclePt));
  }
  dest = new NetAddress("127.0.0.1", 9999); //send messages to port 6448, localhost (this machine)
  oscP5 = new OscP5(this, 12000); //listen for OSC messages on port 12000 (should NOT be same port!)
}
int thisSong=0;
int thisSongTimer=0;

void draw() {
  background(70, 80, 34);
  pushMatrix();
  translate(width/2, height/3);
  fill(255, 100, 100);
  ellipse(0, 0, 100, 100);
  rotate((frameCount*0.01));
  stroke(0);
  noFill();
  beginShape();
  for (int i=0; i<circlePts.length-1; i++) {
    curveVertex(circlePts[i].x, circlePts[i].y);
  }
  curveVertex(circlePts[circlePts.length-1].x, circlePts[circlePts.length-1].y);
  curveVertex(circlePts[0].x, circlePts[0].y);
  endShape(CLOSE);
  popMatrix();
  rectMode(CORNER);
  PVector mX=new PVector(mouseX, mouseY);
  for (int i=-0; i<7; i++) {
    Piano keyTemp=keys.get(i);
    keyTemp.draw(mX.x, mX.y, i);
  }
  rectMode(CENTER);
  for (int i=0; i<6; i++) {
    fill(0);
    rect(width*(i+1)/7, height*2/3+height/8, width/14, height/4, 10);
  }
}

boolean lock=false;
void mouseReleased() {
  lock=false;
}
int clickBefore=0;
int clickCounter=0;
class ClickPt {
  int idSong;
  int timer;
  ClickPt(int id, int continueT) {
    idSong=id;
    timer=continueT;
  }
}
class Piano {
  PVector pos;
  PVector size;
  Piano(float x, float y, float w, float h) {
    pos=new PVector(x, y);
    size=new PVector(w, h);
  }
  void draw(float X, float Y, int id) {
    stroke(0);
    strokeWeight(3);
    if (X>=pos.x && X<=pos.x+size.x && Y>=pos.y && Y<=pos.y+size.y && mousePressed && lock==false) {
      fill(100, 70, 80);
      pianoSound[id].trigger();

      OscMessage msg = new OscMessage("/pinaoKey");
      msg.add(id);
      oscP5.send(msg, dest);
      lock=true;
      if (clickBefore==0) {
        clickBefore=1; 
        pts.add(new ClickPt(id, 0));
        clickCounter=millis();

        circlePts[0]=new PVector((circleLen+map(id, 0, 7, -50, 50))*cos(radians(0)), (circleLen+map(id, 0, 7, -50, 50))*sin(radians(0)));
      } else {
        pts.add(new ClickPt(id, millis()-clickCounter));
        clickCounter=millis();
        int num=numCirclePt/pts.size();
        for (int i=0; i<circlePts.length; i++) {
          if (i%num==0 && i/num<=pts.size()-1) {
            circlePts[i]=new PVector((circleLen+map(pts.get(i/num).idSong, 0, 7, -50, 50))*cos((i*TWO_PI/numCirclePt)), (circleLen+map(pts.get(i/num).idSong, 0, 7, -50, 50))*sin((i*TWO_PI/numCirclePt)));
            continue;
          }
          circlePts[i]=new PVector(circleLen*cos((i*TWO_PI/numCirclePt)), circleLen*sin((i*TWO_PI/numCirclePt)));
        }
      }
    } else {
      fill(255);
    }
    rect(pos.x, pos.y, size.x, size.y, 30);
  }
}
