--- STEAMODDED HEADER
--- MOD_NAME: Sylvie's Silliness
--- MOD_ID: SylvieSilly
--- MOD_AUTHOR: [NewtTheFish]
--- MOD_DESCRIPTION: A few decks, blinds, etc. Have fun!
--- DISPLAY_NAME: Sylvie Sillies
--- BADGE_COLOUR: C7387D

----------------------------------------------
------------MOD CODE -------------------------

local blind_stay_flipped_ref = Blind.stay_flipped
function Blind.stay_flipped(self, area, card)
    if not self.disabled then
        if area == G.hand then
            if self.name == 'The Frost' then
                if card:get_id() == 14 or card:get_id() == 3 or card:get_id() == 5 or card:get_id() == 7 or card:get_id() == 9 then
                    return true
                end
            end
            if self.name == 'The Heatwave' then
                if card:get_id() == 2 or card:get_id() == 4 or card:get_id() == 6 or card:get_id() == 8 or card:get_id() == 10 then
                    return true
                end
            end
        end
    end

    return blind_stay_flipped_ref(self, area, card)
end

local blind_disable_ref = Blind.disable
function Blind.disable(self)
    self.disabled = true

    if self.name == 'The Heatwave' or self.name == 'The Frost' then 
        for i = 1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for k, v in pairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end

    blind_disable_ref(self)
end

local blind_debuff_card_ref = Blind.debuff_card
function Blind.debuff_card(self, card, from_blind)

    if self.debuff and not self.disabled and card.area ~= G.jokers then
        if self.name == 'The Prospector' then
            if card.ability.name == 'Stone Card' or card.ability.name == 'Gold Card' or card.ability.name == 'Steel Card' or card.ability.name == 'Glass Card' then
                card:set_debuff(true)
                return
            end
        elseif self.name == 'The Gambler' then
            if card.ability.name == 'Mult' or card.ability.name == 'Bonus' or card.ability.name == 'Wild Card' or card.ability.name == 'Lucky Card' then
                card:set_debuff(true)
                return
            end
        elseif self.name == 'The Pathway' then
            if card:get_id() == 6 or card:get_id() == 7 or card:get_id() == 8 or card:get_id() == 9 or card:get_id() == 10 then
                card:set_debuff(true)
                return
            end
        elseif self.name == 'The Backside' then
            if card:get_id() == 14 or card:get_id() == 2 or card:get_id() == 3 or card:get_id() == 4 or card:get_id() == 5 then
                card:set_debuff(true)
                return
            end
        end
    end
    
    blind_debuff_card_ref(self, card, from_blind)
end

local cardsetedition = Card.set_edition
function Card.set_edition(self, edition, immediate, silent)
    cardsetedition(self, edition, immediate, silent)
    
    if G.GAME.starting_params.auroramodifier and self.ability.set == 'Default' and (edition == nil) then
        local rngedition = pseudorandom(pseudoseed('random_edition'))
        if rngedition > 0.5 then self:set_edition({foil = true})
        elseif rngedition > 0.1 then self:set_edition({holo = true})
        else self:set_edition({polychrome = true})
        end
    end
end

