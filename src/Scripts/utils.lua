local utils = {};

-- Check if the vlue is a string and not empty
-- param str valiur to check
function utils.isString(str)
  if (str == nil or str == '') then
    return false
  end
  return true;
end

function utils.round(number)
  local rest = number % 1;
  if (rest < 0.5) then
    return math.floor(number)
  else
    return math.ceil(number)
  end
end

return utils;
