local utils = {};

---comCheck if the vlue is a string and not emptyment
---@param str string
---@return boolean
function utils.isString(str)
  if (str == nil or str == '') then
    return false
  end
  return true;
end

---Remove whitespace from both ends of a string
---@param str string
---@return string
function utils.trim(str)
  return (string.gsub(str, '^%s*(.-)%s*$', '%1'))
end

---Returns the value of a number rounded to the nearest integer.
---@param number number
---@return integer
function utils.round(number)
  local rest = number % 1;
  if (rest < 0.5) then
    return math.floor(number)
  else
    return math.ceil(number)
  end
end

---Rest all midi surfaces
function utils.resetSurfaces()
  reaper.Main_OnCommandEx(41743, 0, 0)
end

---Creates a copy of a portion of a given array, filtered down to just the elements from the given array that pass the test implemented by the provided function.
---@param tbl table
---@param callback function
---@return table
function utils.filterTable(tbl, callback)
  local output = {}
  for k, v in pairs(tbl) do
    if (callback(v)) then
      table.insert(output, v)
    end
  end
  return output
end

---Get the number of items in a table
---@param tbl table
---@return integer
function utils.tableCount(tbl)
  local count = 0;
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

return utils;
