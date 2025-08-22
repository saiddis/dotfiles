return {
  'glacambre/firenvim',
  build = ':call firenvim#install(0)',
  config = function()
    vim.api.nvim_create_autocmd({ 'UIEnter' }, {
      callback = function(event)
        local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
        if client ~= nil and client.name == 'Firenvim' then
          vim.o.laststatus = 0
        end
      end,
    })

    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
      callback = function(e)
        if vim.g.timer_started == true then
          return
        end
        vim.g.timer_started = true
        vim.fn.timer_start(10000, function()
          vim.g.timer_started = false
          vim.cmd 'silent write'
        end)
      end,
    })
  end,
}
