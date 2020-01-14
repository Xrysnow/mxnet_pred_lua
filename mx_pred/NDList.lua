---@class mx.NDList
local M = require('mx_pred.base').class('mx.NDList')

local ffi = require('ffi')
local _b = require('mx_pred.base')
local _LIB, check_call = _b._LIB, _b.check_call

local function cdata(type)
    return ffi.new(type)
end

function M:ctor(file_bytes, file_size)
    if file_size == nil and type(file_bytes) == 'string' then
        file_size = #file_bytes
    end
    assert(file_size > 0)
    local hdl = cdata('void*[1]')
    local size = cdata('unsigned int[1]')
    check_call(_LIB.MXNDListCreate(file_bytes, file_size, hdl, size))
    self.handle = hdl[0]
    self.size = size[0]
    self._data = {}
    for i = 1, self.size do
        local key = cdata('const char*[1]')
        local dat = cdata('const float*[1]')
        local shape = cdata('const unsigned int*[1]')
        local ndim = cdata('unsigned int[1]')
        check_call(_LIB.MXNDListGet(self.handle, i - 1, key, dat, shape, ndim))
        if _b.isnullptr(key[0]) then
            key = nil
        else
            key = ffi.string(key[0])
        end
        dat = dat[0]
        local s = {}
        for j = 1, ndim[0] do
            table.insert(s, shape[0][j - 1])
        end
        table.insert(self._data, { key, dat, s })
    end
end

function M:dtor()
    check_call(_LIB.MXNDListFree(self.handle))
end

function M:get(key_or_index)
    if type(key_or_index) == 'string' then
        for i, v in ipairs(self._data) do
            if key_or_index == v[1] then
                return v[2], v[3]
            end
        end
    elseif type(key_or_index) == 'number' then
        local v = self._data[key_or_index + 1]
        if v then
            return v[2], v[3]
        end
    end
    -- no result
end

function M.create(file_bytes, file_size)
    return M(file_bytes, file_size)
end

return M
