# Explanation of NVIM configuration

"Init.lua" is the entry point for NVIM and runs everything specified on startup. Will only ever run "require" commands.

"Lua" directory is where all referenced lua files are stored to create better seperation and organization. There is a nested directory for additional specification 
of type of configuration file. This seperation is mainly to prevent collisions between some of the further nested lua files but can also be a way to let the user 
know what this configuration is for.

## Lua Directory

Options is used to configre simple options for NVIM. Run the command: "help options" to learn more about possible options and details.

Keymaps are used to remap defaults keybindings in neovim. Note this specific file is idiosyncratic compared to how remaps are typically done. 
Review contents in the file iteself before consulting external guides.

## Plugins
Managed by packer. Plugins stored in .local/share/nvim/site. Where all plugins save their data. There are optional and start. Start just run on startup. 
Optional is where lazy loaded plugins live. Note more lazy loading will not necessarily speed things up.

Plugin directory is made by Packer to manage plugins and compile them. Can delete but packer will re-create.
See packer options to modify load.
