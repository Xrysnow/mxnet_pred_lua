local ffi = require('ffi')

local header = [[

typedef unsigned int mx_uint;
typedef float mx_float;
typedef void *PredictorHandle;
typedef void *NDListHandle;

const char* MXGetLastError();

int MXPredCreate(const char* symbol_json_str,
                           const void* param_bytes,
                           int param_size,
                           int dev_type, int dev_id,
                           mx_uint num_input_nodes,
                           const char** input_keys,
                           const mx_uint* input_shape_indptr,
                           const mx_uint* input_shape_data,
                           PredictorHandle* out);

int MXPredCreatePartialOut(const char* symbol_json_str,
                                     const void* param_bytes,
                                     int param_size,
                                     int dev_type, int dev_id,
                                     mx_uint num_input_nodes,
                                     const char** input_keys,
                                     const mx_uint* input_shape_indptr,
                                     const mx_uint* input_shape_data,
                                     mx_uint num_output_nodes,
                                     const char** output_keys,
                                     PredictorHandle* out);

int MXPredCreateMultiThread(const char* symbol_json_str,
                                      const void* param_bytes,
                                      int param_size,
                                      int dev_type, int dev_id,
                                      mx_uint num_input_nodes,
                                      const char** input_keys,
                                      const mx_uint* input_shape_indptr,
                                      const mx_uint* input_shape_data,
                                      int num_threads,
                                      PredictorHandle* out);

int MXPredReshape(mx_uint num_input_nodes,
                  const char** input_keys,
                  const mx_uint* input_shape_indptr,
                  const mx_uint* input_shape_data,
                  PredictorHandle handle,
                  PredictorHandle* out);

int MXPredGetOutputShape(PredictorHandle handle,
                                   mx_uint index,
                                   mx_uint** shape_data,
                                   mx_uint* shape_ndim);

int MXPredSetInput(PredictorHandle handle,
                             const char* key,
                             const mx_float* data,
                             mx_uint size);

int MXPredForward(PredictorHandle handle);

int MXPredPartialForward(PredictorHandle handle, int step, int* step_left);

int MXPredGetOutput(PredictorHandle handle,
                              mx_uint index,
                              mx_float* data,
                              mx_uint size);

int MXPredFree(PredictorHandle handle);

int MXNDListCreate(const char* nd_file_bytes,
                             int nd_file_size,
                             NDListHandle *out,
                             mx_uint* out_length);

int MXNDListGet(NDListHandle handle,
                          mx_uint index,
                          const char** out_key,
                          const mx_float** out_data,
                          const mx_uint** out_shape,
                          mx_uint* out_ndim);

int MXNDListFree(NDListHandle handle);
]]

ffi.cdef(header)

print('start load libmxnet')

local lib
if ffi.os == 'Windows' then
    lib = ffi.load('libmxnet.dll')
else
    lib = ffi.load('libmxnet.so')
end

print('finish load libmxnet')

return lib
