local LINES_PARALLEL_EPS = 0.05;

local function Vector(x, y)
  if y then
    return {x = x, y = y}
  else -- clone vector
    return {x = x.x, y = x.y}
  end
end

local function length(vector)
  return math.sqrt(vector.x * vector.x + vector.y * vector.y)
end

local function normal(out, vector, scale)
  out.x = -vector.y * scale
  out.y = vector.x * scale
  return out
end

local function cross(x1, y1, x2, y2)
  return x1 * y2 - y1 * x2
end

local function printv(vector)
  print(vector.x, vector.y)
end

local function renderEdgeNone(anchors, normals, s, len_s, ns, q, r, hw)
  table.insert(anchors, Vector(q))
  table.insert(anchors, Vector(q))
  table.insert(normals, Vector(ns))
  table.insert(normals, Vector(-ns.x, -ns.y))

  s.x, s.y = r.x - q.x, r.y - q.y
  len_s = length(s)
  normal(ns, s, hw / len_s)

  table.insert(anchors, Vector(q))
  table.insert(anchors, Vector(q))
  table.insert(normals, Vector(ns))
  table.insert(normals, Vector(-ns.x, -ns.y))

  return len_s
end

local function renderEdgeMiter(anchors, normals, s, len_s, ns, q, r, hw)
  local tx, ty = r.x - q.x, r.y - q.y
  local len_t = math.sqrt(tx * tx + ty * ty)
  local ntx, nty = -ty * (hw / len_t), tx * (hw / len_t)

  table.insert(anchors, Vector(q))
  table.insert(anchors, Vector(q))

  local det = cross(s.x, s.y, tx, ty)
  if (math.abs(det) / (len_s * len_t) < LINES_PARALLEL_EPS) and (s.x * tx + s.y * ty > 0) then
    -- lines parallel, compute as u1 = q + ns * w/2, u2 = q - ns * w/2
    table.insert(normals, Vector(ns))
    table.insert(normals, Vector(-ns.x, -ns.y))
  else
    -- cramers rule
    local nx, ny = ntx - ns.x, nty - ns.y
    local lambda = cross(nx, ny, tx, ty) / det
    local dx, dy = ns.x + (s.x * lambda), ns.y + (s.y * lambda)

    table.insert(normals, Vector(dx, dy))
    table.insert(normals, Vector(-dx, -dy))
  end

  s.x, s.y = tx, ty
  ns.x, ns.y = ntx, nty
  return len_t
end

local function renderEdgeBevel(anchors, normals, s, len_s, ns, q, r, hw)
  local tx, ty = r.x - q.x, r.y - q.y
  local len_t = math.sqrt(tx * tx + ty * ty)
  local ntx, nty = -ty * (hw / len_t), tx * (hw / len_t)

  local det = cross(s.x, s.y, tx, ty)
  if (math.abs(det) / (len_s * len_t) < LINES_PARALLEL_EPS) and (s.x * tx + s.y * ty > 0) then
    -- lines parallel, compute as u1 = q + ns * w/2, u2 = q - ns * w/2
    table.insert(anchors, Vector(q))
    table.insert(anchors, Vector(q))
    table.insert(normals, Vector(ntx, nty))
    table.insert(normals, Vector(-ntx, -nty))

    s.x, s.y = tx, ty
    return len_t -- early out
  end

  -- cramers rule
  local nx, ny = ntx - ns.x, nty - ns.y
  local lambda = cross(nx, ny, tx, ty) / det
  local dx, dy = ns.x + (s.x * lambda), ns.y + (s.y * lambda)

  table.insert(anchors, Vector(q))
  table.insert(anchors, Vector(q))
  table.insert(anchors, Vector(q))
  table.insert(anchors, Vector(q))
  if det > 0 then -- 'left' turn
    table.insert(normals, Vector(dx, dy))
    table.insert(normals, Vector(-ns.x, -ns.y))
    table.insert(normals, Vector(dx, dy))
    table.insert(normals, Vector(-ntx, -nty))
  else
    table.insert(normals, Vector(ns.x, ns.y))
    table.insert(normals, Vector(-dx, -dy))
    table.insert(normals, Vector(ntx, nty))
    table.insert(normals, Vector(-dx, -dy))
  end

  s.x, s.y = tx, ty
  ns.x, ns.y = ntx, nty
  return len_t
end

local JOIN_TYPES = {
  miter = renderEdgeMiter,
  none = renderEdgeNone,
  bevel = renderEdgeBevel,
}

local function polyline(join_type, coords, half_width, pixel_size, draw_overdraw)
  local renderEdge = JOIN_TYPES[join_type]
  assert(renderEdge, join_type .. ' is not a valid line join type.')

  local anchors = {}
  local normals = {}

  if draw_overdraw then
    half_width = half_width - pixel_size * 0.3
  end

  local is_looping = (coords[1] == coords[#coords - 1]) and (coords[2] == coords[#coords])
  local s
  if is_looping then
    s = Vector(coords[1] - coords[#coords - 3], coords[2] - coords[#coords - 2])
  else
    s = Vector(coords[3] - coords[1], coords[4] - coords[2])
  end

  local len_s = length(s)
  local ns = normal({}, s, half_width / len_s)

  local r, q = Vector(coords[1], coords[2]), Vector(0, 0)
  for i=1,#coords-2,2 do
    q.x, q.y = r.x, r.y
    r.x, r.y = coords[i + 2], coords[i + 3]
    len_s = renderEdge(anchors, normals, s, len_s, ns, q, r, half_width)
  end

  q.x, q.y = r.x, r.y
  if is_looping then
    r.x, r.y = coords[3], coords[4]
  else
    r.x, r.y = r.x + s.x, r.y + s.y
  end
  len_s = renderEdge(anchors, normals, s, len_s, ns, q, r, half_width)

  local vertices = {}
  for i=1,#normals do
    table.insert(vertices, {
      anchors[i].x + normals[i].x,
      anchors[i].y + normals[i].y,
    })
  end

  return vertices
end

return polyline
