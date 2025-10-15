local json = {}

json.null = setmetatable({}, {
  __tostring = function()
    return "json.null"
  end,
})

local WHITESPACE = { [" "] = true, ["\n"] = true, ["\r"] = true, ["\t"] = true }

local function create_error(message, position)
  if position then
    return string.format("JSON parse error at byte %d: %s", position, message)
  end
  return "JSON parse error: " .. message
end

local function skip_whitespace(source, index)
  while index <= #source and WHITESPACE[source:sub(index, index)] do
    index = index + 1
  end
  return index
end

local function parse_string(source, index)
  index = index + 1 -- skip opening quote
  local buffer = {}
  while index <= #source do
    local char = source:sub(index, index)
    if char == '"' then
      return table.concat(buffer), index + 1
    elseif char == "\\" then
      local next_char = source:sub(index + 1, index + 1)
      if next_char == '"' or next_char == "\\" or next_char == "/" then
        buffer[#buffer + 1] = next_char
        index = index + 2
      elseif next_char == "b" then
        buffer[#buffer + 1] = "\b"
        index = index + 2
      elseif next_char == "f" then
        buffer[#buffer + 1] = "\f"
        index = index + 2
      elseif next_char == "n" then
        buffer[#buffer + 1] = "\n"
        index = index + 2
      elseif next_char == "r" then
        buffer[#buffer + 1] = "\r"
        index = index + 2
      elseif next_char == "t" then
        buffer[#buffer + 1] = "\t"
        index = index + 2
      elseif next_char == "u" then
        local hex = source:sub(index + 2, index + 5)
        if not hex:match("^[0-9a-fA-F]+$") then
          error(create_error("invalid unicode escape", index))
        end
        local codepoint = tonumber(hex, 16)
        buffer[#buffer + 1] = utf8.char(codepoint)
        index = index + 6
      else
        error(create_error("invalid escape sequence", index))
      end
    else
      buffer[#buffer + 1] = char
      index = index + 1
    end
  end
  error(create_error("unterminated string", index))
end

local function parse_number(source, index)
  local start_index = index
  local char = source:sub(index, index)
  if char == "-" then
    index = index + 1
  end
  while index <= #source and source:sub(index, index):match("%d") do
    index = index + 1
  end
  if source:sub(index, index) == "." then
    index = index + 1
    if not source:sub(index, index):match("%d") then
      error(create_error("invalid number", index))
    end
    while index <= #source and source:sub(index, index):match("%d") do
      index = index + 1
    end
  end
  local exponent_char = source:sub(index, index)
  if exponent_char == "e" or exponent_char == "E" then
    index = index + 1
    local sign = source:sub(index, index)
    if sign == "+" or sign == "-" then
      index = index + 1
    end
    if not source:sub(index, index):match("%d") then
      error(create_error("invalid exponent", index))
    end
    while index <= #source and source:sub(index, index):match("%d") do
      index = index + 1
    end
  end
  local value = tonumber(source:sub(start_index, index - 1))
  if value == nil then
    error(create_error("invalid number", start_index))
  end
  return value, index
end

local function parse_literal(source, index, literal, value)
  if source:sub(index, index + #literal - 1) == literal then
    return value, index + #literal
  end
  error(create_error("unexpected value", index))
end

local parse_value -- forward declaration

local function parse_array(source, index)
  index = index + 1 -- skip [
  local result = {}
  index = skip_whitespace(source, index)
  if source:sub(index, index) == "]" then
    return result, index + 1
  end
  while index <= #source do
    local value
    value, index = parse_value(source, index)
    result[#result + 1] = value
    index = skip_whitespace(source, index)
    local char = source:sub(index, index)
    if char == "," then
      index = skip_whitespace(source, index + 1)
    elseif char == "]" then
      return result, index + 1
    else
      error(create_error("expected ',' or ']'", index))
    end
  end
  error(create_error("unterminated array", index))
end

local function parse_object(source, index)
  index = index + 1 -- skip {
  local result = {}
  index = skip_whitespace(source, index)
  if source:sub(index, index) == "}" then
    return result, index + 1
  end
  while index <= #source do
    if source:sub(index, index) ~= '"' then
      error(create_error("expected string key", index))
    end
    local key
    key, index = parse_string(source, index)
    index = skip_whitespace(source, index)
    if source:sub(index, index) ~= ":" then
      error(create_error("expected ':' after key", index))
    end
    index = skip_whitespace(source, index + 1)
    local value
    value, index = parse_value(source, index)
    result[key] = value
    index = skip_whitespace(source, index)
    local char = source:sub(index, index)
    if char == "," then
      index = skip_whitespace(source, index + 1)
    elseif char == "}" then
      return result, index + 1
    else
      error(create_error("expected ',' or '}'", index))
    end
  end
  error(create_error("unterminated object", index))
end

function parse_value(source, index)
  index = skip_whitespace(source, index)
  local char = source:sub(index, index)
  if char == '"' then
    return parse_string(source, index)
  elseif char == "{" then
    return parse_object(source, index)
  elseif char == "[" then
    return parse_array(source, index)
  elseif char == "t" then
    return parse_literal(source, index, "true", true)
  elseif char == "f" then
    return parse_literal(source, index, "false", false)
  elseif char == "n" then
    local _, next_index = parse_literal(source, index, "null", json.null)
    return json.null, next_index
  elseif char == "-" or char:match("%d") then
    return parse_number(source, index)
  end
  error(create_error("unexpected character '" .. char .. "'", index))
end

function json.decode(source)
  if type(source) ~= "string" then
    error("json.decode expects a string")
  end
  local value, index = parse_value(source, 1)
  index = skip_whitespace(source, index)
  if index <= #source then
    error(create_error("unexpected trailing data", index))
  end
  return value
end

local function encode_string(value)
  local replacements = {
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
    ['"'] = '\\"',
    ['\\'] = "\\\\",
  }
  return '"' .. value:gsub('[\0\b\f\n\r\t"\\]', replacements) .. '"'
end

local function is_array(table_value)
  local count = 0
  for key in pairs(table_value) do
    if type(key) ~= "number" then
      return false
    end
    count = count + 1
  end
  return count == #table_value
end

local function encode_value(value, buffer, stack)
  local value_type = type(value)
  if value_type == "string" then
    buffer[#buffer + 1] = encode_string(value)
  elseif value_type == "number" then
    buffer[#buffer + 1] = tostring(value)
  elseif value_type == "boolean" then
    buffer[#buffer + 1] = value and "true" or "false"
  elseif value == nil or value == json.null then
    buffer[#buffer + 1] = "null"
  elseif value_type == "table" then
    if stack[value] then
      error("json.encode does not support circular references")
    end
    stack[value] = true
    if is_array(value) then
      buffer[#buffer + 1] = "["
      for index = 1, #value do
        if index > 1 then
          buffer[#buffer + 1] = ","
        end
        encode_value(value[index], buffer, stack)
      end
      buffer[#buffer + 1] = "]"
    else
      buffer[#buffer + 1] = "{"
      local first = true
      for key, inner in pairs(value) do
        if type(key) ~= "string" then
          error("json.encode only supports string keys for objects")
        end
        if not first then
          buffer[#buffer + 1] = ","
        end
        first = false
        buffer[#buffer + 1] = encode_string(key)
        buffer[#buffer + 1] = ":"
        encode_value(inner, buffer, stack)
      end
      buffer[#buffer + 1] = "}"
    end
    stack[value] = nil
  else
    error("json.encode cannot serialise type: " .. value_type)
  end
end

function json.encode(value)
  local buffer = {}
  encode_value(value, buffer, {})
  return table.concat(buffer)
end

return json
