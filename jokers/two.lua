--second batch of 8
SMODS.Joker {
  key = 'garbage',
  loc_txt = {
    name = 'Garbage Man',
    text = {
      "Earn {C:money}$#1#{} if",
      "exactly {C:attention}5{} cards",
      "are discarded"
    }
  },
  config = { dollars = 3 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 5, y = 2 },
  cost = 4,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.dollars } }
  end,
  calculate = function(self, card, context)
    if context.pre_discard and #context.full_hand == 5 then
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.dollars
        return {
          dollars = card.ability.dollars,
          func = function()
            G.E_MANAGER:add_event(Event({
                func = function()
                  G.GAME.dollar_buffer = 0
                  return true
                end
              }))
          end
        }
    end
  end,
}

SMODS.Joker {
  key = 'speedlimit',
  loc_txt = {
    name = 'Speed Limit',
    text = {
      "Earn {C:money}$#1#{} on final",
      "hand of round"
    }
  },
  config = { dollars = 8 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 6, y = 2 },
  cost = 6,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.dollars } }
  end,
  calculate = function(self, card, context)
    if context.before and G.GAME.current_round.hands_left == 0 then
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.dollars
        return {
          dollars = card.ability.dollars,
          func = function()
            G.E_MANAGER:add_event(Event({
                func = function()
                  G.GAME.dollar_buffer = 0
                  return true
                end
              }))
          end
        }
    end
  end,
}

SMODS.Joker {
  key = "cowboy",
  loc_txt = {
    name = 'Cowboy',
    text = {
      "Retrigger all",
      "played {C:attention}Aces{} and {C:attention}8s{}"
    }
  },
  config = { repetitions = 1 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 7, y = 2 },
  cost = 5,
  blueprint_compat = true,
    calculate = function(self, card, context)
      if context.repetition and context.cardarea == G.play then
        if context.other_card:get_id() == 8 or
          context.other_card:get_id() == 14 then
            return {
              repetitions = card.ability.repetitions
            }
      end
    end
  end
}

SMODS.Joker {
  key = "comic book",
  loc_txt = {
    name = 'Comic Book',
    text = {
      "Gain {C:mult}+#2#{} Mult when",
      "a {C:attention}face card{}",
      "is scored",
      "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    }
  },
  config = { mult = 0, mult_delta = 1 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 8, y = 2 },
  cost = 5,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.mult, card.ability.mult_delta } }
  end,
  calculate = function(self, card, context)
    if context.individual and not context.blueprint and context.cardarea == G.play and context.other_card:is_face() then
      card.ability.mult = card.ability.mult + card.ability.mult_delta
      return {
        message = localize('k_upgrade_ex'),
        colour = G.C.MULT,
        message_card = card
      }
    end
    if context.joker_main then
      return {
        mult = card.ability.mult
      }
    end
  end
}