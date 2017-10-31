/*
Test FullScreen sans lib
https://github.com/processing/processing/wiki/Window-Size-and-Full-Screen-for-Processing-2.0

*/


//import processing.opengl.*;
import SimpleOpenNI.*;


SimpleOpenNI kinect;

boolean tracking = false;
int userID; 
int[] userMap;

// Déclare l'image
PImage backgroundImage;
PImage resultImage;

void setup() {
  println ("setup");

  size(displayWidth, displayHeight);
//  frameRate(30);

  // Charge l'image de fond
  backgroundImage = loadImage("test1.jpg");
  
  
  kinect = new SimpleOpenNI(this);
  if (kinect.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!");
    exit();
    return;
  }

  // enable depthMap generation
  kinect.enableDepth();

  // enable skeleton generation for all joints
  kinect.enableUser();
  // enable color image from the Kinect
  kinect.enableRGB();
  //enable the finding of users but dont' worry about skeletons

  // turn on depth/color alignment
  kinect.alternativeViewPointDepthToImage();
  
  //create a buffer image to work with instead of using sketch pixels
  resultImage = new PImage(640, 480, RGB);
}
void draw() {

  kinect.update();
  // prend la couleur de l'image
  PImage rgbImage = kinect.rgbImage();

  image(rgbImage, 0, 0, displayWidth, displayHeight);
  if (tracking) {
    //Prend les pixel de l'utilisateur
    loadPixels();
    userMap = kinect.userMap();
    for (int i =0; i < userMap.length; i++) {
      // Si le pixel fait partie de l'utilisateur
      if (userMap[i] != 0) {
        // Place la couleur sur les pixels
        resultImage.pixels[i] = rgbImage.pixels[i];
      } else {
        //Place les pixels sur le fond
        resultImage.pixels[i] = backgroundImage.pixels[i];
      }
    }

    // Met a jour les pixels de l'image
    resultImage.updatePixels();
    image(resultImage, 0, 0, displayWidth, displayHeight);
  }
}

boolean sketchFullScreen() {
  return true;
}


void onNewUser(SimpleOpenNI curContext, int userId)
{
  userID = userId;
  tracking = true;
  println("tracking");
  //curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

