// Stephen J. Guy
// sjguy@umn.edu

// ImGui includes.
#include "imgui/imgui.h"
#include "imgui/imgui_impl_sdl.h"
#include "imgui/imgui_impl_opengl3.h"

// Stb_image includes.
#ifndef STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION  // Put this line in only one .cpp file.
#endif  // STB_IMAGE_IMPLEMENTATION
#include <external/stb_image.h>

// Loguru includes.
#include <external/loguru.hpp>

#include "Bloom.h"
#include "Camera.h"
#include "CollisionSystem.h"
#include "Controller.h"
#include "GPU-Includes.h"
#include "Keyboard.h"
#include "LuaSupport.h"
#include "Materials.h"
#include "Models.h"
#include "RenderingSystem.h"
#include "Scene.h"
#include "Shader.h"
#include "Shadows.h"
#include "Skybox.h"
#include "Sound.h"
#include "WindowManager.h"

#include <cstdio>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;
using std::swap;  // For fast delete.
using glm::vec3;
using glm::mat4;

// Preset file paths.
const string materialsFile = "materials.txt";
const string modelFile = "Prefabs.txt";
const string sceneFile = "Scene.txt";

// Configuration variables.
float cameraFar = 20;
float cameraNear = 0.1;

bool shadowFrustumCull = true;
bool viewFrustumCull = true;

bool drawColliders = false;
bool saveOutput = false;

int targetFrameRate = 30;
float secondsPerFrame = 1.0f / (float)targetFrameRate;

bool fullscreen = false;
int targetScreenWidth = 1120;
int targetScreenHeight = 700;

bool useBloom = false;
bool useShadowMap = true;

// Function headers.
void Win2PPM(int width, int height);
void configEngine(string configFile, string configName);

// AudioManager instance for the instance.
AudioManager audioManager = AudioManager();

