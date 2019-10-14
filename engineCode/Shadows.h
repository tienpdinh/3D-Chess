#ifndef SHADOWS_H
#define SHADOWS_H

#include "Materials.h"
#include "Models.h"

//Shadow mapping functions
void initShadowMapping();
void initShadowBuffers();
void computeShadowDepthMap(glm::mat4 lightView, glm::mat4 lightProjection, std::vector<Model*> toDraw);
void computeShadowDepthMap(glm::mat4 lightView, glm::mat4 lightProjection, std::vector<Model*> toDrawShadows, float left, float right, float top, float bottom, float near, float far);
void drawGeometryShadow(int shaderProgram, Model model, Material material, glm::mat4 transform);

//Configuration values that can be set:
extern unsigned int shadowMapWidth, shadowMapHeight;

//Global values we write out:
extern unsigned int depthMapTex;

#endif //SHADOWS_H