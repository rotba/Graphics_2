#include <fstream>
#include <iostream>
#include <errno.h>
#include <vector>
#include "shader.h"

class Scene
{
private:
	glm::vec4 coeffs;         
	glm::ivec4 sizes;
	std::vector<glm::vec4> src_lines;     
	std::vector<glm::vec4> dst_lines;        

	
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