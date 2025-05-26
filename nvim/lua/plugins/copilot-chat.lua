return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "github/copilot.vim" }, -- Make sure Copilot itself is installed
  },
  opts = {
    -- optional settings
  },
  cmd = { "CopilotChat", "CopilotChatToggle" },
  keys = {
    { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
    { "<leader>cq", "<cmd>CopilotChat<cr>", desc = "Open Copilot Chat" },
  },
}