int main(int argc, char *argv[]){
	loguru::g_stderr_verbosity = 0;  // Only show most relevant messages on stderr.
	loguru::init(argc, argv);  // Detect verbosity level on command line as -v.

	// Log messages to file:
	// loguru::add_file("fullLog.log", loguru::Append, loguru::Verbosity_MAX);  // Will append to log from last run.
	loguru::add_file("latest_fullLog.log", loguru::Truncate, loguru::Verbosity_MAX);
	loguru::add_file("latest_readable.log", loguru::Truncate, loguru::Verbosity_INFO);

	string gameFolder = "";
	string configType = "";

	if (argc == 1)
	{
		LOG_F(ERROR,"No Gamefolder specified");
		printf("\nUSAGE: ./engine Gamefolder/ [EngineConfig]\n");
		exit(1);
	}

	if (argc >= 2)
	{
		// First argument is which game folder to load.
		gameFolder = string(argv[1]);
	}

	if (argc >= 3)
	{
		// Second argument is what engine quality settings to use.
		configType = string(argv[2]);
	}

	LOG_F(INFO, "Loading game folder %s", gameFolder.c_str());

	configEngine("settings.cfg", configType);

	string luaFile = gameFolder + "main.lua";

	// Initialize Graphics (for OpenGL) and Audio (for sound) and Game Controller.
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMECONTROLLER | SDL_INIT_HAPTIC);

	audioManager.init();

	// TODO: Let users plug in mid game, must look for events:
	// SDL_CONTROLLERDEVICEADDED, SDL_CONTROLLERDEVICEREMOVED and
	// SDL_CONTROLLERDEVICEREMAPPED.
	initControllers();

	lua_State * L = luaL_newstate();  // Create a new lua state.
	luaSetup(L);  // Load custom engine functions for Lua scripts to use.

	loadMaterials(gameFolder+materialsFile);
	LOG_F(INFO,"Read %d materials\n",numMaterials);

	loadModel(gameFolder+modelFile);
	LOG_F(INFO,"Read %d models\n",numModels);

	loadScene(gameFolder+sceneFile);
	LOG_F(INFO,"Loaded scene file\n");

	createOpenGLWindow(targetScreenWidth, targetScreenHeight, fullscreen);

	// Initalize various buffers on the GPU.
	initIMGui();
	loadTexturesToGPU();
	initHDRBuffers();
	initSkyboxShader();
	initFinalCompositeShader();
	initShadowMapping();
	initBloom();
	initPBRShading();
	initColliderGeometry();  // Depends on PBRShading being initalized.
	initSkyboxBuffers();
  	initShadowBuffers();

	// Create a quad to be used for fullscreen rendering.
	createFullscreenQuad();

	glEnable(GL_DEPTH_TEST);  // Have closer objects hide further away ones.

	// Load Lua Gamescript (this will start the game running).
	LOG_F(INFO,"Loading Gamescript: '%s'",luaFile.c_str());
	int luaErr;
	luaErr = luaL_loadfile(L, luaFile.c_str());
	if(!luaErr)
	{
		luaErr = lua_pcall(L, 0, LUA_MULTRET, 0);
	}
	CHECK_F(luaErr==0, "Error loading Lua: %s ", lua_tostring(L, -1));
	LOG_F(INFO,"Script Loaded without Error.");

	int timeSpeed = 1;  // Modifies timestep rate given to Lua.

	// Event Loop (Loop while alive, processing each event as fast as possible).
	SDL_Event windowEvent;
	bool quit = false;
	while (!quit)
	{
		// Inspects all SDL events in the queue.
		while (SDL_PollEvent(&windowEvent))
		{
			bool altPressed = (windowEvent.key.keysym.mod & KMOD_LALT);
			altPressed |= (windowEvent.key.keysym.mod & KMOD_RALT);

			// Window close button.
			if (windowEvent.type == SDL_QUIT)
			{
				quit = true;
			}

			// Escape key.
			if (windowEvent.type == SDL_KEYUP && windowEvent.key.keysym.sym == SDLK_ESCAPE)
			{
				quit = true;
			}

			// Alt + F.
			if (windowEvent.type == SDL_KEYUP && windowEvent.key.keysym.sym == SDLK_f && altPressed)
			{
				// Toggle full screen view mode.
				fullscreen = !fullscreen;
				setWindowSize(targetScreenWidth, targetScreenHeight,fullscreen);
			}

			// Alt + S (pressed).
			if (windowEvent.type == SDL_KEYDOWN && windowEvent.key.keysym.sym == SDLK_s && altPressed)
			{
				saveOutput = true;
			}

			// Alt + S (released).
			if (windowEvent.type == SDL_KEYUP && windowEvent.key.keysym.sym == SDLK_s)
			{
				saveOutput = false;
			}

			// Alt + X.
			if (windowEvent.type == SDL_KEYUP && windowEvent.key.keysym.sym == SDLK_x && altPressed)
			{
				xxx = !xxx;
			}

			// Alt + Space.
			if (windowEvent.type == SDL_KEYUP && windowEvent.key.keysym.sym == SDLK_SPACE && altPressed)
			{
				// Pause / unpause the game.
				if (timeSpeed != 1)
				{
					 timeSpeed = 1;
					 audioManager.unpause();
					 printf("Game Resumed.\n");
				}
				else
				{
					timeSpeed = 0;
					audioManager.pause();
					printf("Game Paused.\n");
				}
			}

			// Alt + R.
			if (windowEvent.type == SDL_KEYUP && windowEvent.key.keysym.sym == SDLK_r && altPressed)
			{
				printf("Re-loading Materials file!\n");
				resetMaterials();
				loadMaterials(gameFolder+materialsFile);
				loadTexturesToGPU();

				printf("Re-loading Models file!\n");
				resetModels();
				loadModel(gameFolder+modelFile);
				loadAllModelsTo1VBO(modelsVBO);

				printf("Re-loading Scene file!\n");
				resetScene();
				loadScene(gameFolder+sceneFile);
				loadSkyboxToGPU();
			}
		}

		// Update the mouse and send the state to the Lua script.
		updateMouseDir();
		updateMouseState();
		mouseUpdateLua(L);

		// Read keyboard and send the state to the Lua script.
		updateKeyboardState();
		keyboardUpdateLua(L);

		// Read gamepad / controller and send the state to the Lua script.
		updateControllerState();
		gamepadUpdateLua(L);

		// Time management.
		static long long lastTime_dt = 0;  // @cleanup -- pull together various timing code
		long long curTime_dt = SDL_GetTicks();  // TODO: is this really long long?
		if (saveOutput) curTime_dt = lastTime_dt + .07 * 1000.0;
		float lua_dt = timeSpeed*(curTime_dt-lastTime_dt)/1000.0;
		lastTime_dt = curTime_dt;

		// Lua FrameUpdate method.
		lua_getglobal(L, "frameUpdate");
		if(!lua_isfunction(L,-1))
		{
			// Todo: make having frameUpdate function optional
      		lua_pop(L, 1);
    	}
		else
		{
			lua_pushnumber(L, lua_dt);  // 1/60.f
			// lua_call(L, 1, 0);  // 1 arguments, no returns
			luaErr = lua_pcall(L, 1, 0, 0);
			CHECK_F(luaErr==0, "Error after call to lua function 'frameUpdate': %s \n", lua_tostring(L, -1));
		}

		// Update Colliders.
		updateColliderPositions();

		// Calculate time to wait until next frame.
		static long long lastTime;
		long long curTime_frame = (long long) SDL_GetTicks();  // TODO: Does this actually return a long long?
		float frameTime = float(curTime_frame-lastTime)/1000.f;
		int delayFrames = int((secondsPerFrame-frameTime)*1000.0 + 0.5);
		if (delayFrames > 0)
		{
			SDL_Delay(delayFrames);
		}
		lastTime = (long long) SDL_GetTicks();

		// Get the camera state from the Lua script.
		camPos = getCameraPosFromLua(L);
		camDir = getCameraDirFromLua(L);
		camUp = getCameraUpFromLua(L);
		camDir = glm::normalize(camDir);
		camUp = glm::normalize(camUp);
		vec3 lookatPoint = camPos + camDir;

		// LOG_F(3,"Read Camera from Lua");

		// TODO: Allow Lua script to set Lights dynamically (it's currently static).
		for (int i = 0; i < (int)curScene.lights.size(); i++)
		{
			lightDirections[i] = glm::normalize(curScene.lights[i].direction);
			lightColors[i] = curScene.lights[i].color * curScene.lights[i].intensity;
		}

		// TODO: Allow Lua script to set FOV dynamically (it's currently static).
		float FOV = curScene.mainCam.FOV;

		/*
		Rendering the frame goes over 4 passes:
		1. Computing depth map
		2. Rendering geometry (and skybox)
		3. Bloom
		4. Composite and tone-mapping
		*/

		// ------ PASS 1 - shadow map ------ //

		static mat4 lightProjectionMatrix;
		static mat4 lightViewMatrix;

		if (useShadowMap && curScene.shadowLight.castShadow)
		{
			// TODO: We can re-use the lightViewMatrix and lightProjectionMatrix
			// if the light doesn't move @performance
			lightProjectionMatrix = glm::ortho(
				curScene.shadowLight.frustLeft, curScene.shadowLight.frustRight,
				curScene.shadowLight.frustTop, curScene.shadowLight.frustBot,
				curScene.shadowLight.frustNear, curScene.shadowLight.frustFar
			);

			// TODO: Should the directional light always follow the user's lookat point?
			static vec3 lightDir = curScene.shadowLight.direction;
			static float lightDist = curScene.shadowLight.distance;
			static vec3 lightPos = lookatPoint - lightDir*lightDist;
			// TODO: Is this hacky? What should the light up be?
			static vec3 lightUp = glm::cross(camUp,lookatPoint-lightPos);
			static vec3 z = lookatPoint-lightPos;

			lightViewMatrix = glm::lookAt(lightPos,lookatPoint, lightUp);

			if (shadowFrustumCull)
			{
				computeShadowDepthMap(lightViewMatrix, lightProjectionMatrix, curScene.toDraw,
					curScene.shadowLight.frustLeft, curScene.shadowLight.frustRight,
					curScene.shadowLight.frustTop, curScene.shadowLight.frustBot,
					curScene.shadowLight.frustNear, curScene.shadowLight.frustFar
				);
			}
			else
			{
				computeShadowDepthMap(lightViewMatrix, lightProjectionMatrix, curScene.toDraw);
			}
		}

		// TODO: Make this more robust when the user switches to fullscreen.
		glViewport(0, 0, screenWidth, screenHeight);

		// ------ PASS 2 - main (PBR) shading pass ------ //

		view = glm::lookAt(camPos, lookatPoint, camUp);
		proj = glm::perspective(FOV * 3.14f/180, screenWidth / (float) screenHeight, cameraNear, cameraFar);  // FOV, aspect, near, far.
		// view = lightViewMatrix; proj = lightProjectionMatrix;  // This was useful to visualize the shadow map.

		setPBRShaderUniforms(view, proj, lightViewMatrix, lightProjectionMatrix, useShadowMap);
		updatePRBShaderSkybox();  // TODO: We only need to call this if the skybox changes.

		// Clear the screen to default color.
		glClearColor(0,0,0,1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		// Pass 2A: draw scene geometry
		if (viewFrustumCull)
		{
			drawSceneGeometry(curScene.toDraw, view, FOV * 3.14f/180, screenWidth / (float) screenHeight, cameraNear, cameraFar);
		}
		else
		{
			drawSceneGeometry(curScene.toDraw);
		}

		// TODO: add a pass which draws some items without depth culling (e.g. keys, items).

		//Pass 2B: draw colliders.
		if (drawColliders) drawColliderGeometry();

		// Pass 2C: draw skybox / sky color.
		drawSkybox(view, proj);

		// ------ PASS 3 - bloom ------ //

		if (useBloom)
		{
			computeBloomBlur();
		}

		// ------ PASS 4 - composite & HDR tonemapping ------ //

		drawCompositeImage(useBloom);

		// Check for OpenGL errors.
		int err = glGetError();
		if (err)
		{
			LOG_F(ERROR,"GL ERROR: %d\n",err);
			exit(1);
		}

		// Record how long it took to draw the geometry to the screen.
		long long curTime_draw = SDL_GetTicks();
		glFlush();
		float drawTime = (curTime_draw-lastTime);

		if (saveOutput)
		{
			Win2PPM(screenWidth,screenHeight);
		}

		/*
		ImGui can do some pretty cool things, try some of these:
		ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
		ImGui::ColorEdit3("clear color", (float*)&clear_color);
		static float f = 0.0f;
		ImGui::SliderFloat("float", &f, 0.0f, 1.0f);
		static int counter = 0;
		if (ImGui::Button("Button")) counter++;
		*/

		IMGuiNewFrame();
		ImGui::Begin("Frame Info");
		ImGui::Text("Time for Rendering %.0f ms", drawTime);
		ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
		ImGui::Text("%d Objects in Scene Graph, %d being drawn", numModels, (int)curScene.toDraw.size());
		ImGui::Text("Total Triangles: %d", totalTriangles);
		ImGui::Text("Total Shadow Triangles: %d", totalShadowTriangles);
		ImGui::Text("Camera Pos %f %f %f",camPos.x,camPos.y,camPos.z);
		ImGui::Text("Camera Dir %f %f %f",camDir.x,camDir.y,camDir.z);
		ImGui::Text("Camera Up %f %f %f",camUp.x,camUp.y,camUp.z);
		ImGui::End();

		// Render ImGui.
		ImGui::Render();
		ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

		// LOG_F(3,"Done Drawing");
		swapDisplayBuffers();
	}

	// Clean up.
	cleanupBuffers();
	gamepadCleanup();
	windowCleanup();

	lua_close(L);
	return 0;
}

