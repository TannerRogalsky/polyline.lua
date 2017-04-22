# Polyline.lua

This is an implementation of [Love's](love2d.org) line drawing algorithm in pure Lua. The API was designed with Love's Mesh API in mind but the output is pure vertex data and could be adapted to other uses.

## API
The API is a single function.
```lua
local vertices, indices, draw_mode = polyline(join_type, coords, half_width, pixel_size, draw_overdraw)
```

### Arguments
* join_type: One of Love's 3 line join types: https://love2d.org/wiki/LineJoin
* coords: A table of control points for the line. Example: `{x1, y1, x2, y2, x3, y3}` or `{5, 5, 10, 10}`
* half_width: Half of the line's desired width.
* pixel_size: Dimension of one pixel on the screen in world coordinates. Used for fake antialiasing.
* draw_overdraw: Fake antialias the line. (rough or smooth lines)

The equivalents to these parameters in Love's API is as follows:
```lua
polyline(g.getLineJoin(), coords, g.getLineWidth() / 2, 1/scale, g.getLineStyle() == 'smooth')
```
Scale being the current graphics scale which is not exposed via API.

## Why would I use this?
This method of getting and drawing a single line is slower than using Love's API but there are a few reasons to use instead of Love's API.

1. You want to draw the same set of lines multiple times. Create and cache the meshes.
2. You want to interact with the line's UVs or color values. If you want to texture, color or otherwise interact with the line, you may modify the vertices before applying them to a mesh.


## Examples

To see these examples live, please run `main.lua` using Love.

```lua
do -- Treat the line as a mask for an image, it's UVs match the bounding box of the texture
  local vertices = polyline('miter', coords, 3, 1/scale, true)
  for _,vertex in ipairs(vertices) do
    vertex[3] = vertex[1] / w
    vertex[4] = vertex[2] / h
  end
  texturedMesh1 = g.newMesh(vertices, 'strip')
  texturedMesh1:setTexture(image)
end

do -- texture each quad in a none join line with an image
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

do -- create a color gradient on a line
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
```
