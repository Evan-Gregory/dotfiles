## ~/.config/nushell/env.nu
# Hello from dots
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

#~/.config/nushell/config.nu
source ~/.cache/carapace/init.nu

$env.config.show_banner = true

# Starship Setup --
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# EXTERNAL COMPLETIONS --
let fish_completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {|row|
      let value = $row.value
      let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
      if ($need_quote and ($value | path exists)) {
        let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
        $'"($expanded_path | str replace --all "\"" "\\\"")"'
      } else {$value}
    }
}

let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

# This completer will use carapace by default
let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        # carapace completions are incorrect for nu
        nu => $fish_completer
        # fish completes commits and branch names in a nicer way
        git => $fish_completer
        # carapace doesn't have completions for asdf
        asdf => $fish_completer
        _ => $carapace_completer
    } | do $in $spans
}

$env.config.completions = {
	algorithm: 'fuzzy'
	external: {
		enable: true
		max_results: 100
		completer: $external_completer
	}
	
}
# END EXTERNAL COMPLETIONS --

$env.config.buffer_editor = 'nvim' 

def --env 'login aws' [] {
$env.AWS_PROFILE = (aws configure list-profiles | fzf)
aws sso login
}

# Allows for replicating process substituion.
# Example:
#   nvim --cmd copen -q (ruff check --output-format concise | as file )
#
# In bash, this would be `nvim --cmd copen -q <(ruff check --output-format concise)`
# From https://github.com/nushell/nushell/issues/10610
export def "as file" [] {
  let it = $in
  # make tmp file in system tmp dir
  let file = mktemp --tmpdir
  $it | save --append $file # Need to run it in background for it to stream, but this also works (but doesn't provide streaming).
  $file
}


# THEME --
$env.config.table.mode = 'compact'
$env.LS_COLORS = "di=1;34:*.nu=3;33;46"
# # Example color config from [ nushell coloring guide ](https://www.nushell.sh/book/coloring_and_theming.html#special-primitives-not-really-primitives-but-they-exist-solely-for-coloring)
#>$env.config.color_config.header = { # this is like PR #489
#>    fg: "#B01455", # note, quotes are required on the values with hex colors
#>    bg: "#ffb900", # note, commas are not required, it could also be all on one line
#>    attr: bli # note, there are no quotes around this value. it works with or without quotes
#>}
$env.config.color_config.separator = 'purple'
$env.config.color_config.leading_trailing_space_bg = "#ffffff"
$env.config.color_config.header = 'gb'
$env.config.color_config.date = 'wd'
$env.config.color_config.filesize = 'c'
$env.config.color_config.row_index = 'cb'
$env.config.color_config.bool = 'red'
$env.config.color_config.int = 'green'
$env.config.color_config.duration = 'blue_bold'
$env.config.color_config.range = 'purple'
$env.config.color_config.float = 'red'
$env.config.color_config.string = 'white'
$env.config.color_config.nothing = 'red'
$env.config.color_config.binary = 'red'
$env.config.color_config.cellpath = 'cyan'
$env.config.color_config.hints = 'lyd'
$env.config.color_config.shapes_garbage = 'red'
