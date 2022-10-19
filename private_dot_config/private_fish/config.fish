if status is-interactive
    # Commands to run in interactive sessions can go here
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /home/main/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<
export PATH="$HOME/../../bin/nvim-linux64/bin:$PATH"
export PATH="$HOME/../../bin/bin/:$PATH"

function ll 
        ls -lah
end