local Backapply_to_runRef = Back.apply_to_run
function Back.apply_to_run(self)
    Backapply_to_runRef(self)

    if self.effect.config.tarot_rate then
        G.GAME.tarot_rate = self.effect.config.tarot_rate
    end

    if self.effect.config.planet_rate then
        G.GAME.planet_rate = self.effect.config.planet_rate
    end

    if self.effect.config.edition_rate then
        G.GAME.edition_rate = self.effect.config.edition_rate
    end

    if self.effect.config.playing_card_rate then
        G.GAME.playing_card_rate = self.effect.config.playing_card_rate
    end

    if self.effect.config.auroramodifier then
        G.GAME.starting_params.auroramodifier = self.effect.config.auroramodifier
    end
    
    if self.effect.config.deckosmodifier then
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if v.base.suit == 'Clubs' then
                        v:set_ability(G.P_CENTERS['m_busted'])
                    end
                end
            return true
            end
        }))
    end

    if self.effect.config.lldmodifier then
        delay(0.4)
        G.E_MANAGER:add_event(Event({
            func = function()
                local seal_counter = 1
                for k, v in pairs(G.playing_cards) do
                    if v.base.value == 'Ace' or v.base.value == '10' or v.base.value == '6' then 
                        v:change_suit('Spades')
                    elseif v.base.value == 'King' or v.base.value == '9' or v.base.value == '5'  then
                        v:change_suit('Hearts')
                    elseif v.base.value == 'Queen' or v.base.value == '8' or v.base.value == '4'  then
                        v:change_suit('Clubs')
                    elseif v.base.value == 'Jack' or v.base.value == '7' or v.base.value == '3'  then
                        v:change_suit('Diamonds')
                    elseif v.base.value == '2' then
                        v:set_ability(G.P_CENTERS['m_wild'])
                        if seal_counter == 1 then v:set_seal('Red', true, true)
                        elseif seal_counter == 2 then v:set_seal('Blue', true, true)
                        elseif seal_counter == 3 then v:set_seal('Gold', true, true)
                        else v:set_seal('Purple', true, true)
                        end
                        seal_counter = seal_counter + 1
                    end

                    --v:set_ability(G.P_CENTERS['m_steel'])
                end
            return true
            end
        }))
    end
end

local lld_def = {
    ["name"] = "Lemon-Lime Deck",
    ["text"] = {
        [1] = "Divides up the deck!",
        [2] = "{C:red}-1{} discard.",
        [3] = "The {C:attention}2's{} are extra tasty.",
    },
}

local hallow_def = {
    ["name"] = "Hallowed Deck",
    ["text"] = {
        [1] = "{C:planet}Planets{} and {C:purple}Tarots{}",
        [2] = "no longer appear, while",
        [3] = "{C:attention}Playing Cards{} now",
        [4] = "appear in the shop."
    }
}

local aurora_def = {
    ["name"] = "Aurora Deck",
    ["text"] = {
        [1] = "Start with an {C:spectral,T:c_aura}Aura{} card.",
        [2] = "{C:attention}Jokers{} and {C:attention}Playing Cards{}",
        [3] = "are {C:attention}usually{} {C:dark_edition}Special.",
        [4] = "{C:red}-1{} joker slot, {C:red}-1{} hand."
    }
}

local sulfur_def = {
    ["name"] = "Sulfur Deck",
    ["text"] = {
        [1] = "Start with a {C:tarot,T:c_death}Death{} card",
        [2] = "and the {C:attention,T:v_overstock_norm}Overstock{} voucher.",
        [3] = "{C:attention}Jokers{} appear less often.",
    }
}

local deckos_def = {
    ["name"] = "Deck OS",
    ["text"] = {
        [1] = "BOOTING...",
        [2] = "{C:red}FAILED{} TO LOAD...",
        [3] = "{C:spectral}ATTEMPTING{} TO FIX...",
    }
}

