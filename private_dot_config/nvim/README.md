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

Can view messages using the message command.

Snippets and completions require extra configuration in cmp file.

##LSP 

Language server protocol. Use command LSP.. to manipulate LSP commands. Press i over server name to install the LSP.

See handlers file to get a good understanding of Lua.

## Treesitter

Does dyntax highlighting.

## LSP 

Bash: Just works
Python: Just works. 
JavaScript: For current setup add an empty .git file in root directory. Otherwise you will need a specific configuration file in every project. 
C++: Install cppcheck (its pretty cool) using your system package manager. Need a file at least in root directory called compile_commands.json to generically run code.
