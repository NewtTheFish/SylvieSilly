--- STEAMODDED HEADER
--- MOD_NAME: Sylvie's Silliness
--- MOD_ID: SylvieSilly
--- MOD_AUTHOR: [NewtTheFish]
--- MOD_DESCRIPTION: A few decks, jokers, etc. Have fun!

----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.SylvieSilly()
local ch_SylvieSilly_art = SMODS.findModByID("SylvieSilly")
local EnhancersSylvie = SMODS.Sprite:new("centers", ch_SylvieSilly_art.path, "Enhancers.png", 71, 95, "asset_atli")
EnhancersSylvie:register()

local lld_def = {
    ["name"] = "Lemon-Lime Deck",
    ["text"] = {
        [1] = "Divides up the deck!",
        [2] = "{C:red}-1{} discard, {C:red}-1{} hand.",
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
        [3] = "are always {C:dark_edition}Special.",
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

local cardsetedition = Card.set_edition
function Card.set_edition(self, edition, immediate, silent)
    cardsetedition(self, edition, immediate, silent)
    if G.GAME.starting_params.auroramodifier and self.ability.set == 'Joker' and edition == nil then
        local rngedition = pseudorandom(pseudoseed('random_edition'))
        if rngedition > 0.5 then self:set_edition({foil = true})
        elseif rngedition > 0.1 then self:set_edition({holo = true})
        elseif rngedition > 0.01 then self:set_edition({polychrome = true})
        else self:set_edition({negative = true})
        end
    end

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

local LemonLimeDeck = SMODS.Deck:new("Lemon-Lime Deck", "ss_lemonlime", {lldmodifier = true, discards = -1, hands = -1}, {x = 0, y = 5}, lld_def)
local AuroraDeck = SMODS.Deck:new("Aurora Deck", "ss_aurora", {auroramodifier = true, consumables = {'c_aura'}, joker_slot = -1, hands = -1}, {x = 2, y = 5}, aurora_def)
local SulfurDeck = SMODS.Deck:new("Sulfur Deck", "ss_sulfur", {consumables = {'c_death'}, joker_rate = 4, voucher = 'v_overstock_norm'}, {x = 3, y = 5}, sulfur_def)
local HallowedDeck = SMODS.Deck:new("Hallowed Deck", "ss_hallowed", {tarot_rate = 0, planet_rate = 0, playing_card_rate = 10, voucher = 'v_magic_trick'},{x = 1, y = 5}, hallow_def)

LemonLimeDeck:register()
SulfurDeck:register()
AuroraDeck:register()
HallowedDeck:register()

end
----------------------------------------------
------------MOD CODE END----------------------