local chipboost = 5
local bonusboost = 10
local multboost = 2
local sylvie_moons = {
    [1] = {
        name = 'Europa',
        text = {
            "{C:attention}Upgrade{} all",
            "{C:spades}Spade{} cards",
            "in your deck",
            "by {C:chips}+#1#{} Chips"
        },
        slug = "sylvie_europa",
        effect = 'Upgrade Spades',
        config = {
            chips = chipboost
        },
        pos = {x=0, y=0},
        loc_def = function(_c) return { _c.config.chips } end,
        can_use = function(self) return true end,
        use = function(self, area, copier)
            local used_tarot = copier or self
            for k, v in pairs(G.playing_cards) do
                if v:is_suit('Spades') then
                    v.ability.perma_bonus = v.ability.perma_bonus or 0
                    v.ability.perma_bonus = v.ability.perma_bonus + chipboost
                end
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                used_tarot:juice_up(0.3, 0.5)
                attention_text({
                    text = 'Spades Up!',
                    scale = 1, 
                    hold = 2.2,
                    major = used_tarot,
                    backdrop_colour = G.C.SO_1.Spades,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                })
                return true end }))
            delay(2.6)
            end,
        set_badges = function(self, badges)
			badges[1] = create_badge("Moon", get_type_colour(self.config.center or self.config, self), nil, 1.2)
			return badges
		end,
    },
    [2] = {
        name = 'Io',
        text = {
            "{C:attention}Upgrade{} all",
            "{C:clubs}Club{} cards",
            "in your deck",
            "by {C:chips}+#1#{} Chips"
        },
        slug = "sylvie_io",
        effect = 'Upgrade Clubs',
        config = {
            chips = chipboost
        },
        pos = {x=1, y=0},
        loc_def = function(_c) return { _c.config.chips } end,
        can_use = function(self) return true end,
        use = function(self, area, copier)
            local used_tarot = copier or self
            for k, v in pairs(G.playing_cards) do
                if v:is_suit('Clubs') then
                    v.ability.perma_bonus = v.ability.perma_bonus or 0
                    v.ability.perma_bonus = v.ability.perma_bonus + chipboost
                end
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                used_tarot:juice_up(0.3, 0.5)
                attention_text({
                    text = 'Clubs Up!',
                    scale = 1, 
                    hold = 2.2,
                    major = used_tarot,
                    backdrop_colour = G.C.SO_1.Clubs,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                })
                return true end }))
            delay(2.6)
            end,
        set_badges = function(self, badges)
			badges[1] = create_badge("Moon", get_type_colour(self.config.center or self.config, self), nil, 1.2)
			return badges
		end,
    },
    [3] = {
        name = 'Callisto',
        text = {
            "{C:attention}Upgrade{} all",
            "{C:hearts}Heart{} cards",
            "in your deck",
            "by {C:chips}+#1#{} Chips"
        },
        slug = "sylvie_callisto",
        effect = 'Upgrade Hearts',
        config = {
            chips = chipboost
        },
        pos = {x=2, y=0},
        loc_def = function(_c) return { _c.config.chips } end,
        can_use = function(self) return true end,
        use = function(self, area, copier)
            local used_tarot = copier or self
            for k, v in pairs(G.playing_cards) do
                if v:is_suit('Hearts') then
                    v.ability.perma_bonus = v.ability.perma_bonus or 0
                    v.ability.perma_bonus = v.ability.perma_bonus + chipboost
                end
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                used_tarot:juice_up(0.3, 0.5)
                attention_text({
                    text = 'Hearts Up!',
                    scale = 1, 
                    hold = 2.2,
                    major = used_tarot,
                    backdrop_colour = G.C.SO_1.Hearts,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                })
                return true end }))
            delay(2.6)
            end,
        set_badges = function(self, badges)
			badges[1] = create_badge("Moon", get_type_colour(self.config.center or self.config, self), nil, 1.2)
			return badges
		end,
    },
    [4] = {
        name = 'Ganymede',
        text = {
            "{C:attention}Upgrade{} all",
            "{C:diamonds}Diamond{} cards",
            "in your deck",
            "by {C:chips}+#1#{} Chips"
        },
        slug = "sylvie_ganymede",
        effect = 'Upgrade Diamonds',
        config = {
            chips = chipboost
        },
        pos = {x=3, y=0},
        loc_def = function(_c) return { _c.config.chips } end,
        can_use = function(self) return true end,
        use = function(self, area, copier)
            local used_tarot = copier or self
            for k, v in pairs(G.playing_cards) do
                if v:is_suit('Diamonds') then
                    v.ability.perma_bonus = v.ability.perma_bonus or 0
                    v.ability.perma_bonus = v.ability.perma_bonus + chipboost
                end
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                used_tarot:juice_up(0.3, 0.5)
                attention_text({
                    text = 'Diamonds Up!',
                    scale = 1, 
                    hold = 2.2,
                    major = used_tarot,
                    backdrop_colour = G.C.SO_1.Diamonds,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                })
                return true end }))
            delay(2.6)
            end,
        set_badges = function(self, badges)
			badges[1] = create_badge("Moon", get_type_colour(self.config.center or self.config, self), nil, 1.2)
			return badges
		end,
    },
    [5] = {
        name = 'Charon',
        text = {
            "{C:attention}Upgrade{} {C:chips}Bonus Cards{}",
            "by {C:chips}+#1#{} chips",
            "Affects {C:chips}Current{}",
            "and {C:dark_edition}Future{} cards",
        },
        slug = "sylvie_charon",
        effect = 'Upgrade Bonus Cards',
        config = {
            chips = bonusboost
        },
        pos = {x=0, y=1},
        loc_def = function(_c, info_queue)
			info_queue[#info_queue+1] = G.P_CENTERS.m_bonus

			return { _c.config.chips }
		end,
        can_use = function(self) return true end,
        use = function(self, area, copier)
            local used_tarot = copier or self
            G.P_CENTER_POOLS.Enhanced[1].config.bonus = G.P_CENTER_POOLS.Enhanced[1].config.bonus + bonusboost
            for k, v in pairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_bonus then
                    v:set_ability(G.P_CENTERS.m_bonus)
                end
            end

            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                used_tarot:juice_up(0.3, 0.5)
                attention_text({
                    text = 'Bonus Up!',
                    scale = 1, 
                    hold = 2.2,
                    major = used_tarot,
                    backdrop_colour = G.C.CHIPS,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                })
                return true end }))
            delay(2.6)
            end,
        set_badges = function(self, badges)
			badges[1] = create_badge("Moon", get_type_colour(self.config.center or self.config, self), nil, 1.2)
			return badges
		end,
    },

    [6] = {
        name = 'Hydra',
        text = {
            "{C:attention}Upgrade{} {C:mult}Mult Cards{}",
            "by {C:mult}+#1#{} mult",
            "Affects {C:mult}Current{}",
            "and {C:dark_edition}Future{} cards",
        },
        slug = "sylvie_hydra",
        effect = 'Upgrade Mult Cards',
        config = {
            mult = multboost
        },
        pos = {x=1, y=1},
        loc_def = function(_c, info_queue)
			info_queue[#info_queue+1] = G.P_CENTERS.m_mult

			return { _c.config.mult }
		end,
        can_use = function(self) return true end,
        use = function(self, area, copier)
            local used_tarot = copier or self
            G.P_CENTER_POOLS.Enhanced[2].config.mult = G.P_CENTER_POOLS.Enhanced[2].config.mult + multboost
            for k, v in pairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_mult then
                    v:set_ability(G.P_CENTERS.m_mult)
                end
            end

            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                used_tarot:juice_up(0.3, 0.5)
                attention_text({
                    text = 'Mult Up!',
                    scale = 1, 
                    hold = 2.2,
                    major = used_tarot,
                    backdrop_colour = G.C.MULT,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                })
                return true end }))
            delay(2.6)
            end,
        set_badges = function(self, badges)
			badges[1] = create_badge("Moon", get_type_colour(self.config.center or self.config, self), nil, 1.2)
			return badges
		end,
    },

}

