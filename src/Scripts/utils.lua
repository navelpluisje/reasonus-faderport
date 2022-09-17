local utils = {};

-- Check if the vlue is a string and not empty
-- param str valiur to check
function utils.isString(str)
  if (str == nil or str == '') then
    return false
  end
  return true;
end

function utils.trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function utils.round(number)
  local rest = number % 1;
  if (rest < 0.5) then
    return math.floor(number)
  else
    return math.ceil(number)
  end
end

--******************************************************************************
--
-- Reset all the midi surfaces
--
--******************************************************************************
function utils.resetSurfaces()
  reaper.Main_OnCommandEx(41743, 0, 0)
end

function utils.filterTable(tbl, callback)
  local output = {}
  for k, v in pairs(tbl) do
    if (callback(v)) then
      table.insert(output, v)
    end
  end
  return output
end

function utils.tableCount(tbl)
  local count = 0;
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

return utils;
