local M = {}

-----------------------------------------------------------
-- Checks if running under Windows.
-----------------------------------------------------------
function M.is_win()
  if vim.loop.os_uname().version:match "Windows" then
    return true
  else
    return false
  end
end

-----------------------------------------------------------
-- Function equivalent to basename in POSIX systems.
-- @param str the path string.
-----------------------------------------------------------
function M.basename(str)
  return string.gsub(str, "(.*/)(.*)", "%2")
end

-----------------------------------------------------------
-- Contatenates given paths with correct separator.
-- @param: var args of string paths to joon.
-----------------------------------------------------------
function M.join_paths(...)
  local path_sep = M.is_win() and "\\" or "/"
  local result = table.concat({ ... }, path_sep)
  return result
end

-----------------------------------------------------------
-- Loads all modules from the given package.
-- @param package: name of the package in lua folder.
-----------------------------------------------------------
function M.glob_require(package)
  local function get_current_file_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str
  end

  local utils_file_path = vim.fn.fnamemodify(get_current_file_path(), ":p:h")

  local glob_path = M.join_paths(utils_file_path, package, "*.lua")

  for _, path in pairs(vim.split(vim.fn.glob(glob_path), "\n")) do
    -- convert absolute filename to relative
    local prefix = utils_file_path .. "/"
    local relfilename = path

    -- remove prefix path
    if string.sub(relfilename, 1, #prefix) == prefix then
      relfilename = string.sub(relfilename, #prefix + 1)
    end

    -- remove .lua extension
    local modulename = relfilename:gsub("%.lua", "")

    -- skip `init` and files starting with underscore.
    local basename = M.basename(modulename)
    if basename ~= "init" and basename:sub(1, 1) ~= "_" then
      print(modulename)
      require(modulename)
    end
  end
end

return M
