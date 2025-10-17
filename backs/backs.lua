-- Glass Deck
SMODS.Back {
    key = "glass",
    loc_txt = {
        name = "Glass Deck",
        text = {
<<<<<<< HEAD
            "{C:blue}+#1#{} hand every round",
            '{C:red}+#2#{} discard every round',
            "",
=======
>>>>>>> 0c66dc8fcf0136f0f235e848c010239a15454e60
            "All {C:attention}face cards",
            "are {C:attention}glass cards"
        }
    },
    atlas = 'BSDB',
    pos = { x = 1, y = 0 },
<<<<<<< HEAD
    config = { hands = 1, discards = 1 },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.hands, self.config.discards } }
    end,
=======
>>>>>>> 0c66dc8fcf0136f0f235e848c010239a15454e60
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