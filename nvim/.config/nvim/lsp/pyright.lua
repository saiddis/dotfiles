return {
	settings = {
		pyright = {
			autoImportCompletion = true,
		},
		python = {
			analysis = {
				typeCheckingMode = "off",
				indexing = true,
				userFileIndexingLimit = 2000,
				diagnosticMode = "openFilesOnly",
				diagnosticSeverityOverrides = {
					reportUnusedExpression = "none",
				},
				useLibraryCodeForTypes = false,
				autoImportCompletions = true,
				autoSearchPaths = true,
				gotoDefinitionInStringLiteral = true,
				packageIndexDepths = {
					{ name = "sklearn", depth = 2 },
					{ name = "matplotlib", depth = 2 },
					{ name = "scipy", depth = 2 },
					{ name = "flask", depth = 2 },
					{ name = "pytorch", depth = 2 },
					{ name = "torch", depth = 2 },
					{ name = "numpy", depth = 2 },
					{ name = "gym", depth = 2 },
					{ name = "gymnasium", depth = 2 },
				},
			},
		},
	},
}
