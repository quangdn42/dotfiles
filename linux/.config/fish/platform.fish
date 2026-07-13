if status is-interactive
    if not string match -rq '^linux:[^:]+:[^:]+$' -- $__dotfiles_fish_theme
        __dotfiles_omarchy_fish_theme >/dev/null 2>&1
    end

    __dotfiles_apply_fish_theme $__dotfiles_fish_theme

    function __dotfiles_reload_fish_theme --on-variable __dotfiles_fish_theme
        __dotfiles_apply_fish_theme $__dotfiles_fish_theme
        if functions -q tide
            tide reload
        end

        commandline -f repaint >/dev/null 2>&1
    end
end
