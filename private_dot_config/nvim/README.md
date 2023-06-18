# Explanation of NVIM File Structure

"Init.lua" is the entry point for NVIM and runs everything specified on startup. Will only ever run "require" commands.

"Lua" directory is where all referenced lua files are stored to create better seperation and organization. There is a nested directory for additional specification 
of type of configuration file. This seperation is mainly to prevent collisions between some of the further nested lua files but can also be a way to let the user 
know what this configuration is for.

"Plugin" is where the package manager 'packer' stores plugin data to manage and compile the plugins. This file can be deleted but will respawn when neovim is ran again.

"README.md" is this file.

## Lua Directory

Contains core, lsp, packer_init, and plugins.

### Core

Options is used to configre simple options for NVIM. Run the command: "help options" to learn more about possible options and details.

Keymaps are used to remap defaults keybindings in neovim. Note this specific file is idiosyncratic compared to how remaps are typically done. 
Review contents in the file iteself before consulting external guides.

Colorshceme is the settings scritp to apply color designs to the neovim configuration.

### packer_init

This is the lua script utilizing packer to manage plugins. Plugins are stored in .local/share/nvim/site. Where all plugins save their data. These are optional and start. Start just run on startup. 

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
