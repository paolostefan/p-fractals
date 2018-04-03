/**
 *
 *  Buddhabrot / Nebulabrot progressive implementation
 *
 *  . realtime update
 *  . each channel is given a different "bail out speed"
 *
 * Possible optimizations:
 *  . starting points could be discarded with a better function
 *  . use 2 threads
 *
 *  Any mouse click: save the current frame to disk.
 *
 *  @author Paolo Stefan 2018
 *
 *  Inspired by the work of Albert Lobo and based on the Buddhabrot algorithm by Melinda Green.
 */

// Coordinates/sizes/properties

// color mode, RGB or HSB
int    cm = RGB;

int    pixSize = 720;     // Window size in px (both horizontal & vertical)

float rmin = -2.5, imin=-1.8, side=3.6;
float rmax = rmin + side;
float imax = imin + side;
float zoom;

// Try this many nearby points once a good one is found
int    nearbyTries = 2000;
float  triesRadius = 20;

float[] tries = new float[nearbyTries*2];

// Draw this many trajectories per frame
int trajPerFrame = 10000;

// Color channels
int buddha[][];

// Order of color channels (must be a 3-element int array, a permutation of (0,1,2);
// if colormode is RGB, the first element will map to Red, the second to Green and the third to Blue
// e.g. channelOrder = {2,1,0} means: buddha[2] is red, buddha[1] is green and buddha[0] is blue
int channelOrder[] = { 0, 1, 2 };

// Bailout iterations per channel (buddha[n])
int bailout_ch0 = 600000;
int bailout_ch1 = 60000;
int bailout_ch2 = 6000;

// Trajectories coordinates
float[] trajec = new float[bailout_ch0*2];

int[] lut = new int[65536];

PFont fontA;

/**
 * Functions
 */
int maxPixel(int[] plane) {
  int maxval = 0;
  for ( int j=0, jm=plane.length; j<jm; j++ ) {
    if ( plane[j]>maxval ) maxval = plane[j];
  }
  return maxval;
}

/**
 * Compute the trajectory for point (cr, ci)
 * Fills the trajec[] array.
 * Returns the number of iterations done - bailing out when |z|>sqrt(7)
 */
int trajectory(float cr, float ci) {

  int n, tj;
  float zr, zi, zrtmp=0, zitmp=0;

  for ( n=0, tj=0; n<bailout_ch0; n++, tj+=2 ) {

    zr = zrtmp*zrtmp - zitmp*zitmp + cr; //re_mand( zrtmp, zitmp, cr )
    zi = 2*zrtmp*zitmp + ci; //im_mand( zrtmp, zitmp, ci );

    trajec[tj] = zrtmp = zr;
    trajec[tj+1] = zitmp = zi;
    // Test against a threshold bigger than 4,
    // otherwise the image will be cropped to the 2.0-radius circle
    if (zr*zr+zi*zi>12) break;
  }
  return n;
}

// Increment the pixels value in each channel, if it applies
void overlayTrajectory(int escaped) {

  for ( int ti=0; ti<2*escaped; ti+=2 ) {

    int coordx, coordy1, coordy2 ;

    coordx = int( Math.round((trajec[ti]-rmin)*zoom) );

    if (coordx<0 || coordx>=width) continue;

    coordy1 = int( Math.round((trajec[ti+1]-imin)*zoom) );
    coordy2 = int( Math.round((-trajec[ti+1]-imin)*zoom) );

    int off1 = coordx*height+coordy1;
    int off2 = coordx*height+coordy2;

    if (coordy1>=0 && coordy1<height && coordy2>=0 && coordy2<height){
      buddha[0][off1]++;
      buddha[0][off2]++;
    }
    else continue;

    if ( escaped<=bailout_ch1 ) {
      buddha[1][off1]++;
      buddha[1][off2]++;

      if ( escaped<=bailout_ch2 ) {
        buddha[2][off1]++;
        buddha[2][off2]++;
      }
    }
  }
}

/**
 *	Buddhabrot step computation
 */
