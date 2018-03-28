/**
 *  Mandelbrot set with hardcoded start values
 *
 *  Left click: the zoom is multiplied by zoomMult and the fractal is redrawn.
 *  Riight click: reset the zoom.
 */

int pixSize = 800;
float rmin=-2, imin=-1.3, side=2.6;
float rmax=rmin+side, imax=imin+side;

float init_rmin = rmin;
float init_imin = imin;
float init_side = side;

int maxIter = 600;

float zoom, lastzoom=0, init_zoom, zoomMult = 2;

void settings() {
  size( pixSize, pixSize );
}

void setup() {
  colorMode(HSB, log(maxIter), 255, 255);

  zoom = width/(rmax-rmin);
  if (height/(imax-imin)>zoom) {
    zoom = height/(imax-imin);
  }

  init_zoom = zoom;
}

int maxPixel(int[] plane) {
  int maxval = 0;
  for ( int j=0, jm=plane.length; j<jm; j++ ) {
    if ( plane[j]>maxval ) maxval = plane[j];
  }
  return maxval;
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
  } else {

    // Reset the zoom
    zoom = init_zoom;
    rmin = init_rmin;
    imin = init_imin;
  }
}

void draw() {
  if (lastzoom == zoom) {
    return;
  }
  
  background(0);
  
  int start = millis();

  loadPixels();

  float zr, zi, cr, ci, zrtmp;
  int it;

  for (int j=0, px=0; j<height; j++ ) {

    for ( int i=0; i<width; i++, px++ ) {
      cr = zr = rmin+i/zoom;
      ci = zi = imin+j/zoom;

      for ( it=0; it<maxIter; it++ ) {
        zrtmp = zr*zr-zi*zi + cr;
        zi = 2*zr*zi + ci;
        zr = zrtmp;

        if (zr*zr+zi*zi>4f) {
          break;
        }
      }

      if (it == maxIter) continue;
      pixels[px] = color(log(it), 255, 255);
    }
  }

  updatePixels();

  int end = millis();
  println( (end-start)+ " ms (" + (pixSize*pixSize*1000/(end-start)) + " pixels/sec)" );
  
  lastzoom = zoom;
}