import SimpleOpenNI.*; 

SimpleOpenNI  kinect; 
PImage img, img1, img2, img3, img4;
PImage resultImage;
int userID; 
boolean tracking = false;
PImage backgroundImage;


//on choisis 2 distance
//celle ou se termine le premier plan
float minZ = 1200;
//celle ou commence l'arriere plan
float maxZ = 1700;

void setup() {
  size(displayWidth, displayHeight); 

    backgroundImage = loadImage("tout.jpg");

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
  resultImage = new PImage(displayWidth, displayHeight, RGB);
  
  img1 = loadImage ("premierplan.png");
  img2 = loadImage ("secondplan.png");
  img3 = loadImage ("dernierplan.png");
  img4 = loadImage ("tout.jpg");
}

void draw() {
  //clears the screen with the black color, this is usually a good idea 
  //to avoid color artefacts from previous draw iterations
  background(255);

  //asks kinect to send new data
  kinect.update();

    // CONDITION - c'est ici que l'on décide de ce qui se passe aux distances choisie plus haut
    if (userDepth.z <= minZ) {//if the user is within a certain range
      fill(255, 0, 0);
      ellipse(projCoM.x, projCoM.y, 50, 50);
    resultImage.updatePixels();
    image(resultImage, 0, 0, displayWidth, displayHeight);
       //  image (img1, 0,0, width, height);
 }
    if (projCoM.z > minZ && projCoM.z < maxZ) {//if the user is within a certain range
      fill(0, 255, 0);
      ellipse(projCoM.x, projCoM.y, 50, 50);
    resultImage.updatePixels();
   // image(resultImage, 0, 0, displayWidth, displayHeight);
  image (img2, 0,0, displayWidth, displayHeight);
    }
    if (projCoM.z >= maxZ) {//if the user is within a certain range
      fill(0, 0, 255);
      ellipse(projCoM.x, projCoM.y, 50, 50);
    resultImage.updatePixels();
    image(resultImage, 0, 0, displayWidth, displayHeight);
      //    image (img3, 0,0, width, height);

    }


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

