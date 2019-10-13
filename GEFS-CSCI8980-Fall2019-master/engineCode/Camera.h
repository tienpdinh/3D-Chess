	#include "glm/glm.hpp"

  extern glm::mat4 view, proj;  //Camera view and projection matrix
	extern glm::vec3 camPos, camDir, camUp; //Camera State
  extern glm::vec3 mouseDir; //Normalized direction mouse is pointing (in world space)

  void updateMouseDir(); //Recompute mouseDir each frame