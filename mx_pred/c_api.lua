--
local M = {}
local _lib = require('mx_pred.lib')
local function _f()
end
local _TYPEDEF = _f
local _ENUMDEF = _f
local _CALL = function(name, ...)
    return _lib[name](...)
end
local _FUNCDEF = _f

--

-- header/c_predict_api.h

--

---@brief manually define unsigned int
_TYPEDEF("mx_uint", "unsigned int")

--

---@brief manually define float
_TYPEDEF("mx_float", "float")

--

---@brief handle to Predictor
_TYPEDEF("PredictorHandle", "void *")

--

---@brief handle to NDArray list
_TYPEDEF("NDListHandle", "void *")

--

---
---@brief return str message of the last error
--- all function in this file will return 0 when success
--- and -1 when an error occured,
--- MXGetLastError can be called to retrieve the error
---
--- this function is threadsafe and can be called by different thread
---@return string @(const char *) error info
---
function M.MXGetLastError()
    return _CALL("MXGetLastError")
end
_FUNCDEF("MXGetLastError", {  }, "const char *")

--

---
---@brief create a predictor
---@param symbol_json_str string @(const char *) The JSON string of the symbol.
---@param param_bytes number @(const void *) The in-memory raw bytes of parameter ndarray file.
---@param param_size number @(int) The size of parameter ndarray file.
---@param dev_type number @(int) The device type, 1: cpu, 2:gpu
---@param dev_id number @(int) The device id of the predictor.
---@param num_input_nodes number @(mx_uint) Number of input nodes to the net,
---    For feedforward net, this is 1.
---@param input_keys number @(const char * *) The name of input argument.
---    For feedforward net, this is {"data"}
---@param input_shape_indptr number @(const mx_uint *) Index pointer of shapes of each input node.
---    The length of this array = num_input_nodes + 1.
---    For feedforward net that takes 4 dimensional input, this is {0, 4}.
---@param input_shape_data number @(const mx_uint *) A flattened data of shapes of each input node.
---    For feedforward net that takes 4 dimensional input, this is the shape data.
---@param out number @(PredictorHandle *) The created predictor handle.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredCreate(symbol_json_str, param_bytes, param_size, dev_type, dev_id, num_input_nodes, input_keys, input_shape_indptr, input_shape_data, out)
    return _CALL("MXPredCreate", symbol_json_str, param_bytes, param_size, dev_type, dev_id, num_input_nodes, input_keys, input_shape_indptr, input_shape_data, out)
end
_FUNCDEF("MXPredCreate", { "const char *", "const void *", "int", "int", "int", "mx_uint", "const char * *", "const mx_uint *", "const mx_uint *", "PredictorHandle *" }, "int")

--

---
---@brief create a predictor wich customized outputs
---@param symbol_json_str string @(const char *) The JSON string of the symbol.
---@param param_bytes number @(const void *) The in-memory raw bytes of parameter ndarray file.
---@param param_size number @(int) The size of parameter ndarray file.
---@param dev_type number @(int) The device type, 1: cpu, 2:gpu
---@param dev_id number @(int) The device id of the predictor.
---@param num_input_nodes number @(mx_uint) Number of input nodes to the net,
---    For feedforward net, this is 1.
---@param input_keys number @(const char * *) The name of input argument.
---    For feedforward net, this is {"data"}
---@param input_shape_indptr number @(const mx_uint *) Index pointer of shapes of each input node.
---    The length of this array = num_input_nodes + 1.
---    For feedforward net that takes 4 dimensional input, this is {0, 4}.
---@param input_shape_data number @(const mx_uint *) A flattened data of shapes of each input node.
---    For feedforward net that takes 4 dimensional input, this is the shape data.
---@param num_output_nodes number @(mx_uint) Number of output nodes to the net,
---@param output_keys number @(const char * *) The name of output argument.
---    For example {"global_pool"}
---@param out number @(PredictorHandle *) The created predictor handle.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredCreatePartialOut(symbol_json_str, param_bytes, param_size, dev_type, dev_id, num_input_nodes, input_keys, input_shape_indptr, input_shape_data, num_output_nodes, output_keys, out)
    return _CALL("MXPredCreatePartialOut", symbol_json_str, param_bytes, param_size, dev_type, dev_id, num_input_nodes, input_keys, input_shape_indptr, input_shape_data, num_output_nodes, output_keys, out)
