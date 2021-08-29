local M = {}

function M.greater_than_zero(values)
  for k, v in pairs(values) do
    vim.validate({
      [k] = {
        v,
        function(x)
          return x > 0
        end,
        "greater than 0",
      },
    })
  end
end

return M
