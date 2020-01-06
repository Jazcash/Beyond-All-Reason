
-- see alldefs.lua for documentation
-- load the games _Post functions for defs, and find out if saving to custom params is wanted
VFS.Include("gamedata/alldefs_post.lua")
-- load functionality for saving to custom params
VFS.Include("gamedata/post_save_to_customparams.lua")

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- adjusted tablemerge: converts string 'nil' to an actual nil
function tableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        elseif v == 'nil' then
            t1[k] = nil
        else
            t1[k] = v
        end
    end
    return t1
end

-- handle unba modoption
if (Spring.GetModOptions) and Spring.GetModOptions().unba and Spring.GetModOptions().unba == "enabled" then
	VFS.Include("gamedata/unbaconfigs/unbacom_post.lua")
	VFS.Include("gamedata/unbaconfigs/stats.lua")
	VFS.Include("gamedata/unbaconfigs/buildoptions.lua")
	UnbaCom_Post("armcom")
	UnbaCom_Post("corcom")
end

-- create scavenger units
if Spring.GetModOptions and (tonumber(Spring.GetModOptions().scavengers) or 0) ~= 0 then
    VFS.Include("gamedata/scavengers/unitdef_changes.lua")
    local scavengerUnitDefs = {}
     for name,uDef in pairs(UnitDefs) do
         local faction = string.sub(name, 1, 3)
         if faction == 'arm' or faction == 'cor' then
             if customDefs[name] ~= nil then
                 scavengerUnitDefs[name..'_scav'] = tableMerge(deepcopy(uDef), deepcopy(customDefs[name]))
             else
                 scavengerUnitDefs[name..'_scav'] = deepcopy(uDef)
             end
         end
     end
     for name,ud in pairs(scavengerUnitDefs) do
         UnitDefs[name] = ud
     end
end

-- handle unitdefs and the weapons they contain
for name,ud in pairs(UnitDefs) do
  UnitDef_Post(name,ud)
  if ud.weapondefs then
	for wname,wd in pairs(ud.weapondefs) do
	  WeaponDef_Post(wname,wd)
	end
  end 
  
  --ud.acceleration = 0.75
  --ud.turnrate = 800
  
  if SaveDefsToCustomParams then
      SaveDefToCustomParams("UnitDefs", name, ud)    
  end
end