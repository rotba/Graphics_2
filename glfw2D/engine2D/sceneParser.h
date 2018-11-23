#include <fstream>
#include <iostream>
#include <errno.h>
#include <vector>
#include "shader.h"

class Scene
{
private:
	glm::vec4 eye;
	glm::vec4 ambient;
	std::vector<glm::vec4> objects;
	std::vector<glm::vec4> objColors;
	std::vector<glm::vec4> lightsDirection;
	std::vector<glm::vec4> lightsIntensity;
	std::vector<glm::vec4> lightPosition;
	glm::ivec4 sizes; //{number of objects , number of lights , width, hight}  

	
	static inline unsigned int FindNextChar(unsigned int start, const char* str, unsigned int length, char token)
	{
		unsigned int result = start;
		while(result < length)
		{
			result++;
			if(str[result] == token)
				break;
		}
    
		return result;
	}

	static inline unsigned int ParseIndexValue(const std::string& token, unsigned int start, unsigned int end)
	{
		return atoi(token.substr(start, end - start).c_str()) - 1;
	}

	static inline float ParseFloatValue(const std::string& token, unsigned int start, unsigned int end)
	{
		return atof(token.substr(start, end - start).c_str());
	}
public:
	
	glm::vec4 parseVec4(const std::string& line);
	void loadtoShader(Shader &shader);
	Scene(const std::string& fileName,int width,int height);
	void Scene::PrintScene();
};