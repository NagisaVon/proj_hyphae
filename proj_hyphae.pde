

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
    stroke(color(hue(col), maxLvl-l*4, maxLvl*2/3));
    strokeWeight(w);
    if ( parent != null ) {
      line(parent.x, parent.y, x, y);
      // a liner color
      colorMode(RGB);
      stroke(255);
      strokeWeight(w/2);
      line(parent.x, parent.y, x, y);
    }else {
      point(x, y); // for the rt node who doesn't have a parent
    }
  }
  
  void generate() {
    // return when the recursion level is too deep 
    // or when the cursor is out of the canvas
    if ( l >= maxLvl || x > width || x < 0 || y > height || y < 0 || w <= minWidth ) {
      return;
    }
    // basiclly roll a dice and see if a new branch should be generate
    if ( random(1) <= ((w>thresPLS)?pBranchL:pBranchS) ){  
      // wins, new branch
      float brD, cD; // new direction for branch and child
      float brDelta = bSplit * (random(1)>0.5?1:-1); 
      brD = d + brDelta + random( -wi, wi );
      cD = d - brDelta + random( -wi, wi );
      branch = new node(brD, w*(w>thresWidLS?bWRedL:bWRedS), x+cos(brD)*w*dist, y+sin(brD)*w*dist, wi, l+1, rColor(), this);
      child = new node(cD, w*(w>thresWidLS?bWRedL:bWRedS), x+cos(cD)*w*dist, y+sin(cD)*w*dist, wi, l+1, col, this);
     if(branch.hasCollision()) {
        branch = null;
      }
      if(child.hasCollision()) {
        child = null;
      }
    }else {
      float cD = d + random( -wi, wi );
      child = new node(cD, w, x+cos(cD)*w*dist, y+sin(cD)*w*dist, wi, l+1, col, this);
      if(child.hasCollision()) {
        child = null;
      }
    } 
  }
  
  boolean hasCollision() {
    int i = int(x+cos(d)*w*dist), j = int(y+sin(d)*w*dist);
    if ( i < 0 || i >= width || j < 0 || j >= height ) 
      return true;
    color pix = get().pixels[j*width+i]; // faster than get
    if(  pix != bgColor ) // could compare color directly 
      return true;
    return false;
  }
  
}

color rColor() {
  colorMode(RGB);
  return color(random(255), random(255), random(255));
  //return color(random(150, 200), random(30, 150), random(50, 100));  // orange-ish
}

int maxLvl = 500;
float minWidth = 1;
float thresPLS = 9; // threshold of Large and Small node for probability 
float pBranchL = 0.3; // probability of branching
float pBranchS = 0.15; // probability of branching 
float dist = 0.5; // distance between two node, mutiple by w
float thresWidLS = 10; // threshold of Large and Small node for width 
float bWRedL = 0.6; // width reduce when branching, by percentage, and width is large
float bWRedS = 0.9; // width reduce when branching, by percentage, and width is small
float bSplit =  PI/3; // new branch angle
float wiggle = 0.3; 
float startWidth = 13;
color bgColor = color(255);

// how to show along generation ?

int sHead;
int sTail;
node[] hyphae = new node[1000000];

void setup () {
  size(1000, 1000);
  colorMode(RGB);
  background(bgColor);
  frameRate(300);

  // walls 
  noStroke();
  fill(200);
  rect(0,0,1000,1000);

  // center area
  fill(bgColor);
  circle(width/2, height/2, 600);
  //rectMode(CENTER);
  //rect( width/2, height/2, 600,900);
  
  // system stack will only draw after all stack returns 
  // here I am implementing a custom stack
  
  // generate the root 
  hyphae[0] = new node(0, startWidth, width/2-50, height/2-50, wiggle, 0, rColor(), null);
  hyphae[1] = new node(PI, startWidth, width/2+50, height/2+50, wiggle, 0, rColor(), null);
  //hyphae[sHead] = new node(random(2*PI), startWidth, width/2, height/2, wiggle, 0, rColor(), null);

  sHead = 0;
  sTail = 1;
}

void draw() {
  
  // generate new nodes
  // if last cicle generated branch 
  node curNode = hyphae[sHead];
  
  curNode.generate();
  curNode.show();
  // has a child 
  if (curNode.child != null) {
    hyphae[++sTail] = curNode.child;
  }
  if (curNode.branch != null) {
    hyphae[++sTail] = curNode.branch;
  }
  sHead ++;
  if(sHead > sTail) {
    // end of drawing
    noLoop();
    takeScreenShot();
  }
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
