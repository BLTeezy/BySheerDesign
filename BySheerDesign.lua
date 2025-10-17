Sculio = SMODS.current_mod

SMODS.Atlas {
  -- Key for code to find it with
  key = 'BSD',
  -- The name of the file, for the code to pull the atlas from
  path = 'BySheerDesign.png', -- Original file sourced from https://github.com/Steamodded/examples/tree/master/Mods/ExampleJokersMod/assets
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}

SMODS.Atlas {
  key = 'Sculio_Tags',
  path = 'Tags.png',
  px = 34,
  py = 34
}

SMODS.Atlas {
  key = 'BSDB',
  path = 'Decks.png',
  px = 69,
  py = 93
}

SMODS.Atlas {
  key = 'modicon',
  path = 'Tags.png',
  px = 34,
  py = 34
}

SMODS.current_mod.optional_features = function()
  return {
    post_trigger = true
  }
end

local subdir1 = 'jokers'
local cards1 = NFS.getDirectoryItems(SMODS.current_mod.path .. subdir1)

table.sort(cards1, function(a, b)
  local a_num = tonumber(a:match('^(%d+)_')) or 0
  local b_num = tonumber(b:match('^(%d+)_')) or 0
  return a_num < b_num
end)

for _, filename in ipairs(cards1) do
  assert(SMODS.load_file(subdir1 .. '/' .. filename))()
end

local subdir2 = 'backs'
local cards2 = NFS.getDirectoryItems(SMODS.current_mod.path .. subdir2)

table.sort(cards2, function(a, b)
  local a_num = tonumber(a:match('^(%d+)_')) or 0
  local b_num = tonumber(b:match('^(%d+)_')) or 0
  return a_num < b_num
end)

for _, filename in ipairs(cards2) do
  assert(SMODS.load_file(subdir2 .. '/' .. filename))()
end
