--
local M = {}
local ffi = require('ffi')

--

M.__version__ = '1.5.0'
local _LIB = require('mx_pred.c_api')
M._LIB = _LIB

function M.check_call(ret)
    if ret ~= 0 then
        error(ffi.string(_LIB.MXGetLastError()))
    end
end

function M.isnullptr(p)
    return not (ffi.cast('void*', p) > nil)
end

--

local setmetatableindex_
setmetatableindex_ = function(t, index)
    if type(t) == "userdata" then
        local peer = tolua.getpeer(t)
        if not peer then
            peer = {}
            tolua.setpeer(t, peer)
        end
        setmetatableindex_(peer, index)
    else
        local mt = getmetatable(t)
        if not mt then
            mt = {}
        end
        if not mt.__index then
            mt.__index = index
            setmetatable(t, mt)
        elseif mt.__index ~= index then
            setmetatableindex_(mt, index)
        end
    end
end
local setmetatableindex = setmetatableindex_

local function dtor_proxy(ins, dtor)
    if dtor then
        ins['.dtor_proxy'] = ffi.gc(
                ffi.new('int32_t[0]'),
                function()
                    dtor(ins)
                end
        )
    end
end

function M.class(classname)
    local cls = { __cname = classname }

    cls.__index = cls
    local __call = function(_, ...)
        return cls.new(...)
    end

    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, { __index = cls.super, __call = __call })
    else
        setmetatable(cls, {
            __index = function(_, key)
                local supers_ = cls.__supers
                for i = 1, #supers_ do
                    local super = supers_[i]
                    if super[key] then
                        return super[key]
                    end
                end
            end,
            __call  = __call })
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function()
        end
    end
    local meta_method
    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)

        instance['.class'] = cls
        instance['.classname'] = classname
        -- for super is native class
        if not instance.super then
            instance.super = {}
            setmetatable(instance.super, {
                __index = function(_, k)
                    local log = cls[k]
                    cls[k] = nil
                    local ret = instance[k]
                    cls[k] = log
                    return ret
                end
            })
        end
        local mt = getmetatable(instance)
        -- set once
        if not meta_method then
            meta_method = {}
            for _, v in ipairs(
                    { '__add', '__sub', '__mul', '__div', '__mod', '__pow', '__unm',
                      '__concat', '__len', '__eq', '__lt', '__le',
                      '__index', '__newindex', '__call', '__tostring', '__tonumber' }) do
                meta_method[v] = instance[v]
            end
        end
        for k, v in pairs(meta_method) do
            rawset(mt, k, v)
        end
        mt.__supers = cls.__supers
        mt.__cname = cls.__cname
        dtor_proxy(instance, cls.dtor)
        instance:ctor(...)
        return instance
    end
    cls.create = function(_, ...)
        return cls.new(...)
    end

    return cls
end

return M
