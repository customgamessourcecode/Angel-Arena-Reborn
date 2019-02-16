_G.dir = function(table) 
	local res = ""
	for i,x in pairs(table) do
		res = res .. tostring(i) .. ": " .. tostring(x) .. ","

	end 
	
	return res.sub(0, #res-2)
end 