local Game_start_run_ref = Game.start_run;
function Game:start_run(args)
	local ret = Game_start_run_ref(self, args)

    -- RESET
    G.P_CENTER_POOLS.Enhanced[1].config.bonus = 30
    G.P_CENTER_POOLS.Enhanced[2].config.mult = 4
	return ret
end

function SMODS.INIT.SylvieSilly()
local mod = SMODS.findModByID("SylvieSilly")

SMODS.Sprite:new("sylvie_backs", mod.path, "sylvie_backs.png", 71, 95, "asset_atli"):register()
SMODS.Sprite:new("sylvie_moons", mod.path, "sylvie_moons.png", 71, 95, "asset_atli"):register()
SMODS.Sprite:new("sylvie_blinds", mod.path, 'sylvie_blinds.png', 34, 34, 'animation_atli', 21):register()

SMODS.Blind:new('The Prospector', 'prospector', {name = 'The Prospector', text = {'All Stone, Steel, Gold, and', 'Glass cards are debuffed'}}, 5, 2, {}, {}, {x=0, y=0}, {min = 2, max = 10}, HEX('e57f8d'), false, "sylvie_blinds"):register()
SMODS.Blind:new('The Gambler', 'gambler', {name = 'The Gambler', text = {'All Wild, Lucky, Mult, and', 'Bonus cards are debuffed'}}, 5, 2, {}, {}, {x=0, y=1}, {min = 2, max = 10}, HEX('62679a'), false, "sylvie_blinds"):register()
SMODS.Blind:new('The Pathway', 'pathway', {name = 'The Pathway', text = {'All 6, 7, 8, 9, and', '10 cards are debuffed'}}, 5, 2, {}, {}, {x=0, y=2}, {min = 1, max = 10}, HEX('9a8a43'), false, 'sylvie_blinds'):register()
SMODS.Blind:new('The Backside', 'backside', {name = 'The Backside', text = {'All Ace, 2, 3, 4, and', '5 cards are debuffed'}}, 5, 2, {}, {}, {x=0, y=3}, {min = 1, max = 10}, HEX('88619a'), true, 'sylvie_blinds'):register()
SMODS.Blind:new('The Heatwave', 'heatwave', {name = 'The Heatwave', text = {'All even cards are', 'drawn face down'}}, 5, 2, {}, {}, {x=0, y=4}, {min = 2, max = 10}, HEX('b72041'), true, 'sylvie_blinds'):register()
SMODS.Blind:new('The Frost', 'frost', {name = 'The Frost', text = {'All odd cards are', 'drawn face down'}}, 5, 2, {}, {}, {x=0, y=5}, {min = 2, max = 10}, HEX('5090b7'), true, 'sylvie_blinds'):register()

