---@class PYConverter
local M = Class 'PYConverter'

---@private
---@type table<string, fun(py_value:any):any>
M.py_to_lua_method = {}

---@private
---@type table<string, fun(lua_value:any):any>
M.lua_to_py_method = {}

---@private
---@type table<string, string>
M.type_alias_map = {}

---@param py_type string
---@param py_value any
---@return any
function M.py_to_lua(py_type, py_value)
    if py_value == nil then
        return nil
    end
    local converter = M.py_to_lua_method[py_type]
    if converter then
        return converter(py_value)
    end
    return py_value
end

---@param py_type string
---@param lua_value any
---@return any
function M.lua_to_py(py_type, lua_value)
    if lua_value == nil then
        return nil
    end
    local converter = M.lua_to_py_method[py_type]
    if converter then
        return converter(lua_value)
    end
    return lua_value
end

---@param py_type string
---@return fun(py_value:any):any
function M.lua_to_py_factory(py_type)
    return function (lua_value)
        return M.lua_to_py(py_type, lua_value)
    end
end

---@param py_type string
---@return fun(lua_value:any):any
function M.py_to_lua_factory(py_type)
    return function (py_value)
        return M.py_to_lua(py_type, py_value)
    end
end

---@param py_type string
---@param converter fun(py_value:any):any
function M.register_py_to_lua(py_type, converter)
    M.py_to_lua_method[py_type] = converter
end

---@param py_type string
---@param converter fun(lua_value:any):any
function M.register_lua_to_py(py_type, converter)
    M.lua_to_py_method[py_type] = converter
end

---@param type_name string
---@return string
function M.get_py_type(type_name)
    if M.type_alias_map[type_name] then
        return M.type_alias_map[type_name]
    end
    if y3.util.stringStartWith(type_name, 'py.') then
        M.type_alias_map[type_name] = type_name
        return type_name
    end
    if type_name:find '^%u' then
        M.type_alias_map[type_name] = 'py.' .. type_name
        return 'py.' .. type_name
    end
    M.type_alias_map[type_name] = type_name
    return type_name
end

---@param py_type_name string
---@param lua_type_name string
function M.register_type_alias(py_type_name, lua_type_name)
    M.type_alias_map[lua_type_name] = py_type_name
end

M.register_py_to_lua('number', function (py_number)
    return py_number:float()
end)

M.register_py_to_lua('number', function (number)
    return Fix32(number)
end)

return M
