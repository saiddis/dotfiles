local settings = {
	ty = {
		rules = {
			["unresolved-import"] = "warn",
			["possibly-unresolved-reference"] = "ignore",
		},

		environment = {
			python = ".venv",
			["python-version"] = "3.12",
		},

		analysis = {
			["respect-type-ignore-comments"] = true,
		},
	},
}

return settings
