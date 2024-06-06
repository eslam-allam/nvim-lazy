return {
  "pwntester/octo.nvim",
  opts = {
    mappings = {
      review_diff = {
        add_review_comment = { lhs = "grc", desc = "add a new review comment" },
        add_review_suggestion = { lhs = "grs", desc = "add a new review suggestion" },
      },
      review_thread = {
        add_comment = { lhs = "grca", desc = "add a new review comment" },
        add_suggestion = { lhs = "grs", desc = "add a new review suggestion" },
        delete_comment = { lhs = "grcd", desc = "delete comment" },
      },
      issue = {
        add_comment = { lhs = "gica", desc = "add comment" },
        delete_comment = { lhs = "gicd", desc = "delete comment" },
      },
      pull_request = {
        add_comment = { lhs = "gpca", desc = "add comment" },
        delete_comment = { lhs = "gpcd", desc = "delete comment" },
      },
    },
  },
}