void buddha3rot() {

  zoom = width/(rmax-rmin);
  float cr, ci, mod, phase;

  for ( int k=trajPerFrame; k>0; k-- ) {

    int n;
    /*

     Pick a random point that may not belong to M.

     The .4-radius disc centered in (-.2,0) belongs to M for sure.
     So does the .25-radius disc centered in (-1,0).

     See http://en.wikipedia.org/wiki/Mandelbrot_set#Optimizations
     See also https://sites.google.com/site/fabstellar84/fractals/cardioid

     Then, pick a random point farther than .4 from (-0.2+i0) using polar coordinates
     Please note: due to the fractal symmetry, it's enough to pick a point in the upper (Im>0)
     complex semi-plane.
     */

    mod = .4 + random(rmax);
    phase = random(PI);

    cr = -.2 + mod*cos(phase);
    ci = mod*sin(phase);

    // If you prefer to pick a really random point in the current window,
    //uncomment the following two lines
    //cr = rmin+rstep*random(divisions-1);
    //ci = imin+rstep*random(divisions-1);
    float modcr;
    // Test other disc
    modcr = cr+1.0;
    if ( (modcr*modcr) + (ci*ci) <= .0625) {
      k++;
      continue;
    }

    n = trajectory(cr, ci);
    if ( n<bailout_ch0 ) {
      overlayTrajectory(n);
      /**
       * Ok, this point was good.
       * Now, try some points around in the hope that they're good, too.
       */

      for ( int l = 0; l<nearbyTries*2; l+=2, k--) {
        if (k<=0) break;
        // spread using tries[] array
        n = trajectory(cr+tries[l], ci+tries[l+1]);
        if ( n<bailout_ch0 ) {
          overlayTrajectory(n);
          k--;
        }
      }
    }
  }
}

/**
 * Calculates the argument (phase) from Re and Im coordinates.
 */
float arg( float creal, float cimag ) {
  if (creal>0 && cimag>=0) return atan(cimag/creal);
  else if (creal>0 && cimag<0)  return atan(cimag/creal)+TWO_PI;
  else if (creal<0) return atan(cimag/creal)+PI;
  else return cimag>0? HALF_PI:3*HALF_PI;
}

void createTries() {
  // debug
  //color white = color(255);
  for (int i =0; i<nearbyTries*2; i+=2) {
    float mod = random(triesRadius);
    float phase = random(2*PI);
    tries[i]   = mod*cos(phase);
    tries[i+1] = mod*sin(phase);
    // debug
    //set( int(10*(triesRadius+tries[i])), int(10*(triesRadius+tries[i+1])), white );
  }
}

void createLut() {
  for (int i = 65535; i>=0; i--) {
    lut[i] = int(pow(i,.55));
  }
  // debug
  //color red = color(255,0,0),green=color(0,255,0);
  //for (int i = 0; i<pixSize; i++) {
  //  int x = i*65535/pixSize;
  //  set(i, lut[x], red);
  //  set(i, i, green);
  //}
}


// Set the current window size.
void settings() {
  size( pixSize, pixSize );
}

// Initial setup
void setup() {

  // comment to debug arrays
  background(0);
  loadPixels();

  buddha = new int[3][];
  buddha[0] = new int[width*height];
  buddha[1] = new int[width*height];
  buddha[2] = new int[width*height];

  // Load the font. Fonts must be placed within the data
  // directory of your sketch. A font must first be created
  // using the 'Create Font...' option in the Tools menu.
  fontA = loadFont("Monospaced-12.vlw");
  // Set the font and its size (in units of pixels)
  textFont(fontA, 12);

  print( "Creating tries ..." );
  createTries();
  println( "done." );
  print( "Creating lookup table ..." );
  createLut();
  println( "done." );
}


// to debug arrays, also rename this to e.g. draw_()
void draw() {

  boolean info = true;

  buddha3rot();
  int ch [][] = {
    buddha[channelOrder[0]],
    buddha[channelOrder[1]],
    buddha[channelOrder[2]]
  };

  int max[] = { max(255, maxPixel(ch[0])), max(255, maxPixel(ch[1])), max(255, maxPixel(ch[2])) };

  colorMode( cm, lut[max[0]], lut[max[1]], lut[max[2]] );

  for ( int of=(height-1)*width-1; of>=0; of-- ) {
    pixels[of] = color( lut[ch[0][of]], lut[ch[1][of]], lut[ch[2][of]] );
  }

  updatePixels();
  // Press any mouse button to save current pic
  if ( mousePressed ) saveFrame( "Buddhabrot-###.tif" );

  if ( info ) {
    // Debug & nerd stuff - current fps and max densities - turn it off if it bothers you :)
    // White font
    fill( sqrt(max[0]) );
    text( round(frameRate*10)/10f + " fps ("+ round(trajPerFrame*frameRate/1000) + " Kt/sec)", 10, 20 );
    text( "D=(" + max[0] +"," + max[1] + "," + max[2] + ")", 10, 33 );
  }
}
