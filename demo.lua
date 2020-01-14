local ffi = require('ffi')
local mx = require('mxnet_pred')

local classes = { 'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', 'boat', 'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench', 'bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe', 'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee', 'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard', 'tennis racket', 'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple', 'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch', 'potted plant', 'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse', 'remote', 'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear', 'hair drier', 'toothbrush' }

-- get from gluoncv:
--[[
from gluoncv import model_zoo, data, utils

net = model_zoo.get_model('yolo3_darknet53_coco', pretrained=True)
utils.export_block('yolo3_darknet53_coco', net)
]]
local json_file = 'yolo3_darknet53_coco-symbol.json'
local param_file = 'yolo3_darknet53_coco-0000.params'
-- get from mxnet:
--[[
import mxnet as mx
from gluoncv import utils

utils.download('https://raw.githubusercontent.com/zhreshold/' +
                          'mxnet-ssd/master/data/demo/dog.jpg',
                          path='dog.jpg')
im = mx.image.imread('dog.jpg')
im = mx.image.resize_short(im, 512).astype('float32')
mx.nd.save('dog_f32_512.nd', im)
]]
local data_file = 'dog_f32_512.nd'
local in_shape = { 512, 682, 3 }

local function readfile(path)
    local file = io.open(path, "rb")
    if file then
        local sz = file:seek('end', 0)
        file:seek('set', 0)
        local content = file:read(sz)
        file:close()
        return content, #content
    end
    error('failed to load ' .. path)
end

print('read files...')
local json = readfile(json_file)
local param, param_sz = readfile(param_file)
local data, data_sz = readfile(data_file)

print('create predictor...')
local pred = mx.pred(json, param, param_sz, { data = in_shape })
print('read data...')
local nd = mx.nd(data, data_sz)

local shapes = pred:getOutputShapes()
local sizes = pred:getOutputSizes()

print('output shape:')
for i, v in ipairs(shapes) do
    print('', ('%d: [%s]'):format(i, table.concat(v, ', ')))
end

print('allocate output...')
local out = {}
for _, v in ipairs(sizes) do
    table.insert(out, ffi.new(('float[%d]'):format(v)))
end

local d, d_shape = nd:get(0)

print(('data shape: [%s]'):format(table.concat(d_shape, ', ')))

pred(d)(unpack(out))

local class_id, score, bbox = unpack(out)

local ret = {}
for i = 1, 100 do
    local s = tonumber(score[i - 1])
    if s > 0.5 then
        table.insert(ret, { classes[class_id[i - 1] + 1], s })
    else
        break
    end
end

print('result:')
for _, v in ipairs(ret) do
    print('', v[1], v[2])
end

-- will output:
--[[
start load libmxnet
finish load libmxnet
read files...
create predictor...
read data...
output shape:
        1: [1, 100, 1]
        2: [1, 100, 1]
        3: [1, 100, 4]
allocate output...
data shape: [512, 682, 3]
result:
        dog     0.99185216426849
        bicycle 0.94232738018036
        truck   0.64780813455582
]]
