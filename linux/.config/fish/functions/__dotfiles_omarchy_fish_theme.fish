function __dotfiles_omarchy_fish_theme
    set -l omarchy_theme tokyo-night
    set -l theme_name_file $HOME/.config/omarchy/current/theme.name
    set -l colors_file $HOME/.config/omarchy/current/theme/colors.toml

    if test -r $theme_name_file
        read omarchy_theme <$theme_name_file
    end

    set omarchy_theme (string lower (string trim $omarchy_theme))
    set -l fish_theme tokyonight

    switch $omarchy_theme
        case catppuccin
            set fish_theme catppuccin-mocha
        case catppuccin-latte
            set fish_theme catppuccin-latte
        case kanagawa
            set fish_theme kanagawa
        case tokyo-night
            set fish_theme tokyonight
        case '*'
            if test -r $colors_file
                set -l background (string match -r '^background\s*=.*' <$colors_file | string replace -r '.*"#([0-9A-Fa-f]{6})".*' '$1')
                if string match -rq '^[0-9A-Fa-f]{6}$' -- $background
                    set -l red (string sub -s 1 -l 2 $background)
                    set -l green (string sub -s 3 -l 2 $background)
                    set -l blue (string sub -s 5 -l 2 $background)
                    set -l luminance (math "0.299 * 0x$red + 0.587 * 0x$green + 0.114 * 0x$blue")

                    if test $luminance -gt 128
                        set fish_theme catppuccin-latte
                    end
                end
            end
    end

    set -l marker linux:$omarchy_theme:$fish_theme
    set -U __dotfiles_fish_theme $marker

    if contains -- --print $argv
        echo $marker
    end
end
