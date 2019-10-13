#include "CollisionSystem.h"

#include "Models.h"

using std::vector;
using std::string;
using glm::vec3;


vector<int> collisionModels;
Collider colliders[MAX_LAYERS][1000];

int numColliders[MAX_LAYERS] = {0,0,0,0,0,0,0,0,0,0};
int ID_counter = 0;

int addCollider(int modelID, int layer, float r, vec3 offset){
  //printf("Added Collider for Model %d to layer %d\n",modelID,layer);
  Collider c = Collider();
  c.offset = offset;
  c.r = r;
  c.layer = layer;
  c.modelID = modelID;
  c.ID = ID_counter++; //A universal unique ID
  glm::vec4 pos = models[modelID].transform*glm::vec4(offset,1); //TODO: This should be the global transform!! (current it's just relative to parent)
  c.globalPos = glm::vec3(pos[0],pos[1],pos[2])/pos[3];
  colliders[layer][numColliders[layer]] = c; //Add to list of models with colliders
  collisionModels.push_back(modelID); //Add this model list of models with colliders //TODO: Only add to collision models if it's not there already (e.g., two colliders per model)
  models[modelID].collider = &colliders[layer][numColliders[layer]];
  numColliders[layer]++;
  return c.ID;
}

void updateColliderPositions(){ 
  for (size_t i = 0; i < collisionModels.size(); i++){
    //printf("Collider: %d Model %d, %s\n",i,collisionModels[i],models[collisionModels[i]].name.c_str());
    Model* m = &models[collisionModels[i]];
    glm::vec4 pos = m->transform*glm::vec4(m->collider->offset,1); //TODO: This should be the global transform!! (current it's just relative to parent)
    m->collider->globalPos = glm::vec3(pos[0],pos[1],pos[2])/pos[3];
    //printf("  is now at pos: %f %f %f\n",pos[0],pos[1],pos[2]);
  }
}

//dir must be normalized!
int getCollisionRay(vec3 pos, vec3 dir, float& maxDist, int layer){
  //printf("Checking for collisions at layer %d\n",layer);
  int hitID = -1;

  for (int i = 0; i < numColliders[layer]; i++){
    vec3 fromObj = (pos-colliders[layer][i].globalPos);
    float b = 2*glm::dot(dir,fromObj);
    float c = glm::dot(fromObj,fromObj) - colliders[layer][i].r*colliders[layer][i].r;
    float disc = b*b - 4*c;
    //printf("pos: %f %f %f\n",colliders[layer][i].globalPos.x,colliders[layer][i].globalPos.y,colliders[layer][i].globalPos.z);
    if (disc < 0) continue; //the ray misses this sphere
    float t = (-b - sqrt(disc))/2; //@HW, why skip the + disc case?
    //printf("t: %f\n",t);
    if (t < 0) continue;
    if (t < maxDist){
      //printf("Dir: %f %f %f\n",dir.x,dir.y,dir.z);
      vec3 hitPoint = pos+t*dir;
      //printf("Hit pos: %f %f %f\n",hitPoint.x,hitPoint.y,hitPoint.z);
      vec3 ctoh = hitPoint - colliders[layer][i].globalPos;
      //printf("Offset: %f %f %f : %f\n",ctoh.x,ctoh.y,ctoh.z, sqrt(glm::dot(ctoh,ctoh)));
      maxDist = t;
      hitID = colliders[layer][i].modelID;
    }
  }
  return hitID;
}

int getCollision(float x, float y, float z, float rad, int layer){
  //printf("Checking for collisions at layer %d\n",layer);
  for (int i = 0; i < numColliders[layer]; i++){
    //printf("Dist to %dth model of %d in layer %d\n",i,numColliders[layer],layer);
    vec3 p2 = colliders[layer][i].globalPos;
    float r = rad + colliders[layer][i].r;
    float rsq = r*r;
    vec3 diff(x - p2[0], y - p2[1], z - p2[2]);
    float distSqr = diff[0]*diff[0] + diff[1]*diff[1] + diff[2]*diff[2];
    //printf("Dist: %f <? %f \n",sqrt(distSqr), rad + colliders[layer][i].r);
    //printf("Dist2: %f <? %f \n", distSqr, rsq);

    //printf("My pos: %f %f %f\n",x,y,z);
    //printf("Hit pos: %f %f %f\n",p2[0],p2[1],p2[2]);

    if (distSqr < rsq){
      return colliders[layer][i].modelID;
    }
  }
  return -1;
}

int getCollision(Collider* collider, int layer){
  //printf("Checking for collisions at layer %d\n",layer);
  vec3 p1 = collider->globalPos; 
  float r1 = collider->r;
  for (int i = 0; i < numColliders[layer]; i++){
    //printf("Dist to %dth model of %d in layer %d\n",i,numColliders[layer],layer);
    if (collider == &colliders[layer][i]) continue; 
    vec3 p2 = colliders[layer][i].globalPos;
    float r = r1 + colliders[layer][i].r;
    float rsq = r*r;
    vec3 diff = p1-p2;
    float distSqr = diff[0]*diff[0] + diff[1]*diff[1] + diff[2]*diff[2];
    //printf("Dist: %f <? %f \n",sqrt(distSqr), collider->r + colliders[layer][i].r);
    //printf("Dist2: %f <? %f \n", distSqr, rsq);

    //printf("My pos: %f %f %f\n",p1[0],p1[1],p1[2]);
    //printf("Hit pos: %f %f %f\n",p2[0],p2[1],p2[2]);

    if (distSqr < rsq){
      return colliders[layer][i].modelID;
    }
  }
  return -1;
}