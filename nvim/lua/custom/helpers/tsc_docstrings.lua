local M = {}

-- -------- TS query: find first docstring in class/def ----------
local py_query = vim.treesitter.query.parse(
  'python',
  [[
(function_definition
  body: (block
          (expression_statement
            (string) @doc)))
(class_definition
  body: (block
          (expression_statement
            (string) @doc)))
]]
)

local function iter_doc(node, bufnr)
  -- range(): start_row, start_col, end_row, end_col
  local sr, _, er, _ = node:range()
  for _, match in py_query:iter_matches(node, bufnr, sr, er) do
    for id, n in pairs(match) do
      if py_query.captures[id] == 'doc' then
        return n
      end
    end
  end
end

-- -------- helpers ----------
local function startswith(s, pre)
  return s:sub(1, #pre) == pre
end
local function endswith(s, suf)
  return s:sub(-#suf) == suf
end

local function strip_py_triple(s)
  -- drop common prefixes (r, f, b, u, combos)
  s = s:gsub('^%s*[rRbBuUfF]*', '')
  if startswith(s, '"""') then
    s = s:sub(4)
  end
  if startswith(s, "'''") then
    s = s:sub(4)
  end
  if endswith(s, '"""') then
    s = s:sub(1, #s - 3)
  end
  if endswith(s, "'''") then
    s = s:sub(1, #s - 3)
  end
  return s
end

local function dedent_lines(lines)
  local indent = nil
  for _, l in ipairs(lines) do
    if l:match '%S' then
      local sp = l:match '^%s*'
      indent = indent and math.min(indent, #sp) or #sp
    end
  end
  if not indent or indent == 0 then
    return lines
  end
  local out = {}
  for _, l in ipairs(lines) do
    table.insert(out, l:sub(indent + 1))
  end
  return out
end

local function doc_lines_for(node, bufnr, max_lines, prefix)
  if vim.bo[bufnr].filetype ~= 'python' then
    return nil
  end
  local t = node:type()
  if t ~= 'function_definition' and t ~= 'class_definition' then
    return nil
  end
  local doc_node = iter_doc(node, bufnr)
  if not doc_node then
    return nil
  end
  local text = vim.treesitter.get_node_text(doc_node, bufnr)
  text = strip_py_triple(text)
  local lines = dedent_lines(vim.split(text, '\n', { plain = true }))
  local n = math.min(#lines, max_lines or 2)
  local out = {}
  prefix = prefix or '""" '
  for i = 1, n do
    table.insert(out, prefix .. (lines[i] or ''))
  end
  return out
end

-- -------- attach / patch ----------
local function find_util()
  local candidates = { 'treesitter-context.util', 'treesitter-context.utils' }
  for _, name in ipairs(candidates) do
    local ok, mod = pcall(require, name)
    if ok and type(mod) == 'table' then
      return mod, name
    end
  end
end

local function find_getter(util)
  for _, k in ipairs { 'get_text_for_node', 'get_node_text', 'get_lines_for_node' } do
    if type(util[k]) == 'function' then
      return k, util[k]
    end
  end
end

function M.attach(opts)
  opts = opts or {}
  local max_doc = opts.max_lines or 2
  local prefix = opts.prefix or '""" '

  -- ensure plugin is loaded
  pcall(require, 'treesitter-context')

  local util, util_name = find_util()
  if not util then
    vim.notify('[tsc_docstrings] util module not found', vim.log.levels.WARN)
    return
  end

  local getter_name, orig = find_getter(util)
  if not orig then
    vim.notify('[tsc_docstrings] no suitable util getter found in ' .. util_name, vim.log.levels.WARN)
    return
  end

  if util._tsc_doc_patched then
    return -- already patched
  end

  util[getter_name] = function(node, bufnr, o)
    local lines = orig(node, bufnr, o) or {}
    local extra = doc_lines_for(node, bufnr, max_doc, prefix)
    if extra and #extra > 0 then
      vim.list_extend(lines, extra)
    end
    return lines
  end
  util._tsc_doc_patched = true

  vim.notify(('[tsc_docstrings] patched %s.%s'):format(util_name, getter_name), vim.log.levels.INFO)
end

-- Debug command: shows status + preview for node at cursor
function M.probe()
  local util = find_util()
  local getter_name = util and find_getter(util)
  vim.notify(('[tsc_docstrings] util=%s getter=%s patched=%s'):format(tostring(util), tostring(getter_name), tostring(util and util._tsc_doc_patched)))

  local bufnr = vim.api.nvim_get_current_buf()
  local node
  if vim.treesitter.get_node then
    node = vim.treesitter.get_node { bufnr = bufnr }
  else
    local tsu_ok, tsu = pcall(require, 'nvim-treesitter.ts_utils')
    if tsu_ok then
      node = tsu.get_node_at_cursor()
    end
  end
  if not node then
    vim.notify('[tsc_docstrings] no node at cursor', vim.log.levels.WARN)
    return
  end
  local extra = doc_lines_for(node, bufnr, 3, '"""')
  if extra then
    vim.notify('[tsc_docstrings] doc preview:\n' .. table.concat(extra, '\n'))
  else
    vim.notify '[tsc_docstrings] no docstring found for this node'
  end
end

return M
