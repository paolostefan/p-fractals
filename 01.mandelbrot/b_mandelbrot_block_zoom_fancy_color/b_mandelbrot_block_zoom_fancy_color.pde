/**
 *  Mandelbrot set with hardcoded (start) zoom value using naive successive refinements.
 *
 *  Possible optimizations:
 *   . the topright corner of every block is already done and
 *     does not need to be recalculated.
 *
 *  Left click: the zoom is multiplied by zoomMult and the fractal is redrawn.
 *  Right click: reset the zoom.
 */

int pixSize = 500;
float rmin=-2, imin=-1.3, side=2.6;
float rmax=rmin+side, imax=imin+side;

float init_rmin = rmin;
float init_imin = imin;
float init_side = side;

int maxIter = 1500;
int logmax = (int)Math.ceil(log(maxIter));

float zoom, lastzoom=0, init_zoom;
float zoomMult = 3;

int[] blocksizes = { 16, 8, 4, 2, 1 };
int b=0, bsize = blocksizes[b];
boolean done = false;

void settings() {

  size( pixSize, pixSize );
}

void setup() {

  colorMode( HSB, logmax, 180, 1000 );

  zoom = width/(rmax-rmin);
  init_zoom = zoom;
  if (height/(imax-imin)>zoom) {
    zoom = height/(imax-imin);
  }
  noStroke();
}

void draw() {

  loadPixels();

  if ( lastzoom == zoom && done ) return;
  println(lastzoom+","+zoom+","+bsize);

  background(0, 0, -1);
  int start = millis();

  float zr, zi, cr, ci, zrtmp;

  int it;

  for ( int j=0; j<height; j+=bsize ) {

    for ( int i=0; i<width; i+=bsize ) {

      ci = zi = imin+j/zoom;
      cr = zr = rmin+i/zoom;
      if (zr*zr+zi*zi>4f) continue;

      for ( it=0; it<maxIter; it++ ) {
        zrtmp = zr*zr-zi*zi + cr;
        zi = 2*zr*zi + ci;
        zr = zrtmp;

        if (zr*zr+zi*zi>4f) break;
      }

      color col;
      if (it==maxIter) col = color(0, 0, -1);
      else {

        float rad = sqrt(zr*zr+zi*zi);
        float alfa = acos(zr/rad)*180f/PI;

        int angle = (int)(Math.round(alfa));
        int rad1000 = (int)(1000f*rad)-2000;
        int logit = Math.round(log(it));

        col = color( logit, angle, rad1000 );
      }

      if (bsize == 1) {
        pixels[j*width+i] = col;
      } else {
        fill(col);
        rect(i, j, i+bsize, j+bsize);
      }
    }
  }

  if ( b>=blocksizes.length) {
    updatePixels();
    b=0;
    done = true;
  } else bsize = blocksizes[b++];

  //saveFrame( "BuddhaImg_iter-###.tif" );

  int end = millis();
  println( (end-start)+ " msec (" + 
    (pixSize*pixSize*1000/(end-start)) + " pixels/sec)" );

  lastzoom = zoom;
}

void mousePressed() {

  if ( mouseButton == LEFT ) {
    float pressR, pressI;
    pressR = rmin + mouseX/zoom;
    pressI = imin + mouseY/zoom;
    println( "Zoom requested at ("+pressR+" + " + pressI + "i )" );

    zoom*= zoomMult;
    float rspread = width/zoom;
    float ispread = height/zoom;

    rmin = pressR-rspread/2;
    rmax = rmin + rspread;

    imin = pressI-ispread/2;
    imax = imin + ispread;
    b = 0;
    bsize = blocksizes[0];
    done = false;
  } else {

    // Reset
    zoom = init_zoom;
    rmin = init_rmin;
    imin = init_imin;

    b = 0;
    bsize = blocksizes[0];
    done = false;
  }
}