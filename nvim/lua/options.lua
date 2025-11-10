local o = vim.o
o.number = true
o.relativenumber = true
o.showmode = false
o.breakindent = true

vim.schedule(function()
	o.clipboard = 'unnamedplus'
end)
