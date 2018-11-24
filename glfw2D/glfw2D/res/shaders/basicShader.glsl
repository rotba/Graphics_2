 #version 130 

#define exponent 15
#define INFINITY 1000.5693
uniform vec4 eye;
uniform vec4 ambient;
uniform vec4[20] objects;
uniform vec4[20] objColors;
uniform vec4[10] lightsDirection;
uniform vec4[10] lightsIntensity;
uniform vec4[10] lightPosition;
uniform ivec4 sizes; //{number of objects , number of lights , width, hight}  

in vec3 position1;

struct Intersection
{
  float t;
  int index;
  vec3 p;
};

float intersect(vec3 sourcePoint,vec3 v, vec4 object);
float intersects_plane(vec3 sourcePoint,vec3 v, vec4 object);
float intersects_sphere(vec3 sourcePoint,vec3 v, vec4 object);
vec3 calcq0( vec4 plane);
vec3 calc_light(vec3 p, int obj_idx ,int light_src_idx);
vec3 calc_spotlight(vec3 p, int obj_idx ,int light_src_idx);
vec3 calc_directional_light(vec3 p, int obj_idx ,int light_src_idx);
vec4 get_spolight_position(int light_src_idx);
vec3 norm_at_point(Intersection intrsc);
vec3 calc_R(vec3 N, vec3 L);
bool not_occluded(vec3 p, int light_idx);



Intersection findIntersection(vec3 sourcePoint,vec3 v)
{
	Intersection ans;
	float t = 0;
	ans.t = INFINITY;
	for(int i = 0; i < sizes[0]; i++){
		t = intersect(sourcePoint, v, objects[i]);
		if(t < ans.t){
			ans.t=t;
			ans.index = i;
		}
	}
	ans.p = sourcePoint + ans.t*v;
    return ans;
    
}

float intersect(vec3 sourcePoint,vec3 v, vec4 object)
{
	float t = INFINITY;
	if(object.w < 0.0){
		t = intersects_plane(sourcePoint,v, object);
	}else{
		t = intersects_sphere(sourcePoint,v, object);
	}
   return t; 
}

float intersects_plane(vec3 sourcePoint,vec3 v, vec4 plane)
{
	float t = INFINITY;
	vec3 Q0=calcq0(plane);
	vec3 N=normalize(plane.xyz);
	vec3 V=normalize(v);
	vec3 PQ=Q0-sourcePoint;
	t=dot(N, PQ/dot(N,V));
	if(t<=0.0){
		t = INFINITY;
	}
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
	float t = INFINITY;
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
	float t1=(-b+sqrt(delta))/2.0;
	float t2=(-b-sqrt(delta))/2.0;
	t=min(t1,t2);
	if (t<0){
		t=max(t1,t2);
	}
	if(t <=0.0){
		t =INFINITY;	
	}
   return t; 
}

vec3 calc_light(vec3 p, int obj_idx ,int light_src_idx)
{
	vec3 ans;
	if(lightsDirection[light_src_idx].w == 1.0){
		ans = calc_spotlight(p, obj_idx ,light_src_idx);
	}else{
		ans = calc_directional_light(p, obj_idx ,light_src_idx);
	}
	return ans;
}
vec3 calc_spotlight(vec3 p, int obj_idx ,int light_src_idx){
	vec3 light_position = get_spolight_position(light_src_idx).xyz;
	vec3 D = normalize(lightsDirection[light_src_idx].xyz);
	vec3 L = normalize(p - light_position);
	vec3 I0 = lightsIntensity[light_src_idx].xyz;
	return I0*dot(D,L);

}
vec3 calc_directional_light(vec3 p, int obj_idx ,int light_src_idx){
	return lightsIntensity[light_src_idx];
}

vec4 get_spolight_position(int light_src_idx){
	vec3 ans;
	int count = -1;
	for(int i = 0; i <= light_src_idx; i++){
		if(lightsDirection[i].w == 1.0){
			count = count+1;
		}
	}
	return lightPosition[count];
}

vec3 norm_at_point(Intersection intrsc)
{
	vec3 ans;
	if(objects[intrsc.index].w < 0.0){
		ans = objects[intrsc.index].xyz;
	}else{
		ans = intrsc.p - objects[intrsc.index].xyz;
	}
	return normalize(ans);
}

vec3 calc_R(vec3 N, vec3 L)
{
	return reflect(-L, N);
}

bool not_occluded(vec3 p, int light_idx){
	vec4 light_src = lightsDirection[light_idx];
	vec3 v = -normalize(light_src.xyz);
	Intersection intr = findIntersection(p, v);
	if(light_src.w == 1.0){
		vec4 light_pos = get_spolight_position(light_idx);
		vec3 L = normalize(p - light_pos.xyz);
		vec3 D = normalize(lightsDirection[light_idx].xyz);
		if(dot(D,L) < light_pos.w){
			return false;
		}
		float length_to_light = length(light_pos.xyz - p);
		float length_to_obj = length(intr.p - p);
		if(intr.t != INFINITY && (length_to_obj < length_to_light)){
			return false;
		}
	}else{
		if(intr.t != INFINITY ){
			return false;
		}
	}
	return true;
}

vec3 colorCalc( Intersection intrsc)
{
	vec3 color;
	vec3 Ka = objColors[intrsc.index].xyz;

	vec3 KaIamb = Ka*(ambient.xyz);
	vec3 diffuse;
	vec3 specular;
	vec3 Kd = vec3(0.7,0.7,0.7);
	
	if(intrsc.index == 0)
	{
		vec3 p= intrsc.p;
		if(p.x * p.y >=0){
			if((mod(int(1.5*p.x),2) == mod(int(1.5*p.y),2)))
			{
				KaIamb=0.5*KaIamb;
			}
		}else{
			if((mod(int(1.5*p.x),2) != mod(int(1.5*p.y),2)))
			{
				KaIamb=0.5*KaIamb;
			}
		}
	}
	vec3 Ks = vec3(0.7,0.7,0.7);
	for(int i = 0; i < sizes[1]; i++){
		if(not_occluded(intrsc.p, i)){
			vec3 N = norm_at_point(intrsc);
			vec3 L = -lightsDirection[i].xyz;
			vec3 Ili = calc_light(intrsc.p, intrsc.index, i);
			if((dot(N,L))>0){
				diffuse += Kd*(dot(N,L))*Ili;
			}
			vec3 V = normalize(eye.xyz - intrsc.p);
			vec3 R = calc_R(N,L);
			if((dot(V,R))>0){
				specular += Ks*(pow(dot(V,R),exponent))*Ili;
			}
		}
	}
	color = KaIamb + diffuse + specular;
    return color;
}

void main()
{	
	vec3 v =normalize( position1 - eye.xyz);
	Intersection intrsc = findIntersection(eye.xyz, v);
	gl_FragColor = vec4(colorCalc(intrsc),1);
}
 

