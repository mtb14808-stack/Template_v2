return {
	Name = "GlobalAnnounce",
	Aliases = { "gm" },
	Description = "Global Message",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "Messsage",
			Description = "Text To Send",
		},
		{
			Type = "number",
			Name = "Duration",
			Description = "How many seconds the message stays",
		},
		{
			Type = "string",
			Name = "Color",
			Description = "ex: Red,Green,Purple,Yellow,Orange",
		},
	},
}
