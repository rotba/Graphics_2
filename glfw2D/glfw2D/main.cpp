#include <iostream>
#include "display.h"
#include "mesh.h"
#include "shader.h"
#include "debugTimer.h"
#include "inputManager.h"
#include "texture.h"
#include "sceneParser.h"

using namespace glm;

int main(int argc,char** argv)
{
	Display display(800,600,"hello!");
	//Shader shader("res/shaders/mbrot");
	Shader shader("res/shaders/basicShader");
	Vertex vertices[] = {Vertex(vec3(-1,-1,0),vec2(0,0),vec3(0,0,1)),Vertex(vec3(1,-1,0),vec2(1,0),vec3(0,0,1)),Vertex(vec3(1,1,0),vec2(1,1),vec3(0,0,1)),Vertex(vec3(-1,1,0),vec2(0,1),vec3(0,0,1))};
	unsigned int indices[] = {0,1,2,0,2,3};
	Mesh mesh(vertices,4,indices,6);
	float t =0;
	
	Scene scn("res/scene.txt", 195, 228);
	scn.PrintScene();
	glfwSetKeyCallback(display.m_window,key_callback);
	
	//main loop
	while(!glfwWindowShouldClose(display.m_window))
	{
		if(t<1)
			t+=0.1;
		else
			t=0;
		std::cout << t << std::endl;
		//clear back buffer 
		display.Clear(0.0f, 0.0f, 0.0f, 1.0f);
	
		//bind shader
		shader.Bind();
		shader.Update(t);
		scn.loadtoShader(shader);

		//draw mesh
		mesh.Draw();
		//swap front and back buffer
		display.SwapBuffers();

		glfwPollEvents();
	}
	
	return 0;
}