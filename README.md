# Matlab-Finger-Counter
Uses a specified range of pixel values to find a hand in an image or video, and a blob analysis is then used to count the number of fingers that are being held up.  

Takes in image or video 
--> finds the hand using YCbCr color space 
--> converts to a binary image 
--> uses blob analysis to find the centroid of the object (hand) 
--> turns a radius around the centroid to 0 value pixels 
--> counts the number of areas left (fingers)

The image needs to be resized to an appropriate size. If the image is too sharp, then it picks up unneccessary information, such as arm hairs.
If the program were to pick this up, it could miscount the number of fingers since it uses binary blob analysis.  The arm hairs could be counted as blobs. 

The image is then converted from from RGB to YCbCr color space. 
The blue and red color values are extracted, and the pixels in the image with the specified range of Cb (about 67<=Cb<=137) and Cr (about 133<=Cr<=173) are found.
It is important to note that these values need to be adjusted based on the color of the hand in the image.  Additionally, this program works best
with the hand placed in a background of a very different color for best hand recognition since pixel values are used.  
The image is then made into a binary image with the the detected hand and fingers given a value of 1 (white) and everything else as 0 (black).
Matlab functions are used to fill in holes in the data and get rid of random stray pixel values.

Matlab centroid functions are used to find the center of the palm of the hand.
A large hole is made in the hand (the pixel values within a certain radius are turned from 1 to 0), leaving only the fingers and removing the palm of the hand.
New centroids in the image can be determined, made up of however many fingers are held up, as well as the wrist and possibly other additional extraneous centroids.
The extraneous centroids are determined based on how large the corresponding blob is. Too small a blob size indicates this is extraneous and not a finger.
all this information is then used to count the number of centroids that are fingers in the image.  
