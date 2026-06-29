-- quicktree's direnv exports GIT_DIR/GIT_WORK_TREE pointing at the sparse
-- worktree, but buffers live under the mount. gitsigns derives its --work-tree
-- from these (worktree falls back to dirname(GIT_DIR), repo.lua:495), so both
-- must go. Discovery then needs to cross the bind-mount device boundary to
-- find .git at the mount root, where core.worktree (the mount) wins.
if vim.env.QUICKTREE_MOUNT and vim.env.QUICKTREE_MOUNT ~= "" then
  vim.fn.setenv("GIT_WORK_TREE", vim.NIL)
  vim.fn.setenv("GIT_DIR", vim.NIL)
  vim.env.GIT_DISCOVERY_ACROSS_FILESYSTEM = "1"
end

require("cindy.core")
require("cindy.lazy")
require("cindy.lsp")
