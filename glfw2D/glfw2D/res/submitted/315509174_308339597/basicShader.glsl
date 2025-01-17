 #version 130 

#define exponent 12
#define INFINITY 1000.5693
#define MAX_LEVEL 5
uniform vec4 eye;
uniform vec4 ambient;
uniform vec4[20] objects;
uniform vec4[20] objColors;
uniform vec4[10] lightsDirection;
uniform vec4[10] lightsIntensity;
uniform vec4[10] lightPosition;
uniform ivec4 sizes; //{number of objects , number of lights , width, hight}  
uniform ivec4 mirrors_size; 
uniform vec4[20] mirrors;


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
//vec3 calc_R(vec3 N, vec3 L);
bool occluded(vec3 p, int light_idx);
bool is_mirror(vec4 obj_idx);





Intersection findIntersection(vec3 sourcePoint,vec3 v)
{
	Intersection ans;
	float t = 0;
	ans.t = INFINITY;
	for(int i = 0; i < sizes[0]; i++){
		t = intersect(sourcePoint, v, objects[i]);
		if(t < ans.t && t > 0.01){
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
	vec3 N=-normalize(plane.xyz);
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
	if(delta < 0){
		return INFINITY;
	}
	float t1=(-b+sqrt(delta))/2.0*a;
	float t2=(-b-sqrt(delta))/2.0*a;
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
	return lightsIntensity[light_src_idx].xyz;
	vec3 light_position = get_spolight_position(light_src_idx).xyz;
	vec3 D = normalize(lightsDirection[light_src_idx].xyz);
	vec3 L = normalize(p - light_position);
	vec3 I0 = lightsIntensity[light_src_idx].xyz;
	return I0*dot(D,L);

}
vec3 calc_directional_light(vec3 p, int obj_idx ,int light_src_idx){
	return lightsIntensity[light_src_idx].xyz;
	vec3 i0= lightsIntensity[light_src_idx].xyz;
	vec3 D = (lightsDirection[light_src_idx].xyz);
	Intersection intrsc;
	intrsc.p=p;
	intrsc.index=obj_idx;
	vec3 L = norm_at_point(intrsc);
	return i0*(-dot(D,L));
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
		ans = -objects[intrsc.index].xyz;
	}else{
		ans = intrsc.p - objects[intrsc.index].xyz;
	}
	return ans;
}

//vec3 calc_R(vec3 N, vec3 L)
//{
	//return reflect(L, N);
//}

bool occluded(vec3 p, int light_idx){
	vec4 light_src = lightsDirection[light_idx];
	vec3 v;
	if(lightsDirection[light_idx].w == 1.0){
		vec3 sl_pos = get_spolight_position(light_idx).xyz;
		v = normalize(sl_pos - p);
	}else{
		v = -normalize(light_src.xyz);
	}
	Intersection intr = findIntersection(p, v);
	if(light_src.w == 1.0){
		vec4 light_pos = get_spolight_position(light_idx);
		vec3 L = normalize(p - light_pos.xyz);
		vec3 D = normalize(lightsDirection[light_idx].xyz);
		if(dot(D,L) < light_pos.w){
			return true;
		}
		float length_to_light = length(light_pos.xyz - p);
		float length_to_obj = length(intr.p - p);
		if(intr.t != INFINITY && (length_to_obj < length_to_light)){
			return true;
		}
	}else{
		if(intr.t != INFINITY ){
			return true;
		}
	}
	return false;
}

bool is_mirror(vec4 obj){
	return 
	(obj ==mirrors[0] ) || (obj ==mirrors[1]) || (obj ==mirrors[2]) || (obj ==mirrors[3]) || (obj ==mirrors[4]) ||
	(obj ==mirrors[5]) || (obj ==mirrors[6]) || (obj ==mirrors[7]) || (obj ==mirrors[8]) || (obj ==mirrors[9]) ||
	(obj ==mirrors[10]) || (obj ==mirrors[11]) || (obj ==mirrors[12]) || (obj ==mirrors[13]) || (obj ==mirrors[14]) ||
	(obj ==mirrors[15]) || (obj ==mirrors[16]) || (obj ==mirrors[17]) || (obj ==mirrors[18]) || (obj ==mirrors[19]);
}



vec3 colorCalc( Intersection intrs, vec3 sourcePoin)
{
	vec3 color;
	Intersection curr_intersc = intrs;
	vec3 curr_sourcePoint = sourcePoin;
	int level = 0;
	while(level <= MAX_LEVEL){
		//vec3 sdfsdf = objects[10].xyz;
		vec3 Ka = objColors[curr_intersc.index].xyz;
		vec3 diffuse=vec3(0,0,0);
		vec3 specular=vec3(0,0,0);
		vec3 Kd = Ka;
		if(objects[curr_intersc.index].w < 0)
		{
			vec3 p= curr_intersc.p;
			if(p.x * p.y >=0){
				if((mod(int(1.5*p.x),2) == mod(int(1.5*p.y),2)))
				{
					Ka=0.5*Ka;
				}
			}
			else{
				if((mod(int(1.5*p.x),2) != mod(int(1.5*p.y),2)))
				{
					Ka=0.5*Ka;
				}
			}
		}
		vec3 KaIamb = Ka*(ambient.xyz);
		vec3 Ks = vec3(0.7,0.7,0.7);
		for(int i = 0; i < sizes[1]; i++){
			if( !occluded(curr_intersc.p, i) ){
				vec3 N = normalize(norm_at_point(curr_intersc));
				vec3 L;
				if(lightsDirection[i].w == 1.0){
					vec3 sl_pos = get_spolight_position(i).xyz;
					L = normalize(sl_pos - curr_intersc.p);
				}
				else{
					L = -normalize(lightsDirection[i].xyz);
				}
				vec3 Ili = calc_light(curr_intersc.p, curr_intersc.index, i);
				if((dot(N,L))>0){
					diffuse += Kd*(dot(N,L))*Ili;
				}
				vec3 V = normalize(curr_sourcePoint - curr_intersc.p);
				vec3 R = reflect(-L,N);
				if((dot(V,R))>0){
					specular += Ks*(pow(dot(V,R),exponent))*Ili;
				}
			}
		}
		bool ismirror = false;
		vec4 obj = objects[curr_intersc.index];
		if( mirrors_size[0] != -1){
			for(int j = 0; j < mirrors_size[0]; j++){
				if(obj == mirrors[j]){
					ismirror = true;
				}
			}
		}
		if(is_mirror(obj) && !(level ==MAX_LEVEL)){
			vec3 N = normalize(norm_at_point(curr_intersc));
			vec3 in_ray =normalize( curr_intersc.p - curr_sourcePoint);
			vec3 out_ray = normalize(reflect(in_ray,N));
			Intersection nextIntr = findIntersection(curr_intersc.p, out_ray);
			curr_sourcePoint = curr_intersc.p;
			curr_intersc = nextIntr;
			if(nextIntr.t == INFINITY){
				return vec3(0,0,0);
			}
			else{
			color = KaIamb + diffuse + specular;
				level =level+ 1;
			}
		}
		else{
			
			color = KaIamb + diffuse + specular;
			level = MAX_LEVEL+1;
		}
	}
    return color;
}


void main()
{	
	vec3 v =normalize( position1 - eye.xyz);
	Intersection intrsc = findIntersection(eye.xyz, v);
	gl_FragColor = vec4(colorCalc(intrsc, eye.xyz),1);
}
 

