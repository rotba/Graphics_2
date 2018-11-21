#include "SceneParser.h"

//parse line to vec4
glm::vec4 Scene::parseVec4(const std::string& line) 
{
    unsigned int tokenLength = line.length();
    const char* tokenString = line.c_str();
    
    unsigned int vertIndexStart = 2;
    
    while(vertIndexStart < tokenLength)
    {
        if(tokenString[vertIndexStart] != ' ')
            break;
        vertIndexStart++;
    }
    
    unsigned int vertIndexEnd = FindNextChar(vertIndexStart, tokenString, tokenLength, ' ');
    
    float x = ParseFloatValue(line, vertIndexStart, vertIndexEnd);
    
    vertIndexStart = vertIndexEnd + 1;
    vertIndexEnd = FindNextChar(vertIndexStart, tokenString, tokenLength, ' ');
    
    float y = ParseFloatValue(line, vertIndexStart, vertIndexEnd);
    
    vertIndexStart = vertIndexEnd + 1;
    vertIndexEnd = FindNextChar(vertIndexStart, tokenString, tokenLength, ' ');
    
    float z = ParseFloatValue(line, vertIndexStart, vertIndexEnd);
    
	vertIndexStart = vertIndexEnd + 1;
    vertIndexEnd = FindNextChar(vertIndexStart, tokenString, tokenLength, ' ');
    
    float w = ParseFloatValue(line, vertIndexStart, vertIndexEnd);

    return glm::vec4(x,y,z,w);

    //glm::vec3(atof(tokens[1].c_str()), atof(tokens[2].c_str()), atof(tokens[3].c_str()))
}

void Scene::loadtoShader(Shader &shader)
{
			shader.set_uniform4v(3,1,&coeffs);			
			shader.set_uniform4v(4,src_lines.size(),&src_lines[0]);
			shader.set_uniform4v(5,dst_lines.size(),&dst_lines[0]);
			shader.set_uniform4vi(6,sizes);
				//objects[1].x +=0.001;
}

void Scene::PrintScene()
{
	std::cout<<"coeffs: a = "<<coeffs[1]<<" b= "<<coeffs[2]<<" p = "<<coeffs[3]<<std::endl; 
	std::cout<<"picture size "<<sizes[2]<<"X"<<sizes[3]<<std::endl;
	std::cout<<"lines: "<<std::endl; 
	for (int i = 0; i < sizes[0]; i++)
	{
		std::cout<<"source: ("<<src_lines[i].x<<" , "<<src_lines[i].y<<") , ("<<src_lines[i].z<<" , "<<src_lines[i].w<<")"<<std::endl;
		std::cout<<"distination: ("<<dst_lines[i].x<<" , "<<dst_lines[i].y<<") , ("<<dst_lines[i].z<<" , "<<dst_lines[i].w<<")"<<std::endl;
	}		
}

//parsing file and save width and hight of the image
Scene::Scene(const std::string& fileName,int width,int height)
{
	std::ifstream file;
    file.open((fileName).c_str());
	
    std::string line;
    if(file.is_open())
    {
        while(file.good())
        {
            getline(file, line);
        
            unsigned int lineLength = line.length();
            
            if(lineLength < 2)
                continue;
            
            const char* lineCStr = line.c_str();
            
            switch(lineCStr[0])
            {
                case 'c':
					coeffs = parseVec4(line);
				break;
				case 's':
					src_lines.push_back( parseVec4(line));
				break;
				case 'd':
					dst_lines.push_back( parseVec4(line));
				break;
			}
		}
		sizes =  glm::ivec4(src_lines.size(),dst_lines.size(),width,height);
	}
	else
	{
		char buf[100];
		//std::cout<<"can not open file!"<<std::endl;
		strerror_s(buf,errno);
		std::cerr << "Error: " << buf; 
		sizes = glm::ivec4(0,0,0,0);
	}
	
}



