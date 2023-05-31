name = "Bone Armor Cooldown Visualization"
--The name of your mod
description = "Adds a cooldown visualizer to the bone armor"
--The description that shows when you are selecting the mod from the list
author = "splorange"
--Your name!
version = "1.2"

forumthread = ""

icon_atlas = "modicon.xml"

icon = "modicon.tex"

dst_compatible = true
forge_compatible = true
gorge_compatible = true

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

all_clients_require_mod = false
server_only_mod = false
client_only_mod = true

api_version = 10
--This is the version of the game's API and should stay the same for the most part
configuration_options =
{
    {
        name = "hasSound",
        label = "Play sound when off cooldown",
        options =
        {
            {description = "No", data = false},
            {description = "Yes", data = true},

        },
        default = false,
    },
    {
        name = "cooldownColor",
        label = "Cooldown color",
        options =
        {
            {description = "Black", data = 0.0},
            {description = "Blue", data = 0.4},

        },
        default = 0.0,
    }
}