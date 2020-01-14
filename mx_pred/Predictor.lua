---@class mx.Predictor
local M = require('mx_pred.base').class('mx.Predictor')

local ffi = require('ffi')
local _b = require('mx_pred.base')
local _LIB, check_call = _b._LIB, _b.check_call

local function cdata(type)
    return ffi.new(type)
end

local function proc_named_shape(named_shape)
    local shape_data = {}
    -- argument shape index in sdata,
    -- e.g. [sdata[indptr[0]], sdata[indptr[1]]) is the shape of the first arg
    local shape_idx = { 0 }
    local shape_names = {}
    local shapes = {}
    if #named_shape > 0 then
        -- list
        for _, vv in ipairs(named_shape) do
            local k, v = vv[1], vv[2]
            table.insert(shape_names, k)
            for _, s in ipairs(v) do
                table.insert(shape_data, s)
            end
            table.insert(shape_idx, #shape_data)
            table.insert(shapes, v)
        end
    else
        -- dict
        for k, v in pairs(named_shape) do
            table.insert(shape_names, k)
            for _, s in ipairs(v) do
                table.insert(shape_data, s)
            end
            table.insert(shape_idx, #shape_data)
            table.insert(shapes, v)
        end
    end
    return shape_names, shape_idx, shape_data, shapes
end

local function proc_dev_str(s)
    if s == nil or s == '' then
        return 1, 0
    end
    if s:match('^cpu') then
        local id = tonumber(s:sub(4)) or 0
        return 1, id
    elseif s:match('^gpu') then
        local id = tonumber(s:sub(4)) or 0
        return 2, id
    end
    error('invalid device string')
end

local function uint_buf(arr)
    local b = cdata(('unsigned int[%d]'):format(#arr))
    for i, v in ipairs(arr) do
        b[i - 1] = v
    end
    return b
end

local function c_str_array(strs)
    local arr = cdata(('const char*[%d]'):format(#strs))
    for i = 1, #strs do
        arr[i - 1] = strs[i]
    end
    return arr
end

local function new_handle(json_str, param_bytes, param_size, dev_type, dev_id,
                          named_shape)
    local hdl = cdata('void*[1]')
    param_bytes = ffi.cast('const void*', param_bytes)
    local shape_names, shape_idx, shape_data, shapes = proc_named_shape(named_shape)
    check_call(_LIB.MXPredCreate(json_str, param_bytes, param_size, dev_type, dev_id,
                                 #shape_names, c_str_array(shape_names),
                                 uint_buf(shape_idx), uint_buf(shape_data),
                                 hdl))
    return hdl[0], shape_names, shapes
end

local function t_clone(t)
    local ret = {}
    for k, v in pairs(t) do
        ret[k] = v
    end
    return ret
end

local function t_prod(t)
    if #t == 0 then
        return 0
    end
    local p = 1
    for _, v in ipairs(t) do
        p = p * v
    end
    return p
end

local function t_count(t)
    local c = 0
    for _, _ in pairs(t) do
        c = c + 1
    end
    return c
end

function M:ctor(hdl, shape_names, shapes)
    assert(hdl)
    self.handle = hdl
    -- input
    self.in_names = shape_names
    self.in_shapes = shapes
    self.in_ns = {}
    for i = 1, #shape_names do
        self.in_ns[shape_names[i]] = shapes[i]
    end
    self.in_sizes = {}
    for _, s in ipairs(self.in_shapes) do
        table.insert(self.in_sizes, t_prod(s))
    end
    -- output
    self.out_shapes = {}
    local ii = 0
    while true do
        local ok, ret = pcall(self._getOutputShape, self, ii)
        if ok then
            table.insert(self.out_shapes, ret)
            ii = ii + 1
        else
            break
        end
    end
    self.out_sizes = {}
    for _, s in ipairs(self.out_shapes) do
        table.insert(self.out_sizes, t_prod(s))
    end
end

function M:dtor()
    check_call(_LIB.MXPredFree(self.handle))
end

function M:getReshaped(in_shapes)
    local shape_names, shape_idx, shape_data, shapes = proc_named_shape(in_shapes)
    local hdl = cdata('void*[1]')
    check_call(_LIB.MXPredReshape(#shape_names, c_str_array(shape_names),
                                  uint_buf(shape_idx), uint_buf(shape_data),
                                  self.handle, hdl))
    return M(hdl[0], shape_names, shapes)
end

function M:_getInputIndex(name)
    assert(self.in_ns[name])
    for i, v in ipairs(self.in_names) do
        if v == name then
            name = i
            break
        end
    end
    return name
end

function M:_getOutputShape(index)
    local shape_data = cdata('unsigned int*[1]')
    local shape_ndim = cdata('unsigned int[1]')
    check_call(_LIB.MXPredGetOutputShape(self.handle, index,
                                         shape_data, shape_ndim))
    shape_ndim = shape_ndim[0]
    shape_data = shape_data[0]
    local ret = {}
    for i = 1, shape_ndim do
        table.insert(ret, tonumber(shape_data[i - 1]))
    end
    return ret
end

function M:getOutputShapes()
    local t = {}
    for i, v in ipairs(self.out_shapes) do
        t[i] = t_clone(v)
    end
    return t
end

function M:getOutputSizes()
    return t_clone(self.out_sizes)
end

function M:getInputSizes()
    return t_clone(self.in_sizes)
end

function M:setInput(key, data, size)
    if type(key) == 'number' then
        key = self.in_names[key + 1]
    end
    if size == nil then
        size = self.in_sizes[self:_getInputIndex(key)]
    end
    assert(size >= 0 and self.in_ns[key])
    check_call(_LIB.MXPredSetInput(self.handle, tostring(key), data, size))
end

function M:forward()
    check_call(_LIB.MXPredForward(self.handle))
end

function M:getOutput(index, data, size)
    assert(index >= 0 and index < #self.out_shapes)
    if size == nil then
        size = self.out_sizes[index + 1]
    end
    assert(size >= 0)
    check_call(_LIB.MXPredGetOutput(self.handle, index, data, size))
end

function M:__call(...)
    local inputs = { ... }
    if #inputs == 1 and type(inputs[1]) == 'table' then
        -- dict
        assert(t_count(inputs) == #self.in_names, 'number of inputs mismatch')
        for k, v in pairs(inputs[1]) do
            self:setInput(k, v)
        end
    else
        assert(#inputs > 0, 'need input')
        for i, v in ipairs(inputs) do
            self:setInput(i - 1, v)
        end
    end
    self:forward()
    local function out(...)
        local outputs = { ... }
        assert(#outputs == #self.out_shapes, 'number of outputs mismatch')
        for i, v in ipairs(outputs) do
            self:getOutput(i - 1, v)
        end
    end
    return out
end

function M.create(sym_json, param_bytes, param_size, in_shapes, dev_str)
    local dev_type, dev_id = proc_dev_str(dev_str)
    return M(new_handle(sym_json, param_bytes, param_size, dev_type, dev_id, in_shapes))
end

return M
