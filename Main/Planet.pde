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
  if (mousePressed)
  {
    rotAngle = map(mouseX, 0, width, 0, TWO_PI);
  }

  Planet r = p.get(0);

  float rPosx = r.pos.x;
  float rPosy = r.pos.y;
  float rPosz = r.pos.z;

  //translate(pPosx, pPosy, pPosz);


  translate(-rPosx, -rPosy, 0);
  rotateY(rotAngle);
  //scale(0.8);
  
  translate(width/2, height/2, rPosz);
}
