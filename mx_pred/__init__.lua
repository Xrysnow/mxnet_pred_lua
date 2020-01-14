--
local M = {}

require('mx_pred.base')
M.Predictor = require('mx_pred.Predictor')
M.NDList = require('mx_pred.NDList')

M.pred = M.Predictor.create
M.nd = M.NDList.create

return M
