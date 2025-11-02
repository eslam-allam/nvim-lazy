return {
  "pwntester/octo.nvim",
  optional = true,
  opts = {
    mappings = {
      review_diff = {
        add_review_comment = { lhs = "goc", desc = "add a new review comment" },
        add_review_suggestion = { lhs = "gos", desc = "add a new review suggestion" },
      },
      review_thread = {
        add_comment = { lhs = "goca", desc = "add a new review comment" },
        add_suggestion = { lhs = "gos", desc = "add a new review suggestion" },
        delete_comment = { lhs = "gocd", desc = "delete comment" },
      },
      issue = {
        add_comment = { lhs = "goca", desc = "add comment" },
        delete_comment = { lhs = "gocd", desc = "delete comment" },
      },
      pull_request = {
        add_comment = { lhs = "goca", desc = "add comment" },
        delete_comment = { lhs = "gocd", desc = "delete comment" },
      },
      submit_win = {
        approve_review = { lhs = "<C-g>", desc = "approve review" },
      },
    },
  },
}
