local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
  return
end

null_ls.setup({
  on_init = function (new_client,_)
    new_client.offset_encoding = 'utf-32'
  end
})
