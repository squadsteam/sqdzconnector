FXServer = {}

serverFrameworkType = nil;
frameworkTable = nil;
additionalData = {}

function FXServer:getFramework()
    local Proxy = module("vrp", "lib/Proxy")

    if (serverFrameworkType ~= nil) then
        return serverFrameworkType
    end

    if Proxy ~= nil then
        local vRP = Proxy.getInterface("vRP")
        local MySQL = module("vrp_mysql", "MySQL")
        if (type(MySQL.asyncQuery) == 'nil') then
            MySQL.asyncQuery = function(name, data)
                local p = promise.new()
                MySQL.query(name, data,function(result)
                    p:resolve(result)
                end)

                return Citizen.Await(p)
            end
        end
        additionalData['MySQL'] = MySQL;

        serverFrameworkType = 'vRP';
        frameworkTable = vRP;

        self:getHandler():setup()
        return serverFrameworkType;
    end

    local QBCore = exports['qb-core']

    local val, err = pcall(function()
        QBCore.GetCoreObject()
    end)
    if (err) then
        QBCore = null;
    else
        QBCore = val;
    end

    if QBCore ~= nil then
        serverFrameworkType = 'QBCore';
        frameworkTable = exports['qb-core']:GetCoreObject();
        return serverFrameworkType;
    end

    local customQBCore = Config:get('qbcore.custom_resource_name', nil)
    if (customQBCore ~= nil and GetResourceState(customQBCore)) then
        local d = promise.new()
        TriggerEvent('QBCore:GetObject', function(obj)
            QBCore = obj
            serverFrameworkType = 'QBCore';
            frameworkTable = QBCore;

            return d:resolve(serverFrameworkType)
        end)

        return Citizen.Await(d)
    end

    return nil;
end

function FXServer:getHandler()
    if (serverFrameworkType == 'vRP') then
        return vRPHandler
    elseif (serverFrameworkType == 'QBCore') then
        return QBCoreHandler
    end
end

function FXServer:getFrameworkAPI()
    return frameworkTable
end

function FXServer:getAdditionalData(key)
    return additionalData[key];
end