void configEngine(string configFile, string configName)
{
	LOG_SCOPE_FUNCTION(INFO);  // Group logging info from this function.

	FILE *fp;
  	char rawline[1024];  // Assumes no line is longer than 1024 characters!

  	// open the file containing the scene description.
  	fp = fopen(configFile.c_str(), "r");

	LOG_F(INFO,"Loading Config File: %s", configFile.c_str());
	CHECK_NOTNULL_F(fp,"Can't open configuration file '%s'", configFile.c_str());

	//a helper variable to make sure we only use elements related to the config
	// chosen by the user.
	bool useThisConfig = true;

  	// Loop through reading each line
  	while( fgets(rawline,1024,fp))
	{
		// Assumes no line is longer than 1024 characters!
	  	string line = string(rawline);
    	if (rawline[0] == '#' || rawline[0] == ';')
		{
			LOG_F(2,"Skipping comment: %s", rawline);
      		continue;
    	}

    	char command[100];  // Assumes no command is longer than 100 chars.
    	int fieldsRead = sscanf(rawline,"%s ",command);  // Read first word in the line (i.e., the command type).
    	string commandStr = command;

    	if (fieldsRead < 1)
		{
			// No command read = blank line.
			continue;
		}

		// Start using a configuration whenver it matches the passed-in configName.
		if (commandStr == "["+configName+"]")
		{
			useThisConfig = true;
		}
		// Stop using configuration values whenver you see a no configuration
		// set start (unless it equals the passed-in name).
		else if (commandStr.substr(0,1) == "[")
		{
			useThisConfig = false;
		}

		// Not in the passed-in configuration.
		if (!useThisConfig)
		{
			continue;
		}

		if (commandStr == "useShadowMap")
		{
			int val;
			sscanf(rawline,"useShadowMap = %d", &val);
			useShadowMap = val;
			LOG_F(1,"Using Shadow map: %s", useShadowMap ? "TRUE" : "FALSE");
    	}
    	else if (commandStr == "shadowMapW")
		{
			float val;
			sscanf(rawline,"shadowMapW = %f", &val);
			shadowMapWidth = val;
      		LOG_F(1,"Setting Shadow Map Width to %d",shadowMapWidth);
    	}
		else if (commandStr == "shadowMapH")
		{
			float val;
			sscanf(rawline,"shadowMapH = %f", &val);
			shadowMapHeight = val;
      		LOG_F(1,"Setting Shadow Map Height to %d",shadowMapHeight);
    	}
		else if (commandStr == "screenW")
		{
			float val;
			sscanf(rawline,"screenW = %f", &val);
			targetScreenWidth = val;
      		LOG_F(1,"Setting Screen Width to %d",targetScreenWidth);
    	}
		else if (commandStr == "screenH")
		{
			float val;
			sscanf(rawline,"screenH = %f", &val);
			targetScreenHeight = val;
      		LOG_F(1,"Setting Screen Height to %d",targetScreenHeight);
    	}
		else if (commandStr == "drawColliders")
		{
			int val;
			sscanf(rawline,"drawColliders = %d", &val);
			drawColliders = val;
      		LOG_F(1,"Drawing colliders: %s", drawColliders ? "TRUE" : "FALSE");
    	}
		else if (commandStr == "`")
		{
			float val;
			sscanf(rawline,"targetFrameRate = %f", &val);
			targetFrameRate = val;
			secondsPerFrame = 1.0f / val;
      		LOG_F(1,"Setting Target Framerate to %d",(int)targetFrameRate);
    	}
		else if (commandStr == "cameraNear")
		{
			float val;
			sscanf(rawline,"cameraNear = %f", &val);
			cameraNear = val;
      		LOG_F(1,"Setting Camera Near Plane to %f",cameraNear);
    	}
		else if (commandStr == "cameraFar")
		{
			float val;
			sscanf(rawline,"cameraFar = %f", &val);
			cameraFar = val;
      		LOG_F(1,"Setting Camera Far Plane to %f",cameraFar);
    	}
		else if (commandStr == "viewFrustumCull")
		{
			int val;
			sscanf(rawline,"viewFrustumCull = %d", &val);
			viewFrustumCull = val;
      		LOG_F(1,"Using View Frustum Culling: %s", viewFrustumCull ? "TRUE" : "FALSE");
    	}
		else if (commandStr == "shadowFrustumCull")
		{
			int val;
			sscanf(rawline,"shadowFrustumCull = %d", &val);
			shadowFrustumCull = val;
      		LOG_F(1,"Using View Frustum Culling: %s", shadowFrustumCull ? "TRUE" : "FALSE");
    	}
		else if (commandStr == "startFullscreen")
		{
			int val;
			sscanf(rawline,"startFullscreen = %d", &val);
			fullscreen = val;
      		LOG_F(1,"Starting Fullscreen: %s", fullscreen ? "TRUE" : "FALSE");
    	}
		else if (commandStr == "boarderlessWindow")
		{
			int val;
			sscanf(rawline,"boarderlessWindow = %d", &val);
			fullscreenMode = val ? SDL_WINDOW_FULLSCREEN_DESKTOP : SDL_WINDOW_FULLSCREEN;
      		LOG_F(1,"Boarderless Window for Fullscreen: %s", fullscreenMode ? "TRUE" : "FALSE");
    	}
		if (commandStr == "useBloom")
		{
			int val;
			sscanf(rawline,"useBloom = %d", &val);
			useBloom = val;
      		LOG_F(1,"Using Bloom: %s", useBloom ? "TRUE" : "FALSE");
    	}
		if (commandStr == "bloomPasses")
		{
			int val;
			sscanf(rawline,"bloomPasses = %d", &val);
			numBloomPasses = val;
      		LOG_F(1,"Number of bloom passes: %d", numBloomPasses);
    	}
	}
}

