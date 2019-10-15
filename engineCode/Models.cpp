#include "Models.h"

#include "GPU-Includes.h"

#define TINYOBJLOADER_IMPLEMENTATION  // Define this in only *one* .cc

#include <external/loguru.hpp>
#include <external/tiny_obj_loader.h>
#include <fstream>

using std::copy;
using std::ifstream;
using std::string;

int numModels = 0;
Model models[10000];

std::string err;
std::string warn;

void resetModels()
{
    // TODO: It is probably best practices to unload the old models from where they are on the GPU
    // TODO: It is best practices to delete the old models explicitly
    numModels = 0;
}

void loadAllModelsTo1VBO(GLuint vbo)
{
    // Set vbo i as the active array buffer (Only one buffer can be active at a time).
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	int vextexCount = 0;
	for (int i = 0; i < numModels; i++)
    {
		models[i].startVertex = vextexCount;
		vextexCount += models[i].numVerts;
	}
	int totalVertexCount = vextexCount;

	float* allModelData = new float[vextexCount*VERTEX_STRIDE];
	copy(models[0].modelData, models[0].modelData + models[0].numVerts*VERTEX_STRIDE, allModelData);
	for (int i = 0; i < numModels; i++)
    {
		copy(models[i].modelData, models[i].modelData + models[i].numVerts*VERTEX_STRIDE, allModelData + models[i].startVertex*VERTEX_STRIDE);
	}

    // Upload model data to the VBO.
	glBufferData(GL_ARRAY_BUFFER, totalVertexCount*VERTEX_STRIDE*sizeof(float), allModelData, GL_STATIC_DRAW);
}

int addModel(string modelName)
{
	int curModelID = numModels;
	numModels++;
	models[curModelID] = Model();  // Create new model with default values.
	models[curModelID].ID = curModelID;
	models[curModelID].name = modelName;
	return curModelID;
}

void addChild(string childName, int curModelID)
{
	int childModel = -1;
	for (int i = 0; i < numModels; i++)
    {
		if (models[i].name == childName)
        {
			childModel = i;
			continue;
		}
	}

    CHECK_F(childModel >= 0,"No model of name '%s' found to be added as a child model!", childName.c_str());

	LOG_F(1,"Adding child %s",childName.c_str());
	models[curModelID].childModel.push_back(&models[childModel]);
	models[curModelID].numChildren++;

	glm::vec3 scaleFactor = glm::vec3(models[childModel].transform*glm::vec4(1,1,1,0));
	float radiusScale = fmaxf(scaleFactor.x,fmaxf(scaleFactor.y,scaleFactor.z)); //TODO: This won't work with relections (ie negative scales)
	float childRadius = radiusScale*models[childModel].boundingRadius;
	models[curModelID].boundingRadius = fmaxf(childRadius,models[curModelID].boundingRadius);
}

void addLODChild(string childName, int curModelID)
{
	int childModel = -1;
	for (int i = 0; i < numModels; i++)
    {
		if (models[i].name == childName)
        {
			childModel = i;
			continue;
		}
	}
	CHECK_F(childModel >= 0,"No model of name '%s' found to be added as a child model!",childName.c_str());

	LOG_F(1,"Adding LOD child %s",childName.c_str());
	models[curModelID].lodChild = &models[childModel];
}

void computeBoundingRadius(int modelID)
{
	LOG_SCOPE_FUNCTION(INFO);
	float rx, ry, rz;
	float x,y,z;
	for (int v = 0; v < models[modelID].numVerts; v++)
    {
		x = fabsf(models[modelID].modelData[VERTEX_STRIDE*v + 0]);
		y = fabsf(models[modelID].modelData[VERTEX_STRIDE*v + 1]);
		z = fabsf(models[modelID].modelData[VERTEX_STRIDE*v + 2]);
		if (x > rx) rx = x;
		if (y > ry) ry = y;
		if (z > rz) rz = z;
	}
	float r = sqrt(rx*rx+ry*ry+rz*rz);
	float childRadius;
	for (int c = 0; c < models[modelID].numChildren; c++)
    {
		glm::vec3 scaleFactor = glm::vec3(models[c].transform*glm::vec4(1,1,1,0));
		float radiusScale = fmaxf(scaleFactor.x,fmaxf(scaleFactor.y,scaleFactor.z)); //TODO: This won't work with relections (ie negative scales)
		childRadius = radiusScale*models[modelID].childModel[c]->boundingRadius;
		LOG_F(2, "Child model %s bounding radius is %f (scale factor = %f)",models[modelID].childModel[c]->name.c_str(), childRadius, radiusScale);
		if (childRadius > r) r = childRadius;
	}
	models[modelID].boundingRadius = r;
	LOG_F(INFO, "Model %s bounding radius is %f ",models[modelID].name.c_str(), models[modelID].boundingRadius);
}

