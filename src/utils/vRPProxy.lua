---
--- This function is taken from https://github.com/ImagicTheCat/vRP/blob/master/vrp/lib/utils.lua
--- All sources goes to vRP
--- https://github.com/ImagicTheCat/vRP
--- MIT license (see LICENSE or vrp/vRPShared.lua)
---

local modules = {}

function module(rsc, path)
    if not path then -- shortcut for vrp, can omit the resource parameter
        path = rsc
        rsc = "vrp"
    end
    local key = rsc.."/"..path
    local rets = modules[key]
    if rets then -- cached module
        return table.unpack(rets, 2, rets.n)
    else
        local code = LoadResourceFile(rsc, path..".lua")
        if code then
            local f, err = load(code, rsc.."/"..path..".lua")
            if f then
                local rets = table.pack(xpcall(f, debug.traceback))
                if rets[1] then
                    modules[key] = rets
                    return table.unpack(rets, 2, rets.n)
                else
                    return nil;
                end
            else
                return nil;
            end
        else
            return nil;
        end
    end
end