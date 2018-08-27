int N = 200;
int setFrameRate = 60;
float G = 0.001;
float c = 0.15;
float dRad = 5;
float dDensity = 1;
float collisionDamping = 0.9;
float rotAngleX, rotAngleY = 0;
float totMass = 0;
PVector zero = new PVector(0, 0, 0);

float x, y, z, vx, vy, vz, k;
float posDiffSq;
int size;
Planet pi, pj;
ArrayList<Planet> p = new ArrayList<Planet>();
PVector posDiff;


void setup()
{  
  size(950, 1000, P3D);
  frameRate(setFrameRate);
  
  p.add(new Planet(width/2, height/2, 0,  0, 0, 0, 10 * dRad, dDensity * 5));
  
  p.add(new Planet(width/2 + 100, height/2, 0,  0, 0, 0, 1 * dRad, dDensity));
  p.add(new Planet(width/2 + 110, height/2, 0,  0, 0, 0, 3 * dRad, dDensity));
  //p.add(new Planet(width/2, height/2, 0,  0, 0, 0, 10 * dRad, dDensity * 5));
  
  
  for (int i = 0; i < N; i = i + 1) 
  {
    float theta = map(i, 0, N, 0, 360);
    float r = random(width/2);
   
    //x = random(width);
    //y = random(height);
    x = width / 2 + r * cos(theta);
    y = height /2 + r * sin(theta);
    z = random(-400, 400);
    
    r = c * (float)Math.pow((double)r, (2.0/5.0)); //map(r, 0, width/2, 1, 0);
    
    vx = -r * sin(theta);
    vy = r * cos(theta);
    vz = random(-0.1, 0.1);
    
    k = random(0.5, 2);
    
    p.add(new Planet(x, y, z, vx, vy, vz, k * dRad, k * dDensity));

    size = p.size();
  }
}




void draw()
{ 
  background(0);
  lights();
  println("FrameRate: " + frameRate);

  rotation(); // These two cost about 2 - 4 frames (at N = 200)
  axis();
  
  size = p.size();

  for (int i = size-1; i >= 0; i = i - 1) 
  {
    for (int j = i - 1; j >= 0; j = j - 1) 
    {
      int size = p.size();
      if (i <= size - 1)
      {
        pi = p.get(i);
        pj = p.get(j);

        posDiff = pi.pos.copy().sub(pj.pos);
        posDiffSq = posDiff.magSq();
        
        if (posDiffSq <= (pi.rad + pj.rad)*(pi.rad + pj.rad))
        { 
          if (random(1) < 0.5)
          {
            if (pi.mass > pj.mass)
            {
              aggregate(pi, pj);
              p.remove(j);
            } else
            {
              aggregate(pj, pi);
              p.remove(i); 
            }
          } else
          {
            collide(pi, pj);
          }
        } else
        {
          //println("gRAVITY");
          gravity(pi, pj);
        }
      }
    }
  }

  for (int i = 0; i < p.size(); i = i + 1) 
  {
    Planet planet = p.get(i);
    planet.update();
    planet.show();

  }
  //println("Total mass: " + totMass);
  //totMass = 0;
  //println("No. of Planets: " + p.size());
}
