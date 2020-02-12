//Add a reset button with sliders


// tab jumps between planets but seems to move the new selected planet to be the centre 
// to the origin next to the previous selected planet.

int N = 0;
int setFrameRate = 3;
int cutDist = 10000; // distance at which to eliminate planets.
int randVelAdd = 1;
float G = 0.01; // 0.001 for sun and two planets
float c = 3;
float dRad = 5.5;
float dDensity = 1;

float AU = 1000;
float v0;// = sqrt(G*//20;

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


PrintWriter output;
float dr, dv;
float minima = 0;


float scaleFactor = 0.5;

float prevdr=0, prev2dr=0;

int centreP = 0;



void setup()
{  
  output = createWriter("output.txt");

  frame.setLocation(100, 100);
  size(1500, 2000, P3D);
  frameRate(setFrameRate);

  reducedMass = calcReducedMass();
  //c = 0.1;// *  (float)Math.pow((double)reducedMass * G, 0.5);
  //Planet(float x0, float y0, float z0, float vx0, float vy0, float vz0, float radius, float density)

  p.add(new Planet(0, 0, 0, 0, 0, 0, 5 * dRad, dDensity * 100));

  v0 = sqrt(G*p.get(0).mass/AU);

  p.add(new Planet(0, AU, 0, v0, 0, 0, 3 * dRad, dDensity));

  float dis = 30;
  v0 = v0 - sqrt(G*p.get(1).mass/dis);
  
  p.add(new Planet(0, AU - dis, 0, v0, 0, 0, 0.5*dRad, dDensity));
  //p.add(new Planet(0.1*width/4 - 40, 0.1*height/4, 0, 0, -0.6*v0, 0, 1 * dRad, dDensity));

  //p.add(new Planet(width/2 + 400, height/2, 0,  0, 2.2, 0, 1 * dRad, dDensity));
  //p.add(new Planet(width/2 + 408, height/2, 0,  0, 2.44, 0, 0.2 * dRad, dDensity));
  //p.add(new Planet(width/2, height/2, 0,  0, 0, 0, 10 * dRad, dDensity * 5));

  //p.add(new Planet(width/2 - 400, height/2, 0,  0, -2.2, 0, 1 * dRad, dDensity));
  //p.add(new Planet(width/2 - 408, height/2, 0,  0, -2.4365, 0, 0.2 * dRad, dDensity));

  for (int i = 0; i < N; i = i + 1) 
  {
    float theta = random(360);//map(i, 0, N, 0, 360);
    float phi = random(360);
    float r = random(width/4);

    //x = random(width);
    //y = random(height);
    x = r * sin(phi)*cos(theta);
    y = r * sin(phi)*sin(theta);
    z = r* cos(phi);//random(-1000, 1000);

    //r = c * (float)Math.pow((double)r, (2.0/5.0)); //map(r, 0, width/2, 1, 0);
    float vel0 = c*sqrt(1/r);

    vx = -vel0 * cos(phi)*sin(theta) + random(-randVelAdd, randVelAdd);
    vy = vel0 * cos(phi)*cos(theta) + random(-randVelAdd, randVelAdd);
    vz = 0;//vel0 * sin(phi) + random(-randVelAdd, randVelAdd);

    k = 1;//random(0.5, 2);
    //print(vx, vy, vz);

    p.add(new Planet(x, y, z, vx, vy, vz, k * dRad, k * dDensity));

    size = p.size();
  }
}




void draw()
{ 
  background(0);
  lights();



  size = p.size();
  //if (frameCount%setFrameRate == 0)
  //{
  //  println("No. Planets: " +size);
  //  println("FrameRate: " + frameRate);
  //}

  rotation(); // These two cost about 2 - 4 frames (at N = 200)

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
                //aggregate(pi, pj);
                //p.remove(j);
              } else
              {
                //aggregate(pj, pi);
                //p.remove(i);
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


  outputData();
}
