#include "Camera.h"
#include "WindowManager.h"
#include "GPU-Includes.h"

using glm::mat4;
using glm::vec3;
using glm::vec4;

mat4 view, proj;  //Camera view and projection matrix
vec3 camPos, camDir, camUp; //Camera State
vec3 mouseDir; //Normalized direction mouse is pointing (in world space)

void updateMouseDir(){
  // convert mouse to (-1, 1) from )0, width/height)
  int mouseX, mouseY;
  SDL_GetMouseState(&mouseX, &mouseY);
  float mx = mouseX / (screenWidth  * 0.5f) - 1.0f;
  float my = mouseY / (screenHeight * 0.5f) - 1.0f;

  glm::mat4 invPV = glm::inverse(proj * view);
  glm::vec4 worldPosFar = invPV * glm::vec4(mx, -my, 1.0f, 1.0f);
  glm::vec4 worldPosNear = invPV * glm::vec4(mx, -my, 0.0f, 1.0f);
  mouseDir =  glm::normalize(glm::vec3(worldPosFar)/worldPosFar.w - glm::vec3(worldPosNear)/worldPosNear.w);
  
  /* //Is this faster or slower?
  int mouseX, mouseY;
  SDL_GetMouseState(&mouseX, &mouseY);

  vec3 rayNear = glm::unProject(vec3(mouseX,screenHeight-mouseY+1,0), view, proj, vec4(0,0,screenWidth,screenHeight));
  vec3 rayFar = glm::unProject(vec3(mouseX,screenHeight-mouseY+1,1), view, proj, vec4(0,0,screenWidth,screenHeight));

  mouseDir =  glm::normalize(rayFar - rayNear);
  */

  //printf("m - %f, %f\n", mx, my);
  //printf("m: %f %f %f\n",mouseDir.x,mouseDir.y,mouseDir.z);
}