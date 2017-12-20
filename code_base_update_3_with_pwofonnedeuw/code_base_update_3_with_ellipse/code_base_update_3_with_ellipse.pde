/*
?
 Résolution image test1.jpg 640x480 pas plus ?
 
 */


//import processing.opengl.*;
import SimpleOpenNI.*;


SimpleOpenNI kinect;

boolean tracking = false;
int userID; 
int[] userMap;

// Déclare l'image
PImage logo;
PImage backgroundImage;
PImage resultImage;
PImage rgbImage;
PImage depthImage;

PImage plan1, plan2, plan3; 
// plan1 : avant plan
// plan2 : milieu
// plan3 : arrière

// DISTANCE Z detection
float minZ = 1200;
float maxZ = 1700; //celle ou commence l'arriere plan

void setup() {
  //size(displayWidth, displayHeight);
  logo = loadImage("data/logo.png");
  size(640, 480);
  smooth();
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
  
  // A la fin charge image sinon crash 
  
  // Charge l'image de fond
  backgroundImage = loadImage("test1.jpg");
  // ?????? Encore utilisée ? background
  
  plan1 = loadImage("premierplan.png");
  plan2 = loadImage("secondplan.png");
  plan3 = loadImage("dernierplan.png"); 
  
}


void draw() {

  kinect.update();

  // SAUVEGARDE image RGB de la kinect
  rgbImage = kinect.rgbImage();
  // ? peut déplacer dans tracking ?


  //image(rgbImage, 0, 0, displayWidth, displayHeight);

  // UTILISATEUR(s) DETECTE(s)
  if (tracking) {
    //Prend les pixel de l'utilisateur
    loadPixels();
    userMap = kinect.userMap();

    //retrieves depth image
    depthImage = kinect.depthImage();
    depthImage.loadPixels();

    //get array of IDs of all users present 
    int[] users= kinect.getUsers();

    // TEMP TEMP TEMP Affichage image pour voir cercles 
    image(depthImage, 0, 0, 640, 480);

    //iterate through users
    for (int i=0; i < users.length; i++) {
      int uid=users[i];

      //draw center of mass of the user (simple mean across position of all user pixels that corresponds to the given user)
      PVector realCoM=new PVector();

      //get the CoM in realworld (3D) coordinates
      kinect.getCoM(uid, realCoM);
      PVector projCoM=new PVector();

      //convert realworld coordinates to projective (those that we can use to draw to our canvas)
      kinect.convertRealWorldToProjective(realCoM, projCoM);
      fill(255, 0, 0);
      ellipse(projCoM.x, projCoM.y, 10, 10);
      personne();

      image(plan3, 0, 0, 640, 480);
      if (projCoM.z > maxZ) {//if the user is within a certain range
        fill(0, 0, 255);
        ellipse(projCoM.x, projCoM.y, 50, 50);
        personne();
      }
      
      image(plan2, 0, 0, 640, 480);
      
      
      if (projCoM.z > minZ && projCoM.z < maxZ) {//if the user is within a certain range
        fill(0, 255, 0);
        ellipse(projCoM.x, projCoM.y, 50, 50);
        personne();
      }
       image(plan1, 0, 0, 640, 480);
      
      
     
     // CONDITION - c'est ici que l'on décide de ce qui se passe aux distances choisie plus haut
      if (projCoM.z < minZ) {//if the user is within a certain range
        fill(255, 0, 0);
        ellipse(projCoM.x, projCoM.y, 50, 50);
      }
      
    }


    /*
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
     */
    // Met a jour les pixels de l'image
    //resultImage.updatePixels();
    //image(resultImage, 0, 0, displayWidth, displayHeight);

  }
}


void personne() {
  
  kinect.update();
  // prend la couleur de l'image
  PImage rgbImage = kinect.rgbImage();
 
  image(rgbImage, 640, 0);
  if (tracking) {
    //Prend les pixel de l'utilisateur
    loadPixels();
    userMap = kinect.userMap();
    for (int i =0; i < userMap.length; i++) {
      // Si le pixel fait partie de l'utilisateur
      if (userMap[i] != 0) {
        // Place la couleur sur les pixels
        resultImage.pixels[i] = rgbImage.pixels[i];
      }
      else {
        //Place les pixels sur le fond
        resultImage.pixels[i] = backgroundImage.pixels[i];
      }
    }
 
    // Met a jour les pixels de l'image
     resultImage.updatePixels();
   image(resultImage, 0, 0);
    image(logo,1180,680);
  }
}
 


boolean sketchFullScreen() {
  return false;
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

