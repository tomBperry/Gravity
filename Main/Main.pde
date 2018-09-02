int N = 500;
int setFrameRate = 60;
int cutDist = 1000000; // distance at which to eliminate planets.
int randVelAdd = 1;
float G = 0.01; // 0.001 for sun and two planets
float c = 0.2;
float dRad = 5;
float dDensity = 1;
float collisionDamping = 1;
float rotAngleX, rotAngleY = 0;
float totMass = 0;
float reducedMass;
PVector zero = new PVector(0, 0, 0);

float x, y, z, vx, vy, vz, k;
float posDiffSq;
int size;
Planet pi, pj;
ArrayList<Planet> p = new ArrayList<Planet>();
PVector posDiff;


void setup()
{  
  size(1920, 1080, P3D);
  frameRate(setFrameRate);
  
  reducedMass = calcReducedMass();
  c = 0.00000001 *  (float)Math.pow((double)reducedMass * G, 0.5);
  
  p.add(new Planet(width/2 - 10, height/2, 0,  0, 0.9, 0, 1 * dRad, dDensity));
  p.add(new Planet(width/2 + 30, height/2, 0,  0, -0.1, 0, 2 * dRad, dDensity));
  p.add(new Planet(width/2 - 40, height/2, 0,  0, -0.6, 0, 1 * dRad, dDensity));
  
  //p.add(new Planet(width/2, height/2, 0,  0, 0, 0, 10 * dRad, dDensity * 5));
  
  //p.add(new Planet(width/2 + 400, height/2, 0,  0, 2.2, 0, 1 * dRad, dDensity));
  //p.add(new Planet(width/2 + 408, height/2, 0,  0, 2.44, 0, 0.2 * dRad, dDensity));
  //p.add(new Planet(width/2, height/2, 0,  0, 0, 0, 10 * dRad, dDensity * 5));
  
  //p.add(new Planet(width/2 - 400, height/2, 0,  0, -2.2, 0, 1 * dRad, dDensity));
  //p.add(new Planet(width/2 - 408, height/2, 0,  0, -2.4365, 0, 0.2 * dRad, dDensity));

  for (int i = 0; i < N; i = i + 1) 
  {
    float theta = map(i, 0, N, 0, 360);
    float r = random(width/2);
   
    //x = random(width);
    //y = random(height);
    x = width / 2 + r * cos(theta);
    y = height /2 + r * sin(theta);
    z = random(-1000, 1000);
    
    r = c * (float)Math.pow((double)r, (2.0/5.0)); //map(r, 0, width/2, 1, 0);
    
    vx = -r * sin(theta) + random(-randVelAdd, randVelAdd);
    vy = r * cos(theta) + random(-randVelAdd, randVelAdd);
    vz = random(-0.1, 0.1) + random(-randVelAdd, randVelAdd);
    
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


  size = p.size();
  rotation(); // These two cost about 2 - 4 frames (at N = 200)
  axis();
  
  //for (int i = 0; i < p.size(); i = i + 1) 
  //{
  //  p.get(i).update();
  //}
  

    
  for (int i = size-1; i >= 0; i = i - 1) 
  {
    if (p.get(i).pos.x > cutDist || p.get(i).pos.y > cutDist
        || p.get(i).pos.x < -cutDist || p.get(i).pos.y < -cutDist)
    {
      println("Planet: " + i +  " eimlinated.");
      p.remove(i);
    } else
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
            //println("Collision");
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
