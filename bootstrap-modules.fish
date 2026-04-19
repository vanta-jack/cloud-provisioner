#!/usr/bin/fish
set selected_modules (gum choose --no-limit "Docker" "WebDev" "KiCad")
if test -n "$selected_modules"
    for mod in $selected_modules
        switch $mod
            case "Docker"
                ~/.cloud-provisioner-modules/module-docker.fish
            case "WebDev"
                ~/.cloud-provisioner-modules/module-webdev.fish
            case "KiCad"
                ~/.cloud-provisioner-modules/module-kicad.fish
        end
    end
else
    echo "No modules selected."
end
