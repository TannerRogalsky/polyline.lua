local polyline = require('polyline')
local g = love.graphics

local coords = {10, 10, 40, 40, 30, 10, 10, 20}
-- local coords = {10, 10, 40, 40}
local mesh = g.newMesh(10000)

local w, h = 50, 50
local scale = 2

local function controlLine()
  g.line(coords)
end

local function testLine()
  local vertices, indices, draw_mode = polyline(g.getLineJoin(), coords, g.getLineWidth() / 2, 1/scale, g.getLineStyle() == 'smooth')
  mesh:setVertices(vertices)
  mesh:setDrawMode(draw_mode)
  mesh:setVertexMap(indices)
  if indices then
    mesh:setDrawRange(1, #indices)
  else
    mesh:setDrawRange(1, #vertices)
  end
  g.draw(mesh)
end

local ox, oy = 0, 0
local function pushPop(drawingFunction)
  g.push('all')
  g.translate(ox, oy)
  drawingFunction()
  g.pop()
  ox, oy = ox + w, oy + 0
end

function love.draw()
  ox, oy = 0, 0

  g.setWireframe(love.keyboard.isDown('space'))
  g.scale(scale)

  pushPop(function()
    g.setLineStyle('smooth')
    testLine()
    g.translate(0, h)
    controlLine()
  end)

  pushPop(function()
    g.setLineStyle('rough')
    testLine()
    g.translate(0, h)
    controlLine()
  end)

  pushPop(function()
    g.setLineStyle('rough')
    g.setLineJoin('none')
    g.setLineWidth(6)
    testLine()
    g.translate(0, 50)
    controlLine()
  end)

  pushPop(function()
    g.setLineStyle('rough')
    g.setLineJoin('miter')
    g.setLineWidth(3)
    testLine()
    g.translate(0, 50)
    controlLine()
  end)

  pushPop(function()
    g.setLineStyle('rough')
    g.setLineJoin('bevel')
    g.setLineWidth(6)
    testLine()
    g.translate(0, 50)
    controlLine()
  end)

  pushPop(function()
    g.setLineStyle('smooth')
    g.setLineJoin('none')
    g.setLineWidth(6)
    testLine()
    g.translate(0, 50)
    controlLine()
  end)

  pushPop(function()
    g.setLineStyle('smooth')
    g.setLineJoin('miter')
    g.setLineWidth(3)
    testLine()
    g.translate(0, 50)
    controlLine()
  end)

  pushPop(function()
    g.setLineStyle('smooth')
    g.setLineJoin('bevel')
    g.setLineWidth(6)
    testLine()
    g.translate(0, 50)
    controlLine()
  end)
end