void Win2PPM(int width, int height)
{
	char outdir[20] = "Screenshots/";  // Must be exist!
	int i,j;
	FILE* fptr;
	static int counter = 0;
	char fname[32];
	unsigned char *image;

	// Allocate our buffer for the image.
	image = (unsigned char *)malloc(3*width*height*sizeof(char));
	if (image == NULL)
	{
		fprintf(stderr,"ERROR: Failed to allocate memory for image\n");
	}

	// Open the file.
	sprintf(fname,"%simage_%04d.ppm",outdir,counter);
	if ((fptr = fopen(fname,"w")) == NULL)
	{
		fprintf(stderr,"ERROR: Failed to open file for window capture\n");
	}

	// Copy the image into our buffer.
	glReadBuffer(GL_BACK);
	glReadPixels(0,0,width,height,GL_RGB,GL_UNSIGNED_BYTE,image);

	// Write the PPM file.
	fprintf(fptr,"P6\n%d %d\n255\n", width, height);
	for (j=height-1; j >= 0; j--)
	{
		for (i=0; i < width; i++)
		{
			fputc(image[3*j*width+3*i+0],fptr);
			fputc(image[3*j*width+3*i+1],fptr);
			fputc(image[3*j*width+3*i+2],fptr);
		}
	}

	free(image);
	fclose(fptr);
	counter++;
}
