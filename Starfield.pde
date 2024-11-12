int _random(float a, float b) {
  return (int)(Math.random()*(b-a)+a);
}

class Particle {
  float x;
  float y;
  color col;
  float friction;
  float size;
  float atc;
  float dx;
  float dy;
  float maxDisp;
  float cor;
  float disp;
  int r,g,b,o,newB,newR;
  float[] pastX = new float[10];
  float[] pastY = new float[10];
  Particle() {
    maxDisp=300;
    float angle = (float)(Math.random()*2*PI);
    x=(float)(Math.cos(angle)*Math.random()*maxDisp*0.9);
    y=(float)(Math.sin(angle)*Math.random()*maxDisp*0.9);
    r = _random(255,255);
    g = _random(192,255);
    b = _random(0,255);
    o = 255;
    newB = b;
    newR = _random(128,255);
    g = Math.min(g,r);
    b = Math.min(b,g);
    col=color(r,g,b,o);
    friction=(float)(0.95+Math.random()*0.05);
    //friction=1;
    size=(float)(Math.random()*10)+20;
    size*=0.8;
    atc=0.002;
    dx=(float)((Math.random()-0.5)*20);
    dy=(float)((Math.random()-0.5)*20);
    dx=0;
    dy=0;
  }
  void move() {
    x+=dx;
    y+=dy;
    dx*=friction;
    dy*=friction;
    float _dist = dist(x,y,0,0);
    if (_dist>maxDisp*0.8) {
      atc=lerp(0,0.01,_dist/maxDisp);
    } else {
      atc=0;
    }
    dx-=x*atc;
    dy-=y*atc;
    dx+=(float)((Math.random()-0.5)*1);
    dy+=(float)((Math.random()-0.5)*1);
  }
  void separate() {
    float sepx=0;
    float sepy=0;
    float sf=0.09;
    int n=0;
    for (int i=0;i<particles.length;i++) {
      Particle a = particles[i];
      float _dist = dist(a.x,a.y,x,y);
      if (_dist<50) {
        sepx+=x-a.x;
        sepy+=y-a.y;
        n++;
      }
    }
    dx+=sepx/n*sf;
    dy+=sepy/n*sf;
  }
  void cap() {
    float _dist=dist(dx,dy,0,0);
    float maxSpeed=15;
    if (maxDisp>500) {
      maxSpeed+=(maxDisp-500)/10;
    }
    if (_dist!=0&&_dist>maxSpeed) {
      dx*=maxSpeed/_dist;
      dy*=maxSpeed/_dist;
    }
  }
  void capPos() {
    float _dist = dist(x,y,0,0);
    float maxDispForRealNow=1.01;
    maxDispForRealNow = totalMaxDisp;
    if (_dist!=0&&_dist>maxDisp*maxDispForRealNow) {
      x*=maxDisp*maxDispForRealNow/_dist;
      y*=maxDisp*maxDispForRealNow/_dist;
    }
  }
  void showVerbose() {
    fill(255,128);
    ellipse(x,y,100,100);
    fill(255);
    textAlign(CENTER,CENTER);
    text((float)Math.sqrt(sq(dx)+sq(dy)),x,y-30);
  }
  void noCap() {
    float _dist=dist(dx,dy,0,0);
    float minSpeed=10;
    if (_dist<minSpeed) {
      dx*=minSpeed/_dist;
      dy*=minSpeed/_dist;
    }
  }
  void history() {
    for (int i=pastX.length-2;i>=0;i--) {
      pastX[i+1]=pastX[i];
      pastY[i+1]=pastY[i];
    }
    pastX[0]=x;
    pastY[0]=y;
    for (int i=0;i<pastX.length;i++) {
      fill(r,g,b,255);
      noStroke();
      ellipse(pastX[i],pastY[i],5,5);
    }
  }
  void show() {
    //col=color(r,g,b);
    fill(col);
    noStroke();
    circle(x,y,size);
  }
}

class oddball extends Particle {
  oddball() {
    super();
    size*=0.5;
    //r/=2;
    //g/=2;
    //b/=2;
    b=_random(128,b);
    g=_random(128,g);
    //o=64;
    col=color(r,g,b,o);
  }
  void show() {
    super.show();
    history();
  }
}

//member variables - 3
//member methods - 6
//accessor methods - 3
//local variables - 2

Particle[] particles = new Particle[700];
int mode;
float totalMaxDisp;

void setup() {
  size(1500,900);
  for (int i=0;i<particles.length;i++) {
    if (i>particles.length-20) {
      particles[i] = new oddball();
    } else {
      particles[i] = new Particle();
    }
  }
  mode=0;
}

void draw() {
  background(0);
  translate(width/2,height/2);
  fill(255,128);
  //ellipse(0,0,particles[0].maxDisp*2,particles[0].maxDisp*2);
  //ellipse(0,0,totalMaxDisp*2,totalMaxDisp*2);
  totalMaxDisp=0;
  for (int i=0;i<particles.length;i++) {
    Particle a = particles[i];
    if (mode==0) {
      a.maxDisp*=0.99;
    } else {
      a.maxDisp=width+height;
    }
    a.separate();
    a.cap();
    //a.capPos();
    a.noCap();
    a.move();
    a.newB = (int)lerp(a.b,a.g,1-a.maxDisp/(width+height));
    a.col = color(a.r,a.g,a.newB,a.o);
    if (a.maxDisp<10) {
      a.col = color(lerp(a.newR,a.r,a.maxDisp/10),lerp(a.newR,a.g,a.maxDisp/10),255,a.o);
    }
    //a.history();
    a.show();
    totalMaxDisp+=dist(a.x,a.y,0,0);
  }
  /*for (int y=-height/2;y<height/2;y++) {
    for (int x=-width/2;x<width/2;x++) {
      float best=width+height;
      for (int i=0;i<particles.length;i++) {
        float _dist = dist(particles[i].x,particles[i].y,x,y);
        if (_dist<best) {
          best = _dist;
        }
      }
      int col = (int)lerp(255,0,best/20);
      set(x+width/2,y+height/2,color(col,col,col));
    }
  }*/
  totalMaxDisp/=particles.length;
  if (mode==1) {
    mode=0;
  }
  if (particles[0].maxDisp<1) {
    mode=1;
  }
  //noLoop();
  //particles[0].showVerbose();
  fill(255);
  noStroke();
  text(round(frameRate),-width/2+50,-height/2+50);
}

void keyPressed() {
  //redraw();
}

//member variables: 4, or maybe 6
//member methods: 9
//accessor methods: 4
//local variables: 6

void mousePressed() {
  mode=1;
}