SMODS.Deck:new("Lemon-Lime Deck", "ss_lemonlime", {lldmodifier = true, discards = -1, atlas = 'sylvie_backs'}, {x = 0, y = 5}, lld_def):register()
SMODS.Deck:new("Aurora Deck", "ss_aurora", {vouchers = {'v_hone', 'v_glow_up'},auroramodifier = true, consumables = {'c_aura'}, joker_slot = -1, hands = -1, atlas = 'sylvie_backs'}, {x = 2, y = 5}, aurora_def):register()
SMODS.Deck:new("Sulfur Deck", "ss_sulfur", {consumables = {'c_death'}, joker_rate = 4, voucher = 'v_overstock_norm', atlas = 'sylvie_backs'}, {x = 3, y = 5}, sulfur_def):register()
SMODS.Deck:new("Hallowed Deck", "ss_hallowed", {tarot_rate = 0, planet_rate = 0, playing_card_rate = 10, voucher = 'v_magic_trick', atlas = 'sylvie_backs'},{x = 1, y = 5}, hallow_def):register()
--SMODS.Deck:new("Deck OS", "ss_deckos", {deckosmodifier = true, atlas = 'sylvie_backs'}, {x = 4, y = 5}, deckos_def)

for key,info in ipairs(sylvie_moons) do
    local v = sylvie_moons[key]
    SMODS.Planet:new(v.name, v.slug, v.config, v.pos, {name = v.name, text = v.text }, 3, 1.0, v.effect, 1, true, true, "sylvie_moons"):register()
    SMODS.Planets["c_"..v.slug].loc_def = v.loc_def
    SMODS.Planets["c_"..v.slug].can_use = v.can_use
    SMODS.Planets["c_"..v.slug].use = v.use
    SMODS.Planets["c_"..v.slug].set_badges = v.set_badges
end

end
----------------------------------------------
------------MOD CODE END----------------------