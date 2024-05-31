Config = {}

Config.Language = 'en'

Config.UseCommand = true
Config.CommandName = 'tracknumber'

Config.ItemUse = true
Config.ItemName = 'phonetracker'

Config.UpdateBlip = 300 -- In ms

Config.UseAirplane = true

Config.BlipType = 'exact' -- Values are exact or radius.

Config.BlipRadius = 50.0 -- If Config.BlipType is set to radius edit this to your own's choice.

Config.NotificationType = "qb" -- Values = qb, okok, ox.

Config.NotifyTitle = '' -- Use this if you have set Config.NotificationType to ox or okok.

Config.OnlyWhitelistedJobs = true

Config.WhitelistedJobs = { -- Edit this if you are using Config.OnlyWhitelistedJobs.
    'police',
}

Config.BlacklistedJobs = { -- Here you can add blacklisted jobs that will not be trackable.
    'taxi',
}

Config.BlacklistedGangs = { -- Here you can add blacklisted gangs that will not be trackable.
    'ballas',
}