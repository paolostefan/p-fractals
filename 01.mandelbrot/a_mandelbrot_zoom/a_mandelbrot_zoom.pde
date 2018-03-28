/**
 *  Mandelbrot set with hardcoded start values
 *
 *  Left click: the zoom is multiplied by zoomMult and the fractal is redrawn.
 *  Right click: reset the zoom.
 */

int pixSize = 800;
double rmin=-2, imin=-1.3, side=2.6;
double rmax=rmin+side, imax=imin+side;

double init_rmin = rmin;
double init_imin = imin;
double init_side = side;

int maxIter = 600;

double zoom, lastzoom=0, init_zoom, zoomMult = 2;

void settings() {
  size( pixSize, pixSize );
}

void setup() {
  colorMode(HSB, log(maxIter), maxIter, 100);

  zoom = width/(rmax-rmin);
  if (height/(imax-imin)>zoom) {
    zoom = height/(imax-imin);
  }

  init_zoom = zoom;
}

void mousePressed() {

  if ( mouseButton == LEFT ) {
    double pressR, pressI;
    pressR = rmin + mouseX/zoom;
    pressI = imin + mouseY/zoom;
    
    zoom*= zoomMult;
    double rspread = width/zoom;
    double ispread = height/zoom;

    rmin = pressR-rspread/2;
    rmax = rmin + rspread;

    imin = pressI-ispread/2;
    imax = imin + ispread;
    
    println( "Zoom requested: window now is ("+rspread+" x " + ispread + ")" );
  } else {

    // Reset the zoom
    zoom = init_zoom;
    rmin = init_rmin;
    imin = init_imin;
  }
}

/**
 * Iterates the complex function z = z^2 + c over the x,y pixel.
 * x and y are integer pixel coordinates that need to be translated into complex coordinates.
 *
 * Returns the number of iterations that took the 
 */
int mandel(int x, int y) {
  double zr, zi, cr, ci, zrtmp;
  int it;
  cr = zr = rmin+x/zoom;
  ci = zi = imin+y/zoom;

  for ( it=0; it<maxIter && (zr*zr+zi*zi)<4f; it++ ) {
    zrtmp = zr*zr-zi*zi + cr;
    zi = 2*zr*zi + ci;
    zr = zrtmp;
  }
  return it;
}

void draw() {
  // Redraw the fractal only if the zoom has changed
  if (lastzoom == zoom) {
    return;
  }

  background(0);

  int start = millis();

  loadPixels();

  int it;
  for (int j=0, px=0; j<height; j++ ) {
    for ( int i=0; i<width; i++, px++ ) {
      it = mandel(i, j);
      if (it == maxIter) continue;
      pixels[px] = color(log(it), maxIter-it, 100);
    }
  }

  updatePixels();

  int end = millis();
  println( (end-start)+ " ms (" + (pixSize*pixSize*1000/(end-start)) + " pixels/sec)" );

  lastzoom = zoom;
}