-- Glass Deck
SMODS.Back {
    key = "glass",
    loc_txt = {
        name = "Glass Deck",
        text = {
            "{C:blue}+#1#{} hand every round",
            '{C:red}+#2#{} discard every round',
            "",
            "All {C:attention}face cards",
            "are {C:attention}glass cards"
        }
    },
    atlas = 'BSDB',
    pos = { x = 1, y = 0 },
    config = { hands = 1, discards = 1 },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.hands, self.config.discards } }
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if v:is_face() then
                        v:set_ability('m_glass', nil, true)
                    end
                end
                return true
        end}))
    end,
}