int N = 1000;
PVector zero = new PVector(0, 0);
PVector posDiff;
float posDiffSq;
float dRad = 5;
float dDensity = 1;
Planet pi, pj;
float G = 0.00001;
float c = 0.15;
float x, y, vx, vy, k;
float collisionDamping = 0.9;
int size;
float totMass = 0;

ArrayList<Planet> p = new ArrayList<Planet>();

void setup()
{  
  size(800, 800);
  frameRate(120);

  for (int i = 0; i < N; i = i + 1) 
  {
    float angle = map(i, 0, N, 0, 360);
    float r = random(width/2);
    
    x = width / 2 + r * cos(angle);
    y = height /2 + r * sin(angle);
    
    

    r = c * (float)Math.pow((double)r, (2.0/5.0)); //map(r, 0, width/2, 1, 0);
    
    vx = -r * sin(angle);
    vy = r * cos(angle);
    
    
    //x = random(width);
    //y = random(height);
    k = random(0.1, 2);
    p.add(new Planet(x, y, vx, vy, k * dRad));

    size = p.size();
  }
  
  p.add(new Planet(width/2, height/2, 0, 0, 5 * dRad));
}


void draw()
{ 
  background(51);
  println("FrameRate: " + frameRate);

  for (int i = size-1; i >= 0; i = i - 1) 
  {
    for (int j = i - 1; j >= 0; j = j - 1) 
    {
      int size = p.size();
      if (i <= size-1)
      {
        pi = p.get(i);
        pj = p.get(j);

        posDiff = pi.pos.copy().sub(pj.pos);
        posDiffSq = posDiff.magSq();

        if (posDiffSq <= (pi.rad + pj.rad)*(pi.rad + pj.rad)/32)
        { 
          if (random(1) < 0.5)
          {
            aggregate(pi, pj);
            p.remove(j);
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
    totMass = totMass + planet.mass;
  }
  println("Total mass: " + totMass);
  totMass = 0;
  //println("No. of Planets: " + p.size());
}
