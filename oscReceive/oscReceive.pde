import oscP5.*;
import netP5.*;

OscP5 oscP5;
int id = -1;
color[] col=new color[7];
int colC =4;
ArrayList<Fireworks> fw =  new ArrayList<Fireworks>();
float time = 0;
int fwpc = 150;
void setup() {
  fullScreen();
  oscP5 = new OscP5(this, 9999);
  background(255);
  frameRate(30);
  noStroke();
  rectMode(CENTER);
  col[0]= #adbd37;
  col[1]= #cc4331;
  col[2]= #1f859c;
  col[3]= #bd3bc4;
  col[4]= #114331;
  col[5]= #1f2e9c;
  col[6]= #b13b14;
}


void oscEvent(OscMessage theOscMessage) {
  /* get and print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
  
   if (theOscMessage.checkAddrPattern("/pinaoKey")) {
        id = theOscMessage.get(0).intValue() ; //get first value in message
        MakeFireWork(width/8+width*id/8+random(-width/8,width/8));
   } else {
        println("Error: unexpected params type tag received by Processing");
   }
}
void draw() {

  fill(0, 25);
  rect(width/2, height/2, width, height);

  for (int i = 0; i<fw.size(); i++) {
    fw.get(i).show();
    if (fw.get(i).time < -0.5) {
      fw.remove(i);
    }
  }
}


void MakeFireWork(float x) {
  int col_rand = parseInt(random(100));
  color fillcol = col[col_rand % colC];
  float high = random(0, height/2);
  fw.add(new Fireworks(x,height, high, fillcol));
}

class particle {
  PVector position, velocity, acceleration;
  int diameter;
  particle(float x, float y, float vx, float vy) {
    this.position = new PVector(x, y);
    this.velocity = new PVector(vx, vy);
    this.acceleration = new PVector(0, 0.03);
    this.diameter = 5;
  }

  void update() {
    PVector vel=new PVector(random(this.velocity.x-0.75, this.velocity.x+0.75), this.velocity.y);
    this.velocity.add(this.acceleration);
    this.position.add(vel);

    ellipse(this.position.x, this.position.y, this.diameter, this.diameter);
  }

  void get_pos(float x, float y) {
    this.position = new PVector(x, y);
  }
}


class Fireworks {
  PVector Pos;
  ArrayList<particle> particles =  new ArrayList<particle>();
  color col;
  float high;
  float time;
  Fireworks(float px, float py, float high, color col) {
    this.Pos = new PVector(px, py);
    this.col = col;
    this.high = high;
    this.time = 1.5;
    for (int i = 0; i < fwpc; i++) {
      float ang_rad = PI * random(0, 360) / 180;
      float scale_vel = random(0.5, 2.5);
      this.particles.add(new particle(px, py, scale_vel * cos(ang_rad), scale_vel * sin(ang_rad)));
    }
  }

  void show() {
    if (this.Pos.y > this.high) {
      fill(this.col);
      this.Pos.add(new PVector(random(-0, 0), -10));
      ellipse(this.Pos.x, this.Pos.y, 7, 7);
      for (int i = 0; i < fwpc; i++) {
        this.particles.get(i).get_pos(this.Pos.x, this.Pos.y);
      }
    } else {
      this.time -= 1 / 60;
      if (this.time > 0) {
        fill(this.col);
        for (int i = 0; i < fwpc; i++) {
          this.particles.get(i).update();
        }
      }
    }
  }
}