void loadModel(string fileName)
{
	LOG_SCOPE_FUNCTION(INFO);

    FILE *fp;
    long length;
    char rawline[1024];  // Assumes no line is longer than 1024 characters!

    // Open the file containing the scene description.
    fp = fopen(fileName.c_str(), "r");

	LOG_F(INFO,"Loading Model File: %s", fileName.c_str());

    // Check for errors in opening the file.
	CHECK_NOTNULL_F(fp,"Can't open model file '%s'", fileName.c_str());

    fseek(fp, 0, SEEK_END);  // Move position indicator to the end of the file.
    length = ftell(fp);  // Return the value of the current position.
    LOG_F(INFO,"File '%s' is %ld bytes long.",fileName.c_str(),length);
    fseek(fp, 0, SEEK_SET);  // Move position indicator to the start of the file.

	string modelName = "";
	string modelDir = "./";
	int curModelID = 0;

    // Loop through reading each line.
    while( fgets(rawline,1024,fp) )
    {
        // Assumes no line is longer than 1024 characters!
	    string line = string(rawline);
        if (rawline[0] == '#')
        {
            LOG_F(2,"Skipping comment: %s", rawline);
            continue;
        }

        char command[100];
        int fieldsRead = sscanf(rawline,"%s ",command);  // Read first word in the line (i.e., the command type).
        string commandStr = command;

        if (fieldsRead < 1)
        {
            // No command read = Blank line
            continue;
        }

        if (commandStr.substr(0,1) == "[")
        {
            // "[" indicates new model
		    int closeBrackets = line.find("]");
			CHECK_F(closeBrackets >= 0,"ERROR: Model name opened with [ but not closed with ]");
            modelName = line.substr(1,closeBrackets-1);
			curModelID = addModel(modelName);
			LOG_F(INFO,"Creating PreFab Model with name: %s",modelName.c_str());
        }
		else if (commandStr == "identity")
        {
			models[curModelID].transform = glm::mat4();
            LOG_F(1,"Reseting to Indentity Transform");
        }
        else if (commandStr == "scale")
        {
			float scaleFactor;
			sscanf(rawline,"scale %f", &scaleFactor);
			models[curModelID].transform = glm::scale(models[curModelID].transform, scaleFactor*glm::vec3(1,1,1));
            LOG_F(1,"Scaling by %f",scaleFactor);
        }
		else if (commandStr == "scalexyz")
        {
			// Compute new glm matrix.
			float sx, sy, sz;
			sscanf(rawline,"scalexyz %f %f %f", &sx, &sy, &sz);
			models[curModelID].transform = glm::scale(models[curModelID].transform, glm::vec3(sx,sy,sz));
            LOG_F(1,"Scaling by %f %f %f",sx,sy,sz);
        }
		else if (commandStr == "rotate")
        {
			// Compute new glm matrix.
			float angle, rx, ry, rz;
			sscanf(rawline,"rotate %f %f %f %f", &angle, &rx, &ry, &rz);
			models[curModelID].transform = glm::rotate(models[curModelID].transform, (float)(angle*(M_PI/180.f)), glm::vec3(rx,ry,rz));
            LOG_F(1,"Rotating by %f around axis %f %f %f",angle,rx,ry,rz);
        }
		else if (commandStr == "translate")
        {
			// Compute new glm matrix.
			float tx, ty, tz;
			sscanf(rawline,"translate %f %f %f", &tx, &ty, &tz);
			models[curModelID].transform = glm::translate(models[curModelID].transform, glm::vec3(tx,ty,tz));
            LOG_F(1,"Transling by (%f, %f, %f)", tx, ty, tz);
        }
		else if (commandStr == "textureWrap")
        {
			float uScale, vScale;
			sscanf(rawline,"textureWrap %f %f", &uScale, &vScale);
			models[curModelID].textureWrap = glm::vec2(uScale,vScale);
            LOG_F(1,"Wrapping texture by %fX in u and %fX in v", uScale, vScale);
        }
		else if (commandStr == "radius")
        {
			float radius;
			sscanf(rawline,"radius = %f", &radius);
			models[curModelID].boundingRadius = radius;
            LOG_F(1,"Setting model bounding radius to %f",radius);
        }
		else if (commandStr == "lodDist")
        {
			float lodDist;
			sscanf(rawline,"lodDist = %f", &lodDist);
			models[curModelID].lodDist = lodDist;
            LOG_F(1,"Setting LOD cutoff distance to %f",lodDist);
        }
		else if (commandStr == "modelDir")
        {
            char dirName[1024];
            sscanf(rawline,"modelDir = %s", dirName);
			modelDir = dirName;
			LOG_F(1,"Setting model directory to: %s",modelDir.c_str());
		}
		else if (commandStr == "flatModel")
        {
            /*
            NOTE:
            flat models files must declare the attributes related to the VERTEX_STRIDE.
            */
            char flatDataFile[1024];
            sscanf(rawline,"flatModel = %s", flatDataFile);

			ifstream modelFile;
			LOG_F(1,"Loading flat model file %s as ID: %d",(modelDir + flatDataFile).c_str(),curModelID);
			modelFile.open(modelDir + flatDataFile);
            CHECK_F(!modelFile.fail(),"Failed to open flatmodel: %s",(modelDir + flatDataFile).c_str());
			int numLines = 0;
			modelFile >> numLines;
			models[curModelID].modelData = new float[numLines];
			for (int i = 0; i < numLines; i++)
            {
				modelFile >> models[curModelID].modelData[i];
				// if (i%8 == 3 || i%8 == 4) models[curModelID].modelData[i] *= 2;  // Texture wrap factor.
			}
			LOG_F(1,"Loaded %d lines",numLines);
			models[curModelID].numVerts = numLines/VERTEX_STRIDE;
			modelFile.close();
			computeBoundingRadius(curModelID);
        }
		else if (commandStr == "objModel")
        {
            char objFile[1024];
            sscanf(rawline,"objModel = %s", objFile);

			LOG_F(1,"Loading obj model %s starting at ID: %d",(modelDir + objFile).c_str(),curModelID);
			tinyobj::attrib_t objAttrib;
			std::vector<tinyobj::shape_t> objShapes;
			std::vector<tinyobj::material_t> objMaterials;
			bool ret = tinyobj::LoadObj(&objAttrib, &objShapes, &objMaterials, &warn, &err, (modelDir + objFile).c_str(),modelDir.c_str());

			LOG_IF_F(WARNING,!warn.empty(),"Obj Loading Warning: %s", warn.c_str());
			LOG_IF_F(WARNING,!err.empty(),"Obj Loading ERROR: %s", err.c_str());
			CHECK_F(ret,"CRITICAL MODEL LOADING ERROR!");

			for (size_t i = 0; i < objMaterials.size(); i++)
            {
				Material m;
				m.name = objFile+string("-")+objMaterials[i].name;
				memcpy((void*)& m.col, (void*)& objMaterials[i].diffuse[0], sizeof(float)*3);  // Copy all 3 colors (RGB).
				m.ior = objMaterials[i].ior;
				m.roughness = 1/(1+0.01*objMaterials[i].shininess);
				m.metallic = objMaterials[i].metallic;
				float avgSpec = (objMaterials[i].specular[0]+objMaterials[i].specular[1]+objMaterials[i].specular[2])/3.0;
				if (avgSpec > 0.8) m.reflectiveness = (avgSpec-0.8)/0.2;
				memcpy((void*)& m.emissive, (void*)& objMaterials[i].emission[0], sizeof(float)*3);  // Copy all 3 emissive colors (RGB).

				if (objMaterials[i].diffuse_texname != "")
                {
					string textureName = modelDir + objMaterials[i].diffuse_texname;
					int foundTexture = -1;
					for (int i = 0; i < numTextures; i++){
						if (textures[i] == textureName){
							foundTexture = i;
							break;
						}
					}
					if (foundTexture >= 0){
						LOG_F(1,"Reusing existing texture: %s", textures[foundTexture].c_str());
						m.textureID = foundTexture;
					}
					else{
						textures[numTextures] = textureName;
						m.textureID = numTextures;
						numTextures++;
						LOG_F(1,"New texture named: %s", textureName.c_str());
					}
				}

                if (objMaterials[i].bump_texname != "")
                {
                    string textureName = modelDir + objMaterials[i].bump_texname;
					int foundTexture = -1;
					for (int i = 0; i < numTextures; i++){
						if (textures[i] == textureName){
							foundTexture = i;
							break;
						}
					}
					if (foundTexture >= 0){
						LOG_F(1,"Reusing existing texture: %s", textures[foundTexture].c_str());
						m.normalMapId = foundTexture;
					}
					else{
						textures[numTextures] = textureName;
						m.normalMapId = numTextures;
						numTextures++;
						LOG_F(1,"New normal map texture named: %s", textureName.c_str());
					}
                }

				materials[numMaterials] = m;
				LOG_F(1,"Creating Material ID %d with name '%s'",numMaterials,materials[numMaterials].name.c_str());
				numMaterials++;
			}

			int objChild = 0;
			string childName = objFile+string("-Child-")+std::to_string(objChild);
			int childModelID = addModel(childName);  // Add Childs.
			LOG_F(1,"Loading obj child model %s as IDs: %d", (childName).c_str(),childModelID);

			std::vector<float> vertexData;

			// Loop over shapes.
			// TODO: The first object may have 0 verticies, we should fix this.
			for (size_t s = 0; s < objShapes.size(); s++)
            {
				int curMaterialID = -1;
				int lastMaterialID = -1;
				if (objMaterials.size() > 0 && objShapes[s].mesh.material_ids.size() > 0)
                {
					curMaterialID = lastMaterialID = objShapes[s].mesh.material_ids[0];
					// if (curMaterialID == -1) curMaterialID = 0;

					string materialName = objFile+string("-")+objMaterials[curMaterialID].name;
					int materialID = -1;
					if (models[curModelID].materialID == -1)
                    {
                        // Only use obj materials if the parent doesn't have it's own material.
                        materialID = findMaterial(materialName.c_str());
                    }
					LOG_F(1,"Binding material: '%s' (Material ID %d) to Model %d",materialName.c_str(),materialID,childModelID);
					models[childModelID].materialID = materialID;
				}
				// Loop over faces(polygon).
				size_t index_offset = 0;
				for (size_t f = 0; f < objShapes[s].mesh.num_face_vertices.size(); f++)
                {
					size_t fv = objShapes[s].mesh.num_face_vertices[f];
					assert(fv == 3);  // tinyobj loader triangulates all faces by default.

					lastMaterialID = curMaterialID;
					curMaterialID = objShapes[s].mesh.material_ids[f];

					if (f == 0 || curMaterialID != lastMaterialID)
                    {
						LOG_F(3,"CurMat: %d, LastMat: %d",curMaterialID,lastMaterialID);

						// Copy vertex data read so far into the model.
						int numAttribs = vertexData.size();
						models[childModelID].modelData = new float[numAttribs];
						std::copy(vertexData.begin(),vertexData.end(),models[childModelID].modelData);
						models[childModelID].numVerts = numAttribs/VERTEX_STRIDE;
						LOG_F(1,"Loaded %d vertices",models[childModelID].numVerts);
						addChild(childName, curModelID);

						/// Start a new model for the next set of textures.
						objChild++;
						childName = objFile+string("-Child-")+std::to_string(objChild);
						LOG_F(1,"Loading obj child model %s as IDs: %d", (childName).c_str(),childModelID);
						childModelID = addModel(childName);
						vertexData.clear();

						// Bind the new material.
						int materialID = -1;
						if (curMaterialID >= 0)
                        {
							string materialName = objFile+string("-")+objMaterials[curMaterialID].name;
							if (models[curModelID].materialID == -1) //Only use obj materials if the parent doesn't have it's own material
								materialID = findMaterial(materialName.c_str());
							LOG_F(1,"Binding material: '%s' (Material ID %d) to Model %d",materialName.c_str(),materialID,curModelID);
						}
						models[childModelID].materialID = materialID;
					}

                    glm::vec3 trianglePos[3];
                    glm::vec2 triangleTexcoords[3];
                    glm::vec3 triangleNormals[3];
                    glm::vec3 triangleTangents[3];

                    bool triangleHasNormals = true;

                    // Fill the triangle positions, texture coordinates, and normals (if present).
                    for (size_t v = 0; v < fv; v++)
                    {
                        tinyobj::index_t idx = objShapes[s].mesh.indices[index_offset+v];

                        // Positions.
                        tinyobj::real_t vx = objAttrib.vertices[3*idx.vertex_index+0];
						tinyobj::real_t vy = objAttrib.vertices[3*idx.vertex_index+1];
						tinyobj::real_t vz = objAttrib.vertices[3*idx.vertex_index+2];
                        trianglePos[v] = glm::vec3(vx, vy, vz);

                        // Texture Coordinates.
                        tinyobj::real_t tx = -1;
                        tinyobj::real_t ty = -1;
                        if (objAttrib.texcoords.size() > 0 && idx.texcoord_index > 0)
                        {
                            tx = objAttrib.texcoords[2*idx.texcoord_index+0];
                            ty = objAttrib.texcoords[2*idx.texcoord_index+1];
                        }
                        triangleTexcoords[v] = glm::vec2(tx, ty);
                        // TODO: What to do if there is no texture coordinates?

                        // Normals.
                        bool vertexHasNormal = (objAttrib.normals.size() > 0 && idx.normal_index >= 0);
                        triangleHasNormals &= vertexHasNormal;
                        if (vertexHasNormal)
                        {
                            tinyobj::real_t nx = objAttrib.normals[3*idx.normal_index+0];
                            tinyobj::real_t ny = objAttrib.normals[3*idx.normal_index+1];
                            tinyobj::real_t nz = objAttrib.normals[3*idx.normal_index+2];
                            triangleNormals[v] = glm::normalize(glm::vec3(nx, ny, nz));
                        }
                    }

                    // If normals are not present, recalculate them.
                    if (!triangleHasNormals)
                    {
                        glm::vec3 u = trianglePos[1] - trianglePos[0];
                        glm::vec3 v = trianglePos[2] - trianglePos[0];
                        glm::vec3 n = glm::normalize(glm::cross(u, v));

                        triangleNormals[0] = n;
                        triangleNormals[1] = n;
                        triangleNormals[2] = n;
                    }

                    // Calculate tangent vectors.
                    triangleTangents[0] = glm::vec3(0,0,0);
                    triangleTangents[1] = glm::vec3(0,0,0);
                    triangleTangents[2] = glm::vec3(0,0,0);

                    // Upload triangle to modelData.
                    for (size_t v = 0; v < fv; v++)
                    {
                        float vertex[VERTEX_STRIDE];

                        vertex[0] = trianglePos[v].x;
                        vertex[1] = trianglePos[v].y;
                        vertex[2] = trianglePos[v].z;

                        vertex[3] = triangleTexcoords[v].x;
                        vertex[4] = triangleTexcoords[v].y;

                        vertex[5] = triangleNormals[v].x;
                        vertex[6] = triangleNormals[v].y;
                        vertex[7] = triangleNormals[v].z;

                        vertex[8] = triangleTangents[v].x;
                        vertex[9] = triangleTangents[v].y;
                        vertex[10] = triangleTangents[v].z;

                        vertexData.insert(vertexData.end(),vertex,vertex+VERTEX_STRIDE);  // Maybe should be vertexData.insert(vertex.end(),std::begin(vertex),std::end(vertex+)) ie make vertex a vector.
                    }

					// Loop over vertices in the face.
                    /*
					for (size_t v = 0; v < fv; v++)
                    {
						// Access to vertex.
						tinyobj::index_t idx = objShapes[s].mesh.indices[index_offset + v];
						tinyobj::real_t vx = objAttrib.vertices[3*idx.vertex_index+0];
						tinyobj::real_t vy = objAttrib.vertices[3*idx.vertex_index+1];
						tinyobj::real_t vz = objAttrib.vertices[3*idx.vertex_index+2];

                        tinyobj::real_t tx=-1,ty=-1;  // TODO: Ohh, what do if there is no texture coordinates?
                        if (objAttrib.texcoords.size() > 0 && idx.texcoord_index > 0)
                        {
                            tx = objAttrib.texcoords[2*idx.texcoord_index+0];
                            ty = objAttrib.texcoords[2*idx.texcoord_index+1];
                        }

						// CHECK_F(objAttrib.normals.size() > 0 && idx.normal_index >=0, "All objects need normals to load");
                        tinyobj::real_t nx;
                        tinyobj::real_t ny;
                        tinyobj::real_t nz;

                        // If obj model has normals, then use them.
                        if (objAttrib.normals.size() > 0 && idx.normal_index >= 0)
                        {
                            nx = objAttrib.normals[3*idx.normal_index+0];
    						ny = objAttrib.normals[3*idx.normal_index+1];
    						nz = objAttrib.normals[3*idx.normal_index+2];
                        }
                        // Otherwise calculate the normals.
                        else
                        {
                            // U = p2-p1
                            // V = p3-p1
                            // N = UxV

                            // LOG_F(1,"Calculating normals for model %s [%d]", models[curModelID].name.c_str(), curModelID);

                            tinyobj::index_t idx2 = objShapes[s].mesh.indices[index_offset + 0];
                            tinyobj::real_t p0x = objAttrib.vertices[3*idx2.vertex_index+0];
                            tinyobj::real_t p0y = objAttrib.vertices[3*idx2.vertex_index+1];
                            tinyobj::real_t p0z = objAttrib.vertices[3*idx2.vertex_index+2];

                            idx2 = objShapes[s].mesh.indices[index_offset + 1];
                            tinyobj::real_t p1x = objAttrib.vertices[3*idx2.vertex_index+0];
                            tinyobj::real_t p1y = objAttrib.vertices[3*idx2.vertex_index+1];
                            tinyobj::real_t p1z = objAttrib.vertices[3*idx2.vertex_index+2];

                            idx2 = objShapes[s].mesh.indices[index_offset + 2];
                            tinyobj::real_t p2x = objAttrib.vertices[3*idx2.vertex_index+0];
                            tinyobj::real_t p2y = objAttrib.vertices[3*idx2.vertex_index+1];
                            tinyobj::real_t p2z = objAttrib.vertices[3*idx2.vertex_index+2];

                            float ux = p1x-p0x;
                            float uy = p1y-p0y;
                            float uz = p1z-p0z;

                            float vx = p2x-p0x;
                            float vy = p2y-p0y;
                            float vz = p2z-p0z;

                            glm::vec3 normalVec = glm::normalize(glm::cross(glm::vec3(ux, uy, uz), glm::vec3(vx, vy, vz)));

                            nx = normalVec.x;
                            ny = normalVec.y;
                            nz = normalVec.z;
                        }

                        float tnx = 0.0;
                        float tny = 0.0;
                        float tnz = 1.0;

						float vertex[VERTEX_STRIDE] = {vx,vy,vz,tx,ty,nx,ny,nz, tnx, tny, tnz};
						vertexData.insert(vertexData.end(),vertex,vertex+VERTEX_STRIDE);  // Maybe should be vertexData.insert(vertex.end(),std::begin(vertex),std::end(vertex+)) ie make vertex a vector.

                        // Optional: vertex colors.
						// tinyobj::real_t red = objAttrib.colors[3*idx.vertex_index+0];
						// tinyobj::real_t green = objAttrib.colors[3*idx.vertex_index+1];
						// tinyobj::real_t blue = objAttrib.colors[3*idx.vertex_index+2];
					}
                    */

					index_offset += fv;

					// Per-face material.
					objShapes[s].mesh.material_ids[f];
				}
			}

			// Copy vertex data read so far into the model.
			int numAttribs = vertexData.size();
			models[childModelID].modelData = new float[numAttribs];
			std::copy(vertexData.begin(),vertexData.end(),models[childModelID].modelData);
			models[childModelID].numVerts = numAttribs/VERTEX_STRIDE;
			LOG_F(1,"Loaded %d vertices",models[childModelID].numVerts);
			computeBoundingRadius(childModelID);
			addChild(childName, curModelID);
        }
	    else if (commandStr == "child")
        {
			int openBracket = line.find("[")+1;
		    int modelNameLength = line.find("]")-openBracket;
			string childName = line.substr(openBracket,modelNameLength);
			LOG_F(1,"Adding Child with name %s to model %d",childName.c_str(), curModelID);
			addChild(childName, curModelID);
        }
		else if (commandStr == "lodChild")
        {
			int openBracket = line.find("[")+1;
		    int modelNameLength = line.find("]")-openBracket;
			string childName = line.substr(openBracket,modelNameLength);
			LOG_F(1,"Adding LOD Child with name %s to model %d",childName.c_str(), curModelID);
			addLODChild(childName, curModelID);
        }
		else if (commandStr == "material")
        {
			int openBracket = line.find("[")+1;
		    int modelNameLength = line.find("]")-openBracket;
			string materialName = line.substr(openBracket,modelNameLength);
			int materialID = findMaterial(materialName);
			LOG_F(1,"Binding material: '%s' (Material ID %d) to Model %d",materialName.c_str(),materialID,curModelID);
			models[curModelID].materialID = materialID;
        }
		else if (commandStr == "modelColor")
        {
			float r, g, b;
			sscanf(rawline,"modelColor = %f %f %f", &r, &g, &b);
			models[curModelID].modelColor = glm::vec3(r,g,b);
            LOG_F(1,"Setting model base color to %f %f %f",r,g,b);
        }
        else
        {
            LOG_F(WARNING,"WARNING. Unknown model command: %s",commandStr.c_str());
        }
    }
}
