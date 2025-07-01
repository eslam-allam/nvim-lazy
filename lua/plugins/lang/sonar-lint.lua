return {
  {
    "iamkarasik/sonarqube.nvim",
    config = function(_, opts)
      require("sonarqube").setup(opts)
    end,
    opts = function()
      local extension_path =
        require("plenary.path"):new(require("mason-registry").get_package("sonarlint-language-server"):get_install_path(), "extension")
      local analyzers = extension_path:joinpath("analyzers")
      local javaExec = require("modules.java").execAtleast(17)
      return {
        lsp = {
          cmd = {
            javaExec,
            "-jar",
            extension_path:joinpath("server/sonarlint-ls.jar"):absolute(),
            "-stdio",
            "-analyzers",
            analyzers:joinpath("sonargo.jar"):absolute(),
            analyzers:joinpath("sonarhtml.jar"):absolute(),
            analyzers:joinpath("sonarhtml.jar"):absolute(),
            analyzers:joinpath("sonariac.jar"):absolute(),
            analyzers:joinpath("sonarjava.jar"):absolute(),
            analyzers:joinpath("sonarjavasymbolicexecution.jar"):absolute(),
            analyzers:joinpath("sonarjs.jar"):absolute(),
            analyzers:joinpath("sonarphp.jar"):absolute(),
            analyzers:joinpath("sonarpython.jar"):absolute(),
            analyzers:joinpath("sonartext.jar"):absolute(),
          },
        },
      }
    end,
  },
}
