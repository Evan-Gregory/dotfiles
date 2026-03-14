_BASE62CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

local function _gen_key(key_len, base_len)
  math.randomseed(os.time())
  local key = ''
  local rand
  for i = 0, key_len, 1 do
    rand = math.random(base_len)
    key = key .. _BASE62CHARS:sub(rand, rand)
  end
  return key
end

local function get_base_64(len)
  _gen_key(len, _BASE62CHARS:len())
end

local function get_base_32(len)
  _gen_key(len, _BASE62CHARS:len() / 2)
end

-- TODO: move to keybind
local function write_key()
  local line = vim.api.nvim_get_current_line()
  line = line .. get_base_64(5)
  vim.api.nvim_set_current_line(line)
end

return get_base_64, get_base_32
