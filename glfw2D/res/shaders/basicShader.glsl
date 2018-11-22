 #version 130 

uniform vec4 eye;
uniform vec4 ambient;
uniform vec4[20] objects;
uniform vec4[20] objColors;
uniform vec4[10] lightsDirection;
uniform vec4[10] lightsIntensity;
uniform vec4[10] lightPosition;
uniform ivec4 sizes; //{number of objects , number of lights , width, hight}  

in vec3 position1;

float intersect(vec3 sourcePoint,vec3 v, vec4 object);
float intersects_plane(vec3 sourcePoint,vec3 v, vec4 object);
float intersects_sphere(vec3 sourcePoint,vec3 v, vec4 object);
vec3 calcq0( vec4 plane);

struct Intersection
{
  float t;
  int index;
};

Intersection findIntersection(vec3 sourcePoint,vec3 v)
{
	Intersection ans;
	float t = 0;
	ans.t = -1.0;
	for(int i = 0; i < sizes[0]; i++){
		t = intersect(sourcePoint, v, objects[i]);
		if(ans.t == -1.0 || t < ans.t){
			ans.t=t;
			ans.index = i;
		}
	}
    return ans;
    
}

float intersect(vec3 sourcePoint,vec3 v, vec4 object)
{
	float t = -1.0;
	if(object.w < 0.0){
		t = intersects_plane(sourcePoint,v, object);
	}else{
		t = intersects_sphere(sourcePoint,v, object);
	}
   return t; 
}

float intersects_plane(vec3 sourcePoint,vec3 v, vec4 object)
{
	float t = -1.0;
	vec3 Q0=calcq0(object);
	vec3 N=normalize(object.xyz);
	vec3 V=normalize(v);
	vec3 PQ=Q0-sourcePoint;
	t=dot(N, PQ/dot(N,V));
   return t; 
}
vec3 calcq0( vec4 plane)
{
	vec3 Q0;
	if(plane.z !=0.0)
	{
		Q0=vec3(0,0,-(plane.w)/plane.z); 
	}
	else if(plane.y !=0.0)
	{
		Q0=vec3(0.0,-(plane.w)/plane.y,0.0);
	}
	else if(plane.x !=0)
	{
		Q0=vec3((-(plane.w)/plane.x),0.0,0.0);
	}
	else if(plane.w!=0.0)
	{
		Q0=	vec3(-1.0,-1.0,-1.0);
	}
	else	
	{	
		Q0=	vec3(0.0,0.0,0.0);
	}
	return Q0;
}

float intersects_sphere(vec3 sourcePoint,vec3 v, vec4 sphere)
{
	float t = -1.0;
	vec3 V=normalize(v);
	vec3 P=sourcePoint;
	vec3 O=sphere.xyz;
	vec3 OP=P-O;
	float R=sphere.w;
	float R2=R*R;
	float a=1.0;
	float b=dot(2*V,OP);
	float c=pow(length(OP),2)-R2;
	float delta=b*b-4*a*c;
	float t1=(b+sqrt(delta))/2.0;
	float t2=(b-sqrt(delta))/2.0;
	t=min(t1,t2);
	if (t<0){
		t=max(t1,t2);
	}
   return t; 
}

vec3 colorCalc( vec3 intersectionPoint)
{
	vec3 v = position1 - intersectionPoint;
	Intersection intrsc = findIntersection(intersectionPoint, v);
    vec3 color = objColors[intrsc.index].xyz;
    return color;
}

void main()
{
	gl_FragColor = vec4(colorCalc(eye.xyz),1);      
}
 

