/**
 * Mandelbrot set + Julia set overlaid -on mouse click.
 *
 * Left click: transparent Julia set
 * Right click: opaque Julia set
 */

PImage julia, mandel;

int view_width = 800;
int view_height = 600; // multiples of 4 please

// Latest mouse coordinates @which we rendered Julia set 
int prevx = -1;
int prevy = -1;


// Mandel coords
float mandel_re_min = -1.85;
float mandel_re_max = 0.55;
float mandel_step = (mandel_re_max-mandel_re_min)/view_width;

/**
 * The pixels at y=view_height/2 are the Real axis.
 * mandel_im_min is the Imaginary part of the topmost pixel row (y=0)
 */
float mandel_im_min = -mandel_step*view_height/2;
int maxMandIter = 1500;


// Julia coords (symmetric), calculated max
float julia_re_min = -1.2;
float julia_re_max = -julia_re_min;
float julia_step = (julia_re_max-julia_re_min)/view_width;
float julia_im_min = -julia_step*view_height/2;
int maxJuliaIter = 255;



void settings() {
  size(view_width, view_height);
  smooth(4);
}

void setup() {

  julia = createImage(view_width, view_height, ARGB);
  mandel = createImage(view_width, view_height, RGB);

  drawMandel();
}

/**
 * Draw the Mandelbrot set.
 * 
 * Two loops iterate through pixels (x,y), translated into complex plane coordinates.
 * The complex number corresponding to (x,y) is the C number used:
 * 1. as the starting point z0 ;
 * 2. to compute z' = z^2 + C .
 *
 * If, after maxMandIter, the modulus of the number is still below 2, the algorithm
 * assigns the current pixel to the Mandelbrot set.
 */
void drawMandel() {
  mandel.loadPixels();
  colorMode(HSB, sqrt(maxMandIter));
  float re, im;
  float cr, ci;
  int iter, timestart, timeend;

  timestart = millis();

  color c;
  int counter = 0;
  for (int y = 0; y<view_height; y++) {
    ci = mandel_im_min + y*mandel_step;
    for (int x = 0; x<view_width; x++) {

      re = cr = mandel_re_min + x*mandel_step;
      im = ci;

      for (iter=0; iter<maxMandIter; iter++) {
        // z = z^2+c
        float zrtmp = re*re - im*im + cr;
        im = 2*re*im + ci;
        re = zrtmp;

        if (re*re+im*im > 4d) {
          break;
        }
      }

      c = (iter>1 && iter<maxJuliaIter)?
        color(sqrt(iter), sqrt(maxMandIter), sqrt(maxMandIter)):
        // Mandel set or less outside 2-circle: black
        color(0, 0, 0);

      //mandel.pixels[x+(y*view_width)] = c;
      mandel.pixels[counter++] = c;
    }
  }

  mandel.updatePixels();

  timeend = millis();
  if (timeend>timestart) {
    println( "Mandel: " +(timeend-timestart)/1000f+ " s (" + 
      (float(view_width*view_height)/(1000f*(timeend-timestart))) + " Mpixels/s)" );
  } else {
    println("Mandel: LESS THAN 1ms!!!");
  }
}

/**
 * Draws the Julia set for C corresponding to the mouseX, mouxeY coordinates.
 *
 * Two loops iterate through pixels (x,y), translated into complex plane coordinates.
 * The translated coordinates are the starting point (z0) for the succession  z = z^2 + C . 
 * 
 * If, after maxJuliaIter, the modulus of the number is still below 2, the algorithm
 * assigns the current pixel to the Julia set.
 */
void drawJulia(float alpha) {
  int iter, timestart, timeend, max = int(sqrt(maxJuliaIter));

  timestart = millis();
 
  colorMode(HSB, max);

  julia.loadPixels();

  color c;
  float re, im;
  // Mouse coordinates - taken over Mandelbrot fractal
  float cr = mandel_re_min + mouseX*mandel_step, ci = mandel_im_min+mouseY*mandel_step;

  // Start from 0,0, and (view_width-1, view_height-1)
  // counter is incremented, reverse_counter is decremented @each step
  int counter = 0, reverse_counter = view_width*view_height-1;
  for (int y = 0; y<view_height/2; y++) {
    for (int x = 0; x<view_width; x++) {
      re = julia_re_min + x*julia_step;
      im = julia_im_min + y*julia_step;

      for (iter=0; iter<maxJuliaIter; iter++) {
        // z = z^2+c
        float zrtmp = re*re - im*im + cr;
        im = 2*re*im + ci;
        re = zrtmp;

        if (re*re+im*im > 4f) {
          break;
        }
      }

      c = (iter>1 && iter<maxJuliaIter)?
        color(sqrt(iter), max, max, int(alpha*max)):
        // Julia set or outside : black
        color(0, 0, 0, int(alpha*max));

      //julia.pixels[x+(y*view_width)] = julia.pixels[(view_width-x-1)+(view_height-y-1)*view_width] = c;
      julia.pixels[counter++] = julia.pixels[reverse_counter--] = c;
    }
  }

  julia.updatePixels();

  timeend = millis();

  if (timeend>timestart) {
    println( cr+","+ci + ": " +(timeend-timestart)/1000f+ " s (" + 
      (float(view_width*view_height)/(1000f*(timeend-timestart))) + " Mpixels/s)" );
  } else {
    println(cr+","+ci + ": LESS THAN 1ms!!!");
  }
}

void draw() {
  image(mandel, 0, 0);
  if (mousePressed) {
    if ( mouseX != prevx || mouseY != prevy ) {
      float alpha = mouseButton == LEFT? .5:1f;
      // refresh Julia
      drawJulia(alpha);

      prevx = mouseX;
      prevy = mouseY;
    }

    image(julia, mouseX-view_width/4, mouseY-view_height/4, view_width/2, view_height/2 );
  }
}