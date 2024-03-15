return {
  "eslam-allam/snap.nvim",
  build = ":SnapBuild",
  opts = {
    line_offset = true,
    watermark = {
      font = "JetBrainsMono-NF-Regular",
      font_color = "white",
      text = " eslam-allam",
      position = "SouthEast",
      font_size = 15,
      opacity = 0.8
    }
  },
}
