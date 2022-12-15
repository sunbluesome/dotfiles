return {
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                -- This setting is deprecated in favor of python.analysis.useLibraryCodeForTypes. It will be removed at a future time.
                -- useLibraryCodeForTypes = true,
                autoImportCompletions = true,
                typeCheckingMode = "strict",

                -- To dynamically change to use poetry.
                -- pythonPath = ""
                -- extraPaths = ""
                -- venvPath = ""
            },
        },
    },
}
