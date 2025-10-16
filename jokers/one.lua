--first batch of 8
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
  pos = { x = 2, y = 0 },
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
  pos = { x = 3, y = 0 },
  cost = 5,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { key = 'tag_investment', set = 'Tag' }
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
  pos = { x = 4, y = 0 },
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
  pos = { x = 5, y = 0 },
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

SMODS.Joker {
  key = 'exponent',
  loc_txt = {
    name = 'Exponent',
    text = {
      '{C:mult}+#1#{} Mult, doubles every',
      'hand played this round'
    }
  },
  config = { mult = 2, handsplayed = 1 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 6, y = 0 },
  cost = 5,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.mult * card.ability.handsplayed } }
  end,
  calculate = function(self, card, context)
    if context.after and not context.blueprint and card.ability.handsplayed > 0 then card.ability.handsplayed = card.ability.handsplayed * 2 end
    if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
      card.ability.handsplayed = 1
    end
    if context.joker_main then
      return {
        mult = card.ability.mult * card.ability.handsplayed
      }
    end
  end,
}

SMODS.Joker {
  key = 'cyber',
  loc_txt = {
    name = 'Cyber Joker',
    text = {
      'Create a {C:tarot}Charm Tag{} if',
      'final hand of round is played',
      'with {C:attention}1{} discard'
    }
  },
  unlocked = true,
  discovered = true,
  rarity = 2, -- Uncommon
  atlas = 'BSD',
  pos = { x = 7, y = 0 },
  soul_pos = { x = 0, y = 1},
  cost = 6,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { key = 'tag_charm', set = 'Tag' }
  end,
  calculate = function(self, card, context)
    if context.before and G.GAME.current_round.hands_left == 0 and G.GAME.current_round.discards_left == 1 then
      G.E_MANAGER:add_event(Event({
        func = (function()
          add_tag(Tag('tag_charm'))
          play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
          play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
          card:juice_up(0.3, 0.5)
          return true
        end)
      }))
      return { 
        message = G.localization.descriptions.Tag['tag_charm'].name.."!",
        colour = G.C.TAROT,
      }
    end
  end,
}

SMODS.Joker {
  key = 'dnd',
  loc_txt = {
    name = 'Do Not Disturb',
    text = {
      'If {C:attention}first discard{} of',
      'round has only {C:attention}1{} card,',
      'create a {C:attention}Glass{} copy of it'
    }
  },
  unlocked = true,
  discovered = true,
  rarity = 2, -- Uncommon
  atlas = 'BSD',
  pos = { x = 8, y = 0 },
  cost = 6,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
  end,
  calculate = function(self, card, context)
    if context.first_hand_drawn then
      local eval = function() return G.GAME.current_round.discards_used == 0 and not G.RESET_JIGGLES end
      juice_card_until(card, eval, true)
    end
    if context.discard and
      G.GAME.current_round.discards_used <= 0 and #context.full_hand == 1 then
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        local copy_card = copy_card(context.full_hand[1], nil, nil, G.playing_card)
        copy_card:set_ability('m_glass', nil, true)
        copy_card:add_to_deck()
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        table.insert(G.playing_cards, copy_card)
        G.hand:emplace(copy_card)
        copy_card.states.visible = nil

        G.E_MANAGER:add_event(Event({
          func = function()
            copy_card:start_materialize()
            return true
          end
        }))
        return {
          message = localize('k_copied_ex'),
          colour = G.C.CHIPS,
          func = function() -- This is for timing purposes, it runs after the message
          G.E_MANAGER:add_event(Event({
            func = function()
              SMODS.calculate_context({ playing_card_added = true, cards = { copy_card } })
              return true
            end
          }))
          end
        }
    end
  end
}

SMODS.Joker {
  key = 'foursquare',
  loc_txt = {
    name = 'Four Square',
    text = {
      'This Joker gains {X:mult,C:white}X#2#{} Mult',
      'when a hand is played that',
      'contains exactly {C:attention}4 4s{}',
      '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
    }
  },
  config = { xmult = 1, xmult_delta = 0.75 },
  unlocked = true,
  discovered = true,
  rarity = 3, -- Rare
  atlas = 'BSD',
  pos = { x = 9, y = 0 },
  cost = 8,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.xmult, card.ability.xmult_delta } }
  end,
  calculate = function(self, card, context)
    if context.before and not context.blueprint and #context.full_hand == 4 and context.full_hand[4]:get_id() == 4 then
      card.ability.xmult = card.ability.xmult + card.ability.xmult_delta
      return {
        message = localize('k_upgrade_ex'),
        colour = G.C.MULT,
        message_card = card
      }
    end
    if context.joker_main then
      return {
        Xmult = card.ability.xmult
      }
    end
  end
}

