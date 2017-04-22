local polyline = require('polyline')
local g = love.graphics

local coords = {10, 10, 40, 40, 30, 10, 10, 20, 10, 40, 30, 45}
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

function love.load()
  image = g.newImage('logo.png')
  do
    local vertices = polyline('miter', coords, 3, 1/scale, true)
    for _,vertex in ipairs(vertices) do
      vertex[3] = vertex[1] / w
      vertex[4] = vertex[2] / h
    end
    texturedMesh1 = g.newMesh(vertices, 'strip')
    texturedMesh1:setTexture(image)
  end
  do
    local vertices, indices, draw_mode = polyline('none', coords, 3, 1/scale, false)
    for i=1,#vertices,4 do
      vertices[i + 0][3], vertices[i + 0][4] = 0, 0
      vertices[i + 1][3], vertices[i + 1][4] = 0, 1
      vertices[i + 2][3], vertices[i + 2][4] = 1, 1
      vertices[i + 3][3], vertices[i + 3][4] = 1, 0
    end
    texturedMesh2 = g.newMesh(vertices, draw_mode)
    texturedMesh2:setVertexMap(indices)
    texturedMesh2:setTexture(image)
  end
  do
    local vertices = polyline('miter', coords, 3, 1/scale, true)
    for i,vertex in ipairs(vertices) do
      vertex[3] = i % 2
    end
    shaderMesh1 = g.newMesh(vertices, 'strip')
    shader = g.newShader([[
      vec4 effect(vec4 c, Image t, vec2 uv, vec2 sc) {
        return c * cos(uv.x * 6.28);
      }
    ]])
  end
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

  g.draw(image, w * 0, h * 2, 0, w / image:getWidth(), h / image:getHeight())
  g.draw(texturedMesh1, w * 1, h * 2)
  g.draw(texturedMesh2, w * 2, h * 2)

  g.setShader(shader)
  g.draw(shaderMesh1, w * 3, h * 2)
  g.setShader()
end
