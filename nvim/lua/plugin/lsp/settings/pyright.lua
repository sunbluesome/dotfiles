return {
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "off",
                extraPaths = {
                    ".",
                    "./src",
                    "./module",
                    "./modules",
                }
            },
        },
    },
}