end
_FUNCDEF("MXPredCreatePartialOut", { "const char *", "const void *", "int", "int", "int", "mx_uint", "const char * *", "const mx_uint *", "const mx_uint *", "mx_uint", "const char * *", "PredictorHandle *" }, "int")

--

---
---@brief create predictors for multiple threads. One predictor for a thread.
---@param symbol_json_str string @(const char *) The JSON string of the symbol.
---@param param_bytes number @(const void *) The in-memory raw bytes of parameter ndarray file.
---@param param_size number @(int) The size of parameter ndarray file.
---@param dev_type number @(int) The device type, 1: cpu, 2:gpu
---@param dev_id number @(int) The device id of the predictor.
---@param num_input_nodes number @(mx_uint) Number of input nodes to the net,
---    For feedforward net, this is 1.
---@param input_keys number @(const char * *) The name of input argument.
---    For feedforward net, this is {"data"}
---@param input_shape_indptr number @(const mx_uint *) Index pointer of shapes of each input node.
---    The length of this array = num_input_nodes + 1.
---    For feedforward net that takes 4 dimensional input, this is {0, 4}.
---@param input_shape_data number @(const mx_uint *) A flattened data of shapes of each input node.
---    For feedforward net that takes 4 dimensional input, this is the shape data.
---@param num_threads number @(int) The number of threads that we'll run the predictors.
---@param out number @(PredictorHandle *) An array of created predictor handles. The array has to be large
---   enough to keep `num_threads` predictors.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredCreateMultiThread(symbol_json_str, param_bytes, param_size, dev_type, dev_id, num_input_nodes, input_keys, input_shape_indptr, input_shape_data, num_threads, out)
    return _CALL("MXPredCreateMultiThread", symbol_json_str, param_bytes, param_size, dev_type, dev_id, num_input_nodes, input_keys, input_shape_indptr, input_shape_data, num_threads, out)
end
_FUNCDEF("MXPredCreateMultiThread", { "const char *", "const void *", "int", "int", "int", "mx_uint", "const char * *", "const mx_uint *", "const mx_uint *", "int", "PredictorHandle *" }, "int")

--

---
---@brief Change the input shape of an existing predictor.
---@param num_input_nodes number @(mx_uint) Number of input nodes to the net,
---    For feedforward net, this is 1.
---@param input_keys number @(const char * *) The name of input argument.
---    For feedforward net, this is {"data"}
---@param input_shape_indptr number @(const mx_uint *) Index pointer of shapes of each input node.
---    The length of this array = num_input_nodes + 1.
---    For feedforward net that takes 4 dimensional input, this is {0, 4}.
---@param input_shape_data number @(const mx_uint *) A flattened data of shapes of each input node.
---    For feedforward net that takes 4 dimensional input, this is the shape data.
---@param handle number @(PredictorHandle) The original predictor handle.
---@param out number @(PredictorHandle *) The reshaped predictor handle.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredReshape(num_input_nodes, input_keys, input_shape_indptr, input_shape_data, handle, out)
    return _CALL("MXPredReshape", num_input_nodes, input_keys, input_shape_indptr, input_shape_data, handle, out)
end
_FUNCDEF("MXPredReshape", { "mx_uint", "const char * *", "const mx_uint *", "const mx_uint *", "PredictorHandle", "PredictorHandle *" }, "int")

--

---
---@brief Get the shape of output node.
---  The returned shape_data and shape_ndim is only valid before next call to MXPred function.
---@param handle number @(PredictorHandle) The handle of the predictor.
---@param index number @(mx_uint) The index of output node, set to 0 if there is only one output.
---@param shape_data number @(mx_uint * *) Used to hold pointer to the shape data
---@param shape_ndim number @(mx_uint *) Used to hold shape dimension.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredGetOutputShape(handle, index, shape_data, shape_ndim)
    return _CALL("MXPredGetOutputShape", handle, index, shape_data, shape_ndim)
end
_FUNCDEF("MXPredGetOutputShape", { "PredictorHandle", "mx_uint", "mx_uint * *", "mx_uint *" }, "int")

--

