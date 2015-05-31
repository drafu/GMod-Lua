local META = {}
META = 
{
	__index = function(tbl, key) return META[key] end,
	__unm = function(lhs) return vec2(-lhs.x, lhs.y) end,
	__add = function(lhs, rhs) return vec2(lhs.x + (rhs.x or rhs), lhs.y + (rhs.y or rhs)) end,
	__sub = function(lhs, rhs) return vec2(lhs.x - (rhs.x or rhs), lhs.y - (rhs.y or rhs)) end,
	__mul = function(lhs, rhs) return vec2(lhs.x * (rhs.x or rhs), lhs.y * (rhs.y or rhs)) end,
	__div = function(lhs, rhs) return vec2(lhs.x / (rhs.x or rhs), lhs.y / (rhs.y or rhs)) end,
	__mod = function(lhs, rhs) return vec2(lhs.x % (rhs.x or rhs), lhs.y % (rhs.y or rhs)) end,
	__pow = function(lhs, rhs) return vec2(lhs.x ^ (rhs.x or rhs), lhs.y ^ (rhs.y or rhs)) end,
	__tostring = function(lhs) return string.format("vec2(%s,%s)",lhs.x,lhs.y) end,
	__le = function(lhs, rhs) return lhs.x <= rhs.x and lhs.y <= rhs.y end,
	__lt = function(lhs, rhs) return lhs.x < rhs.x and lhs.y < rhs.y end,
	__eq = function(lhs, rhs) return lhs.x == rhs.x and lhs.y == rhs.y end,
	
	length = function(lhs) return math.sqrt(lhs.x*lhs.x+lhs.y*lhs.y) end,
	distance = function(lhs, vec) return math.abs(math.sqrt((lhs.x-vec.x)^2+(lhs.y-vec.y)^2)) end,
	dot_product = function(lhs, vec) return lhs.x*vec.x+lhs.y*vec.y end,	
	angle_tan = function(lhs, vec)	return math.deg(math.atan2( vec:length(), lhs:length())) end,
	angle_cos = function(lhs, vec)	return math.deg(math.acos(lhs:dot_product(vec)/(lhs:length()*vec:length()))) end,
	normalize = function(lhs) return vec2(lhs.x/lhs:length(),lhs.y/lhs:length()) end,
	vertical = function(lhs, pos, val)
		
	 //perpendecular line from two vectors
	 
	end,
	rotate = function(lhs, ang) 
		
		local ang = math.rad(ang)
		local c = math.cos(ang)
		local s = math.sin(ang)
		
		return vec2(lhs.x*c-lhs.y*s,lhs.x*s+lhs.y*c)
		 
	end,
	
	rotate_around_axis = function(lhs, ang, pos) 
		
		local ang = math.rad(ang)
		local c = math.cos(ang)
		local s = math.sin(ang)
		
		return vec2((pos.x+lhs.x)*c-(pos.y+lhs.y)*s,(pos.x+lhs.x)*s+(pos.y+lhs.y)*c)
		--return pos+vec2(lhs.x*c-lhs.y*s,lhs.x*s+lhs.y*c)
	end,
}

vec2 = function(x, y)
	
	return setmetatable({x = math.Round(x or 0,4), y = math.Round(y or x or 0,4)}, META)
	
end

print(vec2(1,0):rotate(49))
print(vec2(0,1):rotate(49))