SMODS.Joker {
  key = 'goldbar',
  loc_txt = {
    name = 'Gold Bar',
    text = {
      'Each {C:attention}Gold Card{}',
      'held in hand',
      'gives {X:mult,C:white}X#1#{} Mult'
    }
  },
  config = { xmult = 1.5 },
  unlocked = true,
  discovered = true,
  rarity = 2, -- Uncommon
  atlas = 'BSD',
  pos = { x = 0, y = 2 },
  cost = 6,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
    return { vars = { card.ability.xmult } }
  end,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.hand and not context.end_of_round and SMODS.has_enhancement(context.other_card, 'm_gold') then
      if context.other_card.debuff then
        return {
          message = localize('k_debuffed'),
          colour = G.C.RED
        }
      else
        return {
          Xmult = card.ability.xmult
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'molotov',
  loc_txt = {
    name = 'Molotov Cocktail',
    text = {
      '{C:red}+#1#{} discards when Blind is selected',
      '{C:red}-#2#{} discard every round'
    }
  },
  config = { discards = 3, discards_delta = 1 },
  unlocked = true,
  discovered = true,
  rarity = 1, -- Common
  atlas = 'BSD',
  pos = { x = 1, y = 2 },
  cost = 5,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.discards, card.ability.discards_delta } }
  end,
  calculate = function(self, card, context)
    if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
      if card.ability.discards - card.ability.discards_delta <= 0 then
        SMODS.destroy_cards(card, nil, nil, true)
          return {
            message = localize('k_drank_ex'),
            colour = G.C.FILTER
          }
      else
        card.ability.discards = card.ability.discards - card.ability.discards_delta
          return {
            message = card.ability.discards .. '',
            colour = G.C.FILTER
          }
        end
      end
  if context.setting_blind then
    ease_discard(card.ability.discards)
  return {
    message = card.ability.discards .. '',
    colour = G.C.RED
  }
  end
end
}

SMODS.Joker {
  key = 'jimmy',
  loc_txt = {
    name = 'Little Jimmy',
    text = {
      'After {C:attention}#1#{} ronds, sell',
      'this Joker to create',
      'a {C:attention}Rare Tag{}',
      '{C:inactive}(Currently {C:attention}#2#{C:inactive}/#1# Rounds){}'
    }
  },
  config = { requiredround = 3, currentround = 0 },
  unlocked = true,
  discovered = true,
  rarity = 2, -- Uncommon
  atlas = 'BSD',
  pos = { x = 2, y = 2 },
  cost = 6,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { key = 'tag_rare', set = 'Tag' }
    return { vars = { card.ability.requiredround, card.ability.currentround } }
  end,
  calculate = function(self, card, context)
    if context.selling_self and (card.ability.currentround >= card.ability.requiredround) and not context.blueprint then
      G.E_MANAGER:add_event(Event({
        func = (function()
          add_tag(Tag('tag_rare'))
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
  key = 'lifeafterdeath',
  loc_txt = {
    name = 'Life After Death',
    text = {
      'When a playing card',
      'is {C:attention}destroyed{}, {C:green}#1# in #2#{} chance',
      'to create a {C:spectral}Spectral{} card'
    }
  },
  config = { odds = 3},
  unlocked = true,
  discovered = true,
  rarity = 2, -- Uncommon
  atlas = 'BSD',
  pos = { x = 3, y = 2 },
  cost = 6,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { (G.GAME.probabilities.normal or 1), card.ability.odds } }
  end,
  calculate = function(self, card, context)
    if context.remove_playing_cards and pseudorandom('lifeafterdeath') < G.GAME.probabilities.normal / card.ability.odds 
      and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
      G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
      return {
        message = localize('k_plus_spectral'),
        colour = G.C.SECONDARY_SET.SPECTRAL,
        G.E_MANAGER:add_event(Event({
          func = (function()
            SMODS.add_card {
              set = 'Spectral',
            }
            G.GAME.consumeable_buffer = 0
            return true
          end)
        }))
      }
    end
  end
}

SMODS.Joker {
  key = 'tcard',
  loc_txt = {
    name = 'Trump Card',
    text = {
      'When a {C:attention}consumeable{} is',
      "used, earn it's {C:attention}sell value{}"
    }
  },
  config = { dollars1 = 1, dollars2 = 2 },
  unlocked = true,
  discovered = true,
  rarity = 2, -- Uncommon
  atlas = 'BSD',
  pos = { x = 4, y = 2 },
  cost = 5,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { (G.GAME.probabilities.normal or 1), card.ability.odds } }
  end,
  calculate = function(self, card, context)
    if context.using_consumeable and not context.blueprint and (context.consumeable.ability.set == "Tarot" or context.consumeable.ability.set == "Planet") then
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.dollars1
      return {
        dollars = card.ability.dollars1,
          func = function() -- This is for timing purposes, it runs after the dollar manipulation
            G.E_MANAGER:add_event(Event({
              func = function()
                G.GAME.dollar_buffer = 0
                return true
              end
            }))
            end
          }
      end
    if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == "Spectral" then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.dollars2
      return {
        dollars = card.ability.dollars2,
          func = function() -- This is for timing purposes, it runs after the dollar manipulation
            G.E_MANAGER:add_event(Event({
              func = function()
                G.GAME.dollar_buffer = 0
                return true
              end
            }))
            end
          }
      end
  end
}