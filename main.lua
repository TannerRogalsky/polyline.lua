local polyline = require('polyline')
local g = love.graphics

local coords = {10, 10, 40, 40, 30, 10, 10, 20}

local vertices = polyline('bevel', coords, 3, 1, false)
local mesh = g.newMesh(vertices, 'strip')

local w, h = 50, 50

local function testLine()
  g.line(coords)
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
  pushPop(function()
    testLine()
  end)

  pushPop(function()
    g.setLineStyle('smooth')
    testLine()
  end)

  pushPop(function()
    g.setLineStyle('rough')
    testLine()
  end)

  g.draw(mesh, 200, 200)

  g.push('all')
  g.setLineStyle('rough')
  g.setLineJoin('bevel')
  g.setLineWidth(6)
  g.translate(150, 200)
  testLine()
  g.pop()
end
