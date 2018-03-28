# Processing Fractals

![Buddhabrot pic generated using a_buddhabrot.pde](sample_pics/Buddhabrot-83783.jpg)

This repository collects some fractals written in [Processing](https://processing.org/) language.

The code is not highly optimized, as the focus is on *readability* to help users understand the algorithms.


## 01.mandelbrot

### a_mandelbrot_zoom

The Mandelbrot fractal drawn pixel by pixel. Left click to **zoom in**, right click to **reset zoom**.

![Mandelbrot pic generated using  a_mandelbrot_zoom.pde](sample_pics/mandel-1.jpg)

### b_mandelbrot_block_zoom

The Mandelbrot fractal drawn by successive refinements, that is, first in blocks of 16x16 pixels, then 8x8 pixels, etc. down to 1x1 pixel.

### b_mandelbrot_block_zoom_fancy_color

Same as ***b_mandelbrot_block_zoom***, with an alternative coloring technique.

### c_mandelbrot_julia

By clicking on a point of the Mandelbrot set, the corresponding Julia set is shown as an overlay (easier done that said :smile:)

![Mandelbrot + Julia pic generated using  c_mandelbrot_julia.pde](sample_pics/mandel-julia-1.jpg)

### d_mandelbrot_block_zoom_ord3

Third order Mandelbrot set. Left click to **zoom in**, right click to **zoom out**.

![3rd order Mandelbrot set generated using  c_mandelbrot_julia.pde](sample_pics/mandel3-1.png)

## 02.buddhabrot

### a_buddhabrot

The Buddhabrot rendering algorithm discovered by Melinda Green. This implementation does not wait to end the rendering, instead it outputs trajectories on the go, giving an idea of what's going on.

Any mouse click **saves the current picture** to disk.

![An early frame of the Buddhabrot generated using  a_buddhabrot.pde](sample_pics/Buddhabrot-248.png)
 An early frame of the Buddhabrot generated using  a_buddhabrot.pde

![Buddhabrot pic generated using a_buddhabrot.pde](sample_pics/Buddhabrot-83783-200x200.jpg)

A very late frame of the Buddhabrot.



---

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
