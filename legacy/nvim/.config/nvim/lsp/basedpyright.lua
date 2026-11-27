return {
	settings = {
		basedpyright = {
			disableLanguageServices = false,
			disableOrganizeImports = true,
			disableTaggedHints = false,
			reportMissingSuperCall = false,
			analysis = {
				autoImportCompletions = true,
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				typeCheckingMode = "basic",
				useLibraryCodeForTypes = true,
			},
		},
		python = {
			venvPath = "~/envs/",
		},
	},
}
