class Planet
{
  PVector pos, vel, acc;
  float rad, density, mass, vol, col;

  Planet(float x0, float y0, float z0, float vx0, float vy0, float vz0, float radius, float density)      
  {
    pos = new PVector(x0, y0, z0);
    vel = new PVector(vx0, vy0, vz0);
    acc = new PVector(0, 0, 0);
    rad = radius;
    vol = (4/3) * PI * cube(rad) ;
    this.density = density; 
    mass = vol * density;
    col = map(density, dDensity, 5 * dDensity, 255, 0);
  }

  void update()
  {
    vel.add(acc);
    pos.add(vel);
    acc.set(zero.copy());
    //println("Mass: " + mass);
  }

  void show()
  {
    fill(col, col, 255);
    noStroke();
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    sphere(rad);
    popMatrix();
  }

  void addForce(PVector force)
  {
    acc.add(force.copy().div(mass));
  }
}


void gravity(Planet planet1, Planet planet2)
{
  float gravMag = (G * planet1.mass * planet2.mass)/posDiffSq;
  PVector gravForce = posDiff.copy().setMag(gravMag);

  planet2.addForce(gravForce.copy());
  planet1.addForce(gravForce.copy().mult(-1));
}


void collide(Planet planet1, Planet planet2)
{
  PVector v1v2Diff = planet1.vel.copy().sub(planet2.vel.copy());
  float vDiff = v1v2Diff.mag();

  float m1 = planet1.mass;
  float m2 = planet2.mass;

  PVector vVcm = planet1.vel.copy().mult(m1);
  vVcm.add(planet2.vel.copy().mult(m2));
  vVcm.div(m1 + m2);

  PVector v1Temp = posDiff.copy().setMag(vDiff * m2/(m1 + m2) * collisionDamping);
  PVector v2Temp = posDiff.copy().setMag(-vDiff * m1/(m1 + m2) * collisionDamping);

  planet1.vel.set(v1Temp.add(vVcm));
  planet2.vel.set(v2Temp.add(vVcm));
}


void aggregate(Planet p1, Planet p2)
{
  float m1 = p1.mass;
  float m2 = p2.mass;
  PVector momentum = p1.vel.copy().mult(m1);
  momentum.add(p2.vel.copy().mult(m2));

  PVector posNew = p1.pos.copy().mult(m1);
  posNew.add(p2.pos.copy().mult(m2));
  p1.pos = posNew.div(m1 + m2);

  float rNew = p1.density*cube(p1.rad) + p2.density*cube(p2.rad);
  p1.density = (p1.density*p1.vol + p2.density*p2.vol)/(p1.vol + p2.vol); // fixS
  rNew = rNew / p1.density;

  p1.rad = (float)Math.pow((double)rNew, (1.0/3.0));
  p1.vol = (4/3)*PI*cube(p1.rad);
  p1.mass = p1.density*p1.vol;
  p1.vel = momentum.div(p1.mass);
}


float cube(float num)
{
  return num * num * num;
}

void rotation() // fix
{
  float rotationSpeed = 0.1;
  if (mousePressed)
  {

    if (keyPressed && key == TAB)
    {
      if (mouseX > width/2)
      {
        rotAngleY += rotationSpeed; //map(mouseY, 0, height, 0, TWO_PI);//%TWO_PI;
        //rotAngleY = map(mouseX, 0, width, 0, TWO_PI);//%TWO_PI;
      } else
      {
        rotAngleY -= rotationSpeed;
      }
    } else
    {
      if (mouseY > height/2)
      {
        rotAngleX += rotationSpeed; //map(mouseY, 0, height, 0, TWO_PI);//%TWO_PI;
        //rotAngleX = map(mouseX, 0, width, 0, TWO_PI);//%TWO_PI;
      } else
      {
        rotAngleX -= rotationSpeed;
      }
    }
  }

  //println("rotAngleX: " + rotAngleX);
  //println("rotAngleY: " + rotAngleY);

  PVector CoMPos = CoM();

  PVector centrePlanet = p.get(0).pos.mult(0.5);



  float x = width/2 +centrePlanet.x;//CoMPos.x;
  float y = height/2+ centrePlanet.y;//CoMPos.y;
  float z = 1000/2 + centrePlanet.z;//CoMPos.z;


  translate(x, y, z);//width/2 +CoMPos.x, height/2+CoMPos.y, 1000/2 +CoMPos.z);
  axis();

  stroke(255);

  rotateX(rotAngleX);
  rotateY(rotAngleY);
  line(0, 0, 0, CoMPos.x, CoMPos.y, CoMPos.z);

  //scale(1);
  //translate(100, 100, 100);//width/2 - 2*x, height/2 - 2*y);
}


void axis()
{
  float lineLen = 200;
  strokeWeight(4);
  translate(width/2, height/2);

  stroke(255, 0, 0); // RED X axis
  line(0, lineLen, 0, 0, 0, 0);

  stroke(0, 255, 0); // GREEN Y axis
  line(0, 0, 0, lineLen, 0, 0);

  stroke(0, 0, 255); // BLUE Z axis
  line(0, 0, 0, 0, 0, lineLen);

  translate(-width/2, -height/2);
}
Planet planet;


PVector CoM()
{
  totMass = 0;
  PVector CoMPos = new PVector();
  for (int i = 0; i < p.size(); i++)
  {
    planet = p.get(i);
    CoMPos.add(planet.pos.copy().mult(planet.mass));
    totMass = totMass + planet.mass;
  }
  PVector output = CoMPos.div(totMass);

  //CoMPos.set(zero);
  //totMass = 0;

  //println(output);
  return output;
}

float calcReducedMass()  
{
  float temp = 0;

  for (int i = 0; i < p.size(); i++)
  {
    planet = p.get(i);
    temp = temp + 1/planet.mass;
  }
  //println("inverse temp: " +1/temp);
  return 1/temp;
}
