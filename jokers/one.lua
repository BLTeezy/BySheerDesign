--first batch of 15
SMODS.Joker {
  key = 'blank',
  loc_txt = {
    name = 'Empty Space',
    text = {
      "Cards held in hand",
      "give {C:mult}+#1#{} Mult"
    }
  },
  config = { mult = 3 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 0, y = 0 },
  cost = 4,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.mult } }
  end,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.hand and not context.end_of_round then
      if context.other_card.debuff then
        return {
          message = localize('k_debuffed'),
          colour = G.C.RED
        }
      else
        return {
          mult = card.ability.mult
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'roughdraft',
  loc_txt = {
    name = 'Rough Draft',
    text = {
      "This Joker gains",
      "{C:mult}+#2#{} Mult per {C:attention}face card{}",
      "discarded this round",
      "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    }
  },
  config = { mult = 0, mult_delta = 2 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 1, y = 0 },
  cost = 6,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.mult, card.ability.mult_delta } }
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      return {
        mult = card.ability.mult
      }
    elseif context.discard and context.other_card:is_face() and not context.other_card.debuff and not context.blueprint then
      card.ability.mult = card.ability.mult + card.ability.mult_delta
      return {
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.mult } },
        colour = G.C.MULT
      }
    elseif context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
      card.ability.mult = 0
    end
  end
}

SMODS.Joker {
  key = 'psionics',
  loc_txt = {
    name = 'Psionics',
    text = {
      'Create a {C:tarot}Tarot{} card',
      'every {C:attention}16{} {C:inactive}[#1#]{} discards',
      '{C:inactive}(Must have room){}'
    }
  },
  config = { discards = 16 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 2, y = 0 },
  cost = 6,
  blueprint_compat = false,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.discards } }
  end,
  calculate = function(self, card, context)
    if context.discard and not context.other_card.debuff and not context.blueprint and card.ability.discards > 0 then
      card.ability.discards = card.ability.discards - 1
      if card.ability.discards == 0 then
        card.ability.discards = 16
        if G.consumeables.config.card_limit > #G.consumeables.cards then
          G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
              play_sound('timpani')
              SMODS.add_card {
                set = 'Tarot'
              }
              card:juice_up(0.3, 0.5)
              return true
            end
          }))
        end
      end
    end
  end
}

SMODS.Joker {
  key = 'jimbius',
  loc_txt = {
    name = 'Jimbius The Great',
    text = {
      '{C:mult}+#1#{} Mult for every ',
      '{C:attention}consumeable{} card',
      'in your possession',
      '{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}'
    }
  },
  config = { mult = 10 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 3, y = 0 },
  cost = 5,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.mult, card.ability.mult * (G.consumeables and #G.consumeables.cards or 0) } }
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      return {
        mult = card.ability.mult * #G.consumeables.cards
      }
    end
  end
}

SMODS.Joker {
  key = 'getwellsoon',
  loc_txt = {
    name = 'Get Well Soon',
    text = {
      'After {C:attention}#2#{} round, sell',
      'this card to create',
      'an {C:attention}Investment Tag{}',
      '{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#){}'
    }
  },
  config = { currentround = 0, requiredround = 1 },
  unlocked = true,
  discovered = true,
  rarity = 2, -- Uncommon
  atlas = 'BSD',
  pos = { x = 4, y = 0 },
  cost = 5,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.currentround, card.ability.requiredround } }
  end,
  calculate = function(self, card, context)
    if context.selling_self and (card.ability.currentround >= card.ability.requiredround) and not context.blueprint then
      G.E_MANAGER:add_event(Event({
        func = (function()
          add_tag(Tag('tag_investment'))
          play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
          play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
          return true
        end)
      }))
      return nil, true
    end
    if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
      card.ability.currentround = card.ability.currentround + 1
      if card.ability.currentround == card.ability.requiredround then
        local eval = function(card) return not card.REMOVED end
        juice_card_until(card, eval, true)
      end
      return {
        message = (card.ability.currentround < card.ability.requiredround) and
            (card.ability.currentround .. '/' .. card.ability.requiredround) or
            localize('k_active_ex'),
        colour = G.C.FILTER
      }
    end
  end
}

SMODS.Joker {
  key = 'ace',
  loc_txt = {
    name = 'Ace In The Hole',
    text = {
      'Gives {X:mult,C:white}X#1#{} Mult for',
      'each {C:attention}Ace{} above {C:attention}4{} in',
      'your {C:attention}full deck{}',
      '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}'
    }
  },
  config = { xmult = 0.25 },
  unlocked = true,
  discovered = true,
  rarity = 2, -- Uncommon
  atlas = 'BSD',
  pos = { x = 5, y = 0 },
  cost = 6,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    local ace_tally = 0
    if G.playing_cards then
      for _, playing_card in ipairs(G.playing_cards) do
        if playing_card:get_id() == 14 then ace_tally = ace_tally + 1 end
      end
    end
    return { vars = { card.ability.xmult, math.max(1, card.ability.xmult * ace_tally) } }
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      local ace_tally = 0
      if G.playing_cards then
        for _, playing_card in ipairs(G.playing_cards) do
          if playing_card:get_id() == 14 then ace_tally = ace_tally + 1 end
        end
        return {
          Xmult = math.max(1, card.ability.xmult * ace_tally)
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'fly',
  loc_txt = {
    name = 'Fly',
    text = {
      '{C:blue}+#1#{} hands every round',
      '{C:red}#2#{} hand size'
    }
  },
  config = { extra_hand = 2, handsize = -1 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 6, y = 0 },
  cost = 4,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra_hand, card.ability.handsize } }
  end,
  calculate = function(self, card, context)
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function()
                    ease_hands_played(card.ability.extra_hand)
                    SMODS.calculate_effect(
                        { message = localize { type = 'variable', key = 'a_hands', vars = { card.ability.extra_hand } } },
                        context.blueprint_card or card)
                    return true
                end
            }))
            return nil, true -- This is for Joker retrigger purposes
        end
    end,
  add_to_deck = function(self, card, from_debuff)
    G.hand:change_size(card.ability.handsize)
  end,
  remove_from_deck = function(self, card, from_debuff)
    G.hand:change_size(-card.ability.handsize)
  end,
}
