local utils = {};

utils.tableCount = function(table)
  local length = 0;

  for _, _ in pairs(table) do
    length = length + 1;
  end

  return length;
end

utils.filterTable = function(oldTable, callback)
  local newTable = {};

  for k, v in pairs(oldTable) do
    if (callback(v)) then
      newTable[k] = v;
    end
  end

  return newTable;
end

utils.round = function(number)
  local rest = number % 1;
  if (rest < 0.5) then
    return math.floor(number);
  else
    return math.ceil(number);
  end
end

utils.isString = function(value)
  return type(value) == 'string';
end

utils.resetSurfaces = function()
  reaper.Main_OnCommandEx(41743, 0, 0);
end

utils.trim = function(value)
  return value:match("^%s*(.-)%s*$");
end

return utils;
