//Title font "Impact" //<>//
import java.util.*;
import processing.serial.*;
int score = 0;
final int displayWidth =900;
final int displayHeight =504;
Env env;
boolean start;
boolean jump;
PFont f;
void setup()
{
  size(displayWidth, displayHeight);
  f = createFont("Impact", 45, false);
  env = new Env();
  start = false;
  jump = false;
}
void draw()
{
  /*
  get user input  
   for each object:
   update object state
   update game state (if bird crashed or whatever)
   for each object:
   paint on the screen
   update end of turn vars (clock)
   */
  jump = false;
  start = false;
  if (keyPressed)
  {
    start = true;
    jump = true;
  }

  textFont(f, 45);
  fill(0);
  for (int x = -2; x < 3; x++) {
    for (int y = -2; y < 3; y++) {
      text("Score: " + str(score), 700+x, 50+y);
    }
    text("Score: " + str(score), 700+x, 50);
    text("Score: " + str(score), 700, 50+x);
  }
  fill(255);
  text("Score: " + str(score), 700, 50);

  env.update(start, jump);
  for (Sprite s : env.sprites)
  {
    image(s.img, s.x, s.y);
  }
}
void loop()
{
}

class Env
{
  public int mode; // 0 for title screen 1 for playing screen 2 for game over
  public int clock;
  public Sprite[] bg;
  public ArrayList<Sprite> sprites;
  public Bird b;
  public Env()
  {
    score =0;
    clock = 0;
    mode = 0;
    bg = new Sprite[3];
    bg[0] = new Sprite(0, 0, loadImage("Images/finaltitle.png"));
    bg[1] = new Sprite(0, 0, loadImage("Images/flappy background.png"));
    bg[2]= new Sprite(0, 0, loadImage("Images/gameOver.png"));
    sprites = new ArrayList<Sprite>();
    sprites.add(bg[0]); // first array slot will be game mode ex: title screen
    b = new Bird();
  }
  public void genPipe()
  {
    if (clock % 75 == 0)
      sprites.add(new Pipe());
  }
  public void remPipe()
  {
    Iterator<Sprite> looper = sprites.iterator();
    while (looper.hasNext())
    {
      Sprite cur = looper.next();
      if (cur.x < 0)
      {
        looper.remove();
        score++;
      }
    }
  }
  public void update(boolean st, boolean j)
  {
    if (st && mode == 0)
    {
      sprites.set(0, bg[1]);
      sprites.add(b);
      mode = 1;
    }
    if (mode ==1)
    {

      genPipe();
      remPipe();
      clock++;

      for (Sprite s : sprites)
      {
        if (s.equals(b))
        {
          b.turn(j, clock);
          if (b.y >= displayHeight)
          {
            mode = 2;
          }
        } else if (!s.equals(sprites.get(0)))
        {
          s.turn();
          if (s.collision(b)  == true)
          {
            mode =2;
          }
        }
      }
    }
    if (mode == 2)
    {
      sprites = new ArrayList<Sprite>();
      sprites.add(bg[2]);
      mode = 0;
    }
  }
}
class Pipe extends Sprite
{
  public Pipe()
  {
    super(800, -50 + int(random(-300, -50)), loadImage("Images/pipes.png"));
    vx = -4;
  }
}

class Bird extends Sprite
{
  public int ay = 1;
  public Bird()
  {
    super(0, displayHeight/2, loadImage("Images/bird.png"));
    vy+=ay;
  }
  void turn(Boolean j, int clock)//crashed or not
  {
    if (j)
      vy = -10;
    else if (vy < 0)
      vy = -0;
    else if (clock % 2 == 0)
      vy+=ay;     
    move(vx, vy);
    if (y <= 0)
      y = 0;
  }
}

class Sprite 
{
  public int x;//position on screen
  public int y;
  public int w; //width
  public int h; //height 
  public int vx;
  public int vy;
  public PImage img; 

  public Sprite(int xpos, int ypos, PImage i)
  {
    x = xpos;
    y = ypos;
    img = i;
    h = i.height;
    w = i.width;
    vx = 0;
    vy = 0;
  }
  void turn()
  {
    move(vx, vy);
  }
  public Sprite()
  {
    x = 0;
    y = 0;
    img = null;
    w = 0;
    h = 0;
  }
  public void move(int dx, int dy)
  {
    x+=dx;
    y+=dy;
  }
  public void setPos(int newX, int newY)
  {
    x = newX;
    y = newY;
  }

  public boolean equals(PImage other)
  {
    return img.equals(other);
  }

  public boolean collision(Sprite other)
  {
    if (other.y < this.y+300 || other.y+other.h> this.y+540)
    {
      if (other.x < this.x+this.w && other.x > this.x)
      {
        return true;
      }
    }
    return false;
  }
}
