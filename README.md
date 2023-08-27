# seam-carver

This program takes an image as input and generates a video as output. Every frame of the video
represents one 'seam' or path of pixels down the image being selected to remove. The image shrinks as
the program removes the lowest weighted seams to shrink the aspect ratio. This strategy, called seam carving, 
can be used to shrink the aspect ratio of an image while keeping important details. 

Input: 'input.PNG'
Output: 'output.mp4'

An example input and output are provided in this repo.