

class node {
  float d; // direction by radian 
  float w; // width 
  float x, y;
  float wi; // wiggle, +- radian
  int l; // level
  node child; // child
  node branch; // branch
  node parent;
  color col; 
  
  node(float td, float tw, float tx, float ty, float twi, int tl, color tc, node tparent) {
    d = td;
    w = tw; 
    x = tx;
    y = ty;
    wi = twi;
    l = tl;
    col = tc;
    parent = tparent;
  }
  
  void show() {
    colorMode(HSB, maxLvl);
    stroke(color(hue(col), maxLvl-l*2, maxLvl*2/3));
    strokeWeight(w);
    if ( parent != null ) {
      line(parent.x, parent.y, x, y);
    }else {
      point(x, y); // for the rt node who doesn't have a parent
    }
  }
  
  void generate() {
    if ( l >= maxLvl || x > width || x < 0 || y > height || y < 0 || w <= minWidth ) {
      return;
    }
    if ( random(1) <= ((w>thresPLS)?pBranchL:pBranchS) ){  
      // wins, new branch
      float brD, cD; // new direction for branch and child
      float brDelta = bSplit * (random(1)>0.5?1:-1);
      brD = d + brDelta + random( -wi, wi );
      cD = d - brDelta + random( -wi, wi );
      branch = new node(brD, w*(w>thresWidLS?bWRedL:bWRedS), x+cos(brD)*w*dist, y+sin(brD)*w*dist, wi, l+1, rColor(), this);
      child = new node(cD, w*(w>thresWidLS?bWRedL:bWRedS), x+cos(cD)*w*dist, y+sin(cD)*w*dist, wi, l+1, col, this);
      if(branch.notCollision()) {
        branch.show();
        branch.generate();
      }
      if(child.notCollision()) {
        child.show();
        child.generate();
      }
    }else {
      float cD = d + random( -wi, wi );
      child = new node(cD, w, x+cos(cD)*w*dist, y+sin(cD)*w*dist, wi, l+1, col, this);
      if(child.notCollision()) {
        child.show();
        child.generate();
      }
    } 
  }
  
  Boolean notCollision() {
    int i = int(x+cos(d)*w*dist), j = int(y+sin(d)*w*dist);
    if ( i < 0 || i >= width || j < 0 || j >= height ) 
      return false;
    color pix = get().pixels[j*width+i]; // faster than get
    if(  pix != bgColor ) // could compare color directly 
      return false;
    return true;
  }
  
}

color rColor() {
  colorMode(RGB);
  return color(random(255), random(255), random(255));
  //return color(random(150, 200), random(30, 150), random(50, 100));  // orange-ish
}

int maxLvl = 500;
float minWidth = 1;
float thresPLS = 10; 
float pBranchL = 0.3; // probability of branching
float pBranchS = 0.15; // probability of branching 
float dist = 0.7; // distance between two node, mutiple by w
float thresWidLS = 10; 
float bWRedL = 0.6; // width reduce when branching, by percentage, and width is large
float bWRedS = 0.95; // width reduce when branching, by percentage, and width is small
float bSplit =  PI/6; // new branch angle
float wiggle = 0.5; 
float startWidth = 13;
color bgColor = color(255);

// how to show along generation ?


void setup () {
  size(1000, 1000);
  colorMode(RGB);
  background(bgColor);
  noLoop();
  
  // walls 
  noStroke();
  fill(200);
  rect(0,0,1000,1000);
  fill(255);
  rectMode(CENTER);
  rect( width/2, height/2, 600,900);
  
}

void draw() {
  node rt = new node(random(2*PI), startWidth, width/2, height/2, wiggle, 0, rColor(), null);
  rt.show();
  rt.generate(); 
  takeScreenShot();
}

void mousePressed(){
  println("redrawing...");
  redraw();
}

void takeScreenShot() {
  String time = year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second();
  String s =  "saved-" + time + ".png";
  saveFrame(s);
  println("Saved as: " + s);
}