---
---@brief Set the input data of predictor.
---@param handle number @(PredictorHandle) The predictor handle.
---@param key string @(const char *) The name of input node to set.
---     For feedforward net, this is "data".
---@param data number @(const mx_float *) The pointer to the data to be set, with the shape specified in MXPredCreate.
---@param size number @(mx_uint) The size of data array, used for safety check.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredSetInput(handle, key, data, size)
    return _CALL("MXPredSetInput", handle, key, data, size)
end
_FUNCDEF("MXPredSetInput", { "PredictorHandle", "const char *", "const mx_float *", "mx_uint" }, "int")

--

---
---@brief Run a forward pass to get the output.
---@param handle number @(PredictorHandle) The handle of the predictor.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredForward(handle)
    return _CALL("MXPredForward", handle)
end
_FUNCDEF("MXPredForward", { "PredictorHandle" }, "int")

--

---
---@brief Run a interactive forward pass to get the output.
---  This is helpful for displaying progress of prediction which can be slow.
---  User must call PartialForward from step=0, keep increasing it until step_left=0.
---@code
--- int step_left = 1;
--- for (int step = 0; step_left != 0; ++step) {
---    MXPredPartialForward(handle, step, &step_left);
---    printf("Current progress [%d/%d]\n", step, step + step_left + 1);
--- }
---@endcode
---@param handle number @(PredictorHandle) The handle of the predictor.
---@param step number @(int) The current step to run forward on.
---@param step_left number @(int *) The number of steps left
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredPartialForward(handle, step, step_left)
    return _CALL("MXPredPartialForward", handle, step, step_left)
end
_FUNCDEF("MXPredPartialForward", { "PredictorHandle", "int", "int *" }, "int")

--

---
---@brief Get the output value of prediction.
---@param handle number @(PredictorHandle) The handle of the predictor.
---@param index number @(mx_uint) The index of output node, set to 0 if there is only one output.
---@param data number @(mx_float *) User allocated data to hold the output.
---@param size number @(mx_uint) The size of data array, used for safe checking.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredGetOutput(handle, index, data, size)
    return _CALL("MXPredGetOutput", handle, index, data, size)
end
_FUNCDEF("MXPredGetOutput", { "PredictorHandle", "mx_uint", "mx_float *", "mx_uint" }, "int")

--

---
---@brief Free a predictor handle.
---@param handle number @(PredictorHandle) The handle of the predictor.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXPredFree(handle)
    return _CALL("MXPredFree", handle)
end
_FUNCDEF("MXPredFree", { "PredictorHandle" }, "int")

--

---
---@brief Create a NDArray List by loading from ndarray file.
---     This can be used to load mean image file.
---@param nd_file_bytes string @(const char *) The byte contents of nd file to be loaded.
---@param nd_file_size number @(int) The size of the nd file to be loaded.
---@param out number @(NDListHandle *) The out put NDListHandle
---@param out_length number @(mx_uint *) Length of the list.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXNDListCreate(nd_file_bytes, nd_file_size, out, out_length)
    return _CALL("MXNDListCreate", nd_file_bytes, nd_file_size, out, out_length)
end
_FUNCDEF("MXNDListCreate", { "const char *", "int", "NDListHandle *", "mx_uint *" }, "int")

--

---
---@brief Get an element from list
---@param handle number @(NDListHandle) The handle to the NDArray
---@param index number @(mx_uint) The index in the list
---@param out_key number @(const char * *) The output key of the item
---@param out_data number @(const mx_float * *) The data region of the item
---@param out_shape number @(const mx_uint * *) The shape of the item.
---@param out_ndim number @(mx_uint *) The number of dimension in the shape.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXNDListGet(handle, index, out_key, out_data, out_shape, out_ndim)
    return _CALL("MXNDListGet", handle, index, out_key, out_data, out_shape, out_ndim)
end
_FUNCDEF("MXNDListGet", { "NDListHandle", "mx_uint", "const char * *", "const mx_float * *", "const mx_uint * *", "mx_uint *" }, "int")

--

---
---@brief Free a MXAPINDList
---@param handle number @(NDListHandle) The handle of the MXAPINDList.
---@return number @(int) 0 when success, -1 when failure.
---
function M.MXNDListFree(handle)
    return _CALL("MXNDListFree", handle)
end
_FUNCDEF("MXNDListFree", { "NDListHandle" }, "int")

--

return M
