if AC == nil then
  print ( 'Init AC' )
  AC = {}
  AC.__index = AC
end

local test_table = {
}	

local sol = RandomInt(1, 50000)



local tst = LoadKeyValues('scripts/npc/items.txt')

for i,x in pairs(tst) do 
	if i and x and type(x) == "table" then
		if x['ItemCost'] then
			test_table[i] = x['ItemCost']
		else
			test_table[i] = 0
		end
	end
end

tst = LoadKeyValues('scripts/npc/npc_items_custom.txt')

for i,x in pairs(tst) do 
	if i and x and type(x) == "table" then
		if x['ItemCost'] then
			test_table[i] = x['ItemCost']
		else
			if not test_table[i] then
				test_table[i] = 0
			end
		end
	end
end



function AddSol()
	for i,x in pairs(test_table) do
		test_table[i] = x + sol
	end

	test_table.sol = sol
end

AddSol()

function AC:GetItemCost(item_name)
	if test_table[item_name] then
		return test_table[item_name] - test_table.sol
	end
end

return test_table