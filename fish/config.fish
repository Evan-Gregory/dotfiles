if status is-interactive
    # Commands to run in interactive sessions can go here
	pokemon-colorscripts -r --no-title &
	starship init fish | source &
        zoxide init fish | source
        cat ~/.local/state/caelestia/sequences.txt 2> /dev/null
end

# Start a tmux session if not already inside one
if type -q tmux 
    if not set -q TMUX
        ; or tmux new -s default
    end
end

# Start Hyprland automatically when this is a *login* shell on tty1.
if status is-login
    if test (tty) = "/dev/tty1"
        # Avoid starting inside an existing Wayland/X11 session
        if not set -q WAYLAND_DISPLAY; and not set -q DISPLAY
            exec Hyprland
        end
    end
end

set -l teal 94e2d5
set -l flamingo f2cdcd
set -l mauve cba6f7
set -l pink f5c2e7
set -l red f38ba8
set -l peach fab387
set -l green a6e3a1
set -l yellow f9e2af
set -l blue 89b4fa
set -l gray 1f1d2e
set -l black 191724
    
# # Completion Pager Colors
# set -g fish_pager_color_progress $gray
# set -g fish_pager_color_prefix $mauve
# set -g fish_pager_color_completion $peach
# set -g fish_pager_color_description $gray

# Some config
set -g fish_greeting

