function __dotfiles_apply_fish_theme --argument-names theme
    if test -z "$theme"
        set theme tokyonight
    end

    if string match -q '*:*' -- $theme
        set -l parts (string split : -- $theme)
        set theme $parts[(count $parts)]
    end

    switch $theme
        case catppuccin-latte catppuccin-mocha kanagawa tokyonight
        case '*'
            set theme tokyonight
    end

    set -l theme_file $HOME/.config/fish/themes/$theme.fish
    if test -r $theme_file
        source $theme_file
    else
        source $HOME/.config/fish/themes/tokyonight.fish
    end
end