# Git config
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showupstream informative
set -g __fish_git_prompt_showdirtystate yes
set -g __fish_git_prompt_char_stateseparator ' '
set -g __fish_git_prompt_char_cleanstate '✔'
set -g __fish_git_prompt_char_dirtystate '✚'
set -g __fish_git_prompt_char_invalidstate '✖'
set -g __fish_git_prompt_char_stagedstate '●'
set -g __fish_git_prompt_char_stashstate '⚑'
set -g __fish_git_prompt_char_untrackedfiles '?'
set -g __fish_git_prompt_char_upstream_ahead ''
set -g __fish_git_prompt_char_upstream_behind ''
set -g __fish_git_prompt_char_upstream_diverged 'ﱟ'
set -g __fish_git_prompt_char_upstream_equal ''
set -g __fish_git_prompt_char_upstream_prefix ''''


# set -g man_blink -o $teal
# set -g man_bold -o $pink
# set -g man_standout -b $gray
# set -g man_underline -u $blue

export MANPAGER="nvim +Man!"

# Directory abbreviations
abbr -a -g l 'ls'
abbr -a -g la 'ls -a'
abbr -a -g ll 'ls -l'
abbr -a -g lal 'ls -al'
abbr -a -g d 'dirs'
abbr -a -g h 'cd $HOME'

# ARM GNU Toolchain
export ARMGCC_DIR=/usr
export PATH="$ARMGCC_DIR/bin:$PATH"

export SDK_ROOT_DIR=~/StreamHome/streametric-gateways/stream-m-lite/StreamMLite/SDK_25_03_00_RW612/devices/RW612/

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Exports
export VISUAL="nvim"
export EDITOR="$VISUAL"

# Term
switch "$TERM_EMULATOR"
case '*kitty*'
	export TERM='xterm-kitty'
case '*'
	export TERM='xterm-256color'
end


# User abbreviations
abbr -a -g ytmp3 'youtube-dl --extract-audio --audio-format mp3'				# Convert/Download YT videos as mp3
abbr -a -g cls 'clear'																								# Clear
abbr -a -g h 'history'																								# Show history
abbr -a -g upd 'dnf upgrade --refresh -y'
abbr -a -g please 'sudo'																						# Polite way to sudo
abbr -a -g fucking 'sudo'																						# Rude way to sudo
abbr -a -g sayonara 'shutdown now'																	# Epic way to shutdown
abbr -a -g stahp 'shutdown now'																		# Panik - stonk man
abbr -a -g ar 'echo "awesome.restart()" | awesome-client'							# Reload AwesomeWM
abbr -a -g shinei 'kill -9'																						# Kill ala DIO
abbr -a -g kv 'kill -9 (pgrep vlc)'																			# Kill zombie vlc
abbr -a -g priv 'fish --private'																				# Fish incognito mode
abbr -a -g sshon 'sudo systemctl start sshd.service'										# Start ssh service
abbr -a -g sshoff 'sudo systemctl stop sshd.service'										# Stop ssh service
abbr -a -g untar 'tar -zxvf'																					# Untar
abbr -a -g genpass 'openssl rand -base64 20'													# Generate a random, 20-charactered password
abbr -a -g sha 'shasum -a 256'																			# Test checksum
abbr -a -g cn 'ping -c 5 8.8.8.8'																			# Ping google, checking network
abbr -a -g ipe 'curl ifconfig.co'																				# Get external IP address
abbr -a -g ips 'ip link show'																					# Get network interfaces information
abbr -a -g wloff 'rfkill block wlan'																			# Block wlan, killing wifi connection
abbr -a -g wlon 'rfkill unblock wlan'																		# Unblock wlan, start wifi connection
abbr -a -g ff 'firefox'																								#

# Source plugins
# Useful plugins: archlinux bang-bang cd colorman sudope vcs
if test -d "$HOME/.local/share/omf/pkg/colorman/"
	source ~/.local/share/omf/pkg/colorman/init.fish
end

# Make su launch fish
function su
   command su --shell=/usr/bin/fish $argv
end

function wa
    set -f APPID "6HV6YJ-QGK36VKQQJ" # Get one at https://products.wolframalpha.com/api/
    echo $argv | string escape --style=url | read question_string
    set -f url "https://api.wolframalpha.com/v1/result?appid="$APPID"&i="$question_string
    curl -s $url
end

function _jiratui_completion;
    set -l response (env _JIRATUI_COMPLETE=fish_complete COMP_WORDS=(commandline -cp) COMP_CWORD=(commandline -t) jiratui);

    for completion in $response;
        set -l metadata (string split "," $completion);

        if test $metadata[1] = "dir";
            __fish_complete_directories $metadata[2];
        else if test $metadata[1] = "file";
            __fish_complete_path $metadata[2];
        else if test $metadata[1] = "plain";
            echo $metadata[2];
        end;
    end;
end;

complete --no-files --command jiratui --arguments "(_jiratui_completion)";
# Get terminal emulator
# set TERM_EMULATOR (ps -aux | grep (ps -p $fish_pid -o ppid=) | awk 'NR==1{print $11}')

# Neofetch
# switch "$TERM_EMULATOR"
# case '*kitty*'
#       neofetch --backend 'kitty'
# case '*tmux*' '*login*' '*sshd*' '*konsole*'
#	neofetch --backend 'ascii' --ascii_distro 'arch_small' 
# case '*'
# 	neofetch --backend 'w3m' --xoffset 34 --yoffset 34 --gap 0
# end

eval "$(fzf --fish)"
set FZF_CTRL_T_OPTS "
  --walker-skip .git,node_modules,target,.cache,.local
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

abbr v1 'cd /home/evang/StreamHome/streametric-backend'
abbr v2be 'cd /home/evang/StreamHome/streametric-v2-be'
abbr stream 'cd /home/evang/StreamHome'

alias bat='bat --theme="Catppuccin-mocha"'
alias hc=herbstclient
alias code='code-insiders'
set MOZ_ENABLE_WAYLAND 1
set XDG_CURRENT_DESKTOP sway

alias awsltest='set -x AWS_PROFILE streametric-v2-test; export AWS_PROFILE="streametric-v2-prod"; aws sso login'
alias awsldev='set -x AWS_PROFILE streametric-dev-v2; aws sso login'
alias awslv1='set -x AWS_PROFILE streametric-v1; aws sso login'
alias awslprod='set -x AWS_PROFILE streametric-v2-prod; aws sso login; export AWS_PROFILE="streametric-v2-prod"'
alias awslstg='set -x AWS_PROFILE streametric-staging; aws sso login; export AWS_PROFILE="streametric-staging"'

alias nokvm='sudo rmmod kvm_amd'
alias plskvm='sudo modprobe kvm_amd'

alias vol='amixer' 
alias volup='amixer set Master 5%+'
alias voldn='amixer set Master 5%-'
alias volmute='amixer set Master toggle'


set PATH $PATH $HOME/.local/bin $HOME/.cargo/bin/ $HOME/Documents/awww/target/release $HOME/.bun/bin




# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd
    builtin pwd -L
end

# A copy of fish's internal cd function. This makes it possible to use
# `alias cd=z` without causing an infinite loop.
if ! builtin functions --query __zoxide_cd_internal
    string replace --regex -- '^function cd\s' 'function __zoxide_cd_internal ' <$__fish_data_dir/functions/cd.fish | source
end

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd
    if set -q __zoxide_loop
        builtin echo "zoxide: infinite loop detected"
        builtin echo "Avoid aliasing `cd` to `z` directly, use `zoxide init --cmd=cd fish` instead"
        return 1
    end
    __zoxide_loop=1 __zoxide_cd_internal $argv
end

# =============================================================================
#
# Hook configuration for zoxide.
#

# Initialize hook to add new entries to the database.
function __zoxide_hook --on-variable PWD
    test -z "$fish_private_mode"
    and command zoxide add -- (__zoxide_pwd)
end

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z
    set -l argc (builtin count $argv)
    if test $argc -eq 0
        __zoxide_cd $HOME
    else if test "$argv" = -
        __zoxide_cd -
    else if test $argc -eq 1 -a -d $argv[1]
        __zoxide_cd $argv[1]
    else if test $argc -eq 2 -a $argv[1] = --
        __zoxide_cd -- $argv[2]
    else
        set -l result (command zoxide query --exclude (__zoxide_pwd) -- $argv)
        and __zoxide_cd $result
    end
end

# Completions.
function __zoxide_z_complete
    set -l tokens (builtin commandline --current-process --tokenize)
    set -l curr_tokens (builtin commandline --cut-at-cursor --current-process --tokenize)

    if test (builtin count $tokens) -le 2 -a (builtin count $curr_tokens) -eq 1
        # If there are < 2 arguments, use `cd` completions.
        complete --do-complete "'' "(builtin commandline --cut-at-cursor --current-token) | string match --regex -- '.*/$'
    else if test (builtin count $tokens) -eq (builtin count $curr_tokens)
        # If the last argument is empty, use interactive selection.
        set -l query $tokens[2..-1]
        set -l result (command zoxide query --exclude (__zoxide_pwd) --interactive -- $query)
        and __zoxide_cd $result
        and builtin commandline --function cancel-commandline repaint
    end
end
complete --command __zoxide_z --no-files --arguments '(__zoxide_z_complete)'

# Jump to a directory using interactive search.
function __zoxide_zi
    set -l result (command zoxide query --interactive -- $argv)
    and __zoxide_cd $result
end

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

abbr --erase z &>/dev/null
alias z=__zoxide_z

abbr --erase zi &>/dev/null
alias zi=__zoxide_zi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually
# ~/.config/fish/config.fish):
#
#   
# 
# =============================================================================
if test -d "$HOME/Documents/awww/completions/" 
    source "$HOME/Documents/awww/completions/awww.fish"
end


# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# opencode
fish_add_path /home/evang/.opencode/bin

# pnpm
set -gx PNPM_HOME "/home/evang/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
