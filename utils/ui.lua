function G.FUNCS.textures_button(e)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = create_UIBox_texture_selection()
	})
end

function G.FUNCS.texture_type(e)
    sendDebugMessage(e.config.id)
end

function create_texture_buttons(current_buttons, page)
    if #current_buttons.nodes > 0 then current_buttons.nodes = {} end
    local total_buttons = 11
    local start_index = 0 + (page * total_buttons) -- page number needs to affect
    for i=1, total_buttons do
        if i+start_index > #AltTextures_Utils.texture_types then break end
        local type = AltTextures_Utils.texture_types[i+start_index]
        local button = UIBox_button({
            button = 'texture_type',
            colour = AltTextures_Utils.selectors[type] and Malverk.badge_colour or G.C.GREY,
            label = {localize('b_'..type)},
            minw = 2.5,
            minh = 0.6,
            scale = 0.35,
            id = type
        })
        if not AltTextures_Utils.selectors[type] then
            button.nodes[1].config.button = nil
            button.nodes[1].config.hover = false
        end
        table.insert(current_buttons.nodes, button)
    end
end

function G.FUNCS.update_buttons(args)
    create_texture_buttons(args.cycle_config.ref_table, 1)
end

function texture_displays(page)
    local rows = 2
    local cols = 6
    
    local output = {n=G.UIT.R, config = {}, nodes = {}}
    for i=1, rows do
        local row = {n=G.UIT.R, config = {padding = 0.1}, nodes = {}}
        for j=1, cols do
            if (cols*(i-1) + j) > #TexturePacks then break end
            local texture_pack = TexturePacks[j + cols*(i-1)]
            local node = {n=G.UIT.C, config = {minw=2, minh = 2.5, r=0.1, colour = G.C.BLUE}}
            table.insert(row.nodes, node)
        end
        table.insert(output.nodes, row)
    end

    return output
end

function create_UIBox_texture_selection()
    Malverk:update_atlas()
    Malverk.texture_pack_priority_area = CardArea(G.ROOM.T.w, G.ROOM.T.h, 11, G.CARD_H, 
    {type = 'joker', highlight_limit = 1, deck_height = 0.75, thin_draw = 1, texture_priority = true})
    Malverk.texture_pack_priority_area.ARGS.invisible_area_types = {joker=1}
    for _, texture_pack in ipairs(Malverk.config.selected) do
        if TexturePacks[texture_pack] then
            local card = create_texture_card(Malverk.texture_pack_priority_area, texture_pack)
            card.params.texture_priority = true
            Malverk.texture_pack_priority_area:emplace(card)
        end
    end
    
    generate_texture_pack_areas()
    local t = create_UIBox_generic_options({ back_func = 'options', contents = {
        {n=G.UIT.R, config = {colour = G.C.CLEAR, align = 'cm', minw = 12, minh = 10}, nodes = {
            {n=G.UIT.C, config={align = "cm", padding = 0.15, r = 0.1, minw = 12}, nodes={
                {n=G.UIT.R, config = {colour = G.C.BLACK, r = 0.1, minh = 2.5, minw = 12, align = 'cm'}, nodes = {
                    {n=G.UIT.C, config = {align = 'cm', padding = 0.1, minw = 0.5}, nodes = {{n=G.UIT.T, config = {text = localize('malverk_low'), scale = 0.5, vert = true, colour = G.C.L_BLACK}}}},
                    {n=G.UIT.C, config = {align = 'cm', minw = 11}, nodes = {
                        -- {n=G.UIT.T, config = {text = 'priority card area', scale = 0.7, colour = G.C.WHITE}}
                        {n = G.UIT.O, config = {object = Malverk.texture_pack_priority_area, colour = G.C.BLUE}}
                    }},
                    {n=G.UIT.C, config = {align = 'cm', padding = 0.1, minw = 0.5}, nodes = {{n=G.UIT.T, config = {text = localize('malverk_high'), scale = 0.5, vert = true, colour = G.C.L_BLACK}}}},
                }},
                -- Main Texture Select Display
                {n=G.UIT.R, config = {colour = G.C.BLACK, r = 0.1, minh = 7.5, minw = 12, align = 'tm'}, nodes = {
                    generate_texture_pack_areas_ui(),
                    -- Page cycler
                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                        table.size(TexturePacks) > 10 and {n=G.UIT.C, config={r = 0.1, colour = Malverk.badge_colour, minw = 1.5, align = 'tm', shadow = true, direction = -1, button = 'malverk_change_page', hover = true, minh = 0.5}, nodes = {
                            {n=G.UIT.T, config = {text = '<', scale = 0.5, colour = G.C.WHITE}}
                        }} or nil,
                        {n=G.UIT.C, config = {align = 'cm', minw = 4}, nodes = {
                            {n=G.UIT.O, config = {object = DynaText({
                                string = {{ref_table = Malverk.texture_pack_areas_page, ref_value = 'text'}},
                                scale = 0.5,
                                colours = {G.C.WHITE},
                                pop_in_rate = 0,
                                silent = true
                            })}}
                        }},
                        table.size(TexturePacks) > 10 and {n=G.UIT.C, config={r = 0.1, colour = Malverk.badge_colour, minw = 1.5, align = 'tm', shadow = true, direction = 1, button = 'malverk_change_page', hover = true, minh = 0.5}, nodes = {
                            {n=G.UIT.T, config = {text = '>', scale = 0.5, colour = G.C.WHITE}}
                        }} or nil,
                    }}
                }},
            }},
        }}
    }})
    return t

end

function create_UIBox_texture_selection_advanced()
    local buttons = {n = G.UIT.R, config = {align = 'tm', minh = 8, padding = 0.1}, nodes = {}}
    create_texture_buttons(buttons, 0)

    local t = create_UIBox_generic_options({ back_func = 'options', contents = {
        {n=G.UIT.R, config = {colour = G.C.CLEAR, align = 'cm', minw = 15, minh = 10}, nodes = {

            {n=G.UIT.C, config={align = "tm", padding = 0.15, r = 0.1, colour = G.C.BLACK, minw = 3, minh = 10}, nodes={
                {n=G.UIT.R, config = {align = 'cm', colour = G.C.CLEAR}, nodes = {
                    {n=G.UIT.T, config = {text = 'Types', scale = 0.5, colour = G.C.L_BLACK}},
                }},
                {n=G.UIT.R, config = {minh = 0.025, r = 0.1, colour = G.C.L_BLACK}},
                buttons,
                {n=G.UIT.R, nodes = {
                    create_option_cycle({options = {'Page 1/2','Page 2/2'}, opt_callback = 'update_buttons', ref_table = buttons, no_pips = true, current_option = 1, colour = G.C.BLUE, w = 2, scale = 0.8, text_scale = 0.35/0.8})
                }}
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.15, r = 0.1, minw = 12}, nodes={
                {n=G.UIT.R, config = {colour = G.C.BLACK, r = 0.1, minh = 2.5, minw = 12, align = 'cm'}, nodes = {
                    {n=G.UIT.C, config = {align = 'cm', padding = 0.1, minw = 0.5}, nodes = {{n=G.UIT.T, config = {text = 'LOWEST', scale = 0.5, vert = true, colour = G.C.L_BLACK}}}},
                    {n=G.UIT.C, config = {align = 'cm', minw = 11}, nodes = {{n=G.UIT.T, config = {text = 'priority card area', scale = 0.7, colour = G.C.WHITE}}}},
                    {n=G.UIT.C, config = {align = 'cm', padding = 0.1, minw = 0.5}, nodes = {{n=G.UIT.T, config = {text = 'HIGHEST', scale = 0.5, vert = true, colour = G.C.L_BLACK}}}},
                }},
                {n=G.UIT.R, config = {colour = G.C.BLACK, r = 0.1, minh = 7.5, minw = 12, align = 'cm'}, nodes = {
                    {n=G.UIT.T, config = {text = 'texture displays', scale = 1, colour = G.C.WHITE}}
                }},
            }},
        }}
    }})
    return t
end


function generate_texture_pack_areas()
    if Malverk.texture_pack_areas then
        for i=1, #Malverk.texture_pack_areas do
            for j=1, #G.I.CARDAREA do
                if Malverk.texture_pack_areas[i] == G.I.CARDAREA[j] then
                    table.remove(G.I.CARDAREA, j)
                    Malverk.texture_pack_areas[i] = nil
                end
            end
        end
    end
    Malverk.texture_pack_areas = {}
    Malverk.texture_pack_areas_page = {
        page = 0,
        total = math.ceil(table.size(TexturePacks)/10),
    }
    Malverk.texture_pack_areas_page.text = localize('k_page')..' '..(Malverk.texture_pack_areas_page.page+1)..'/'..Malverk.texture_pack_areas_page.total
    for i=1, 10 do
        Malverk.texture_pack_areas[i] = CardArea(G.ROOM.T.w,G.ROOM.T.h, G.CARD_W, G.CARD_H, 
        {card_limit = 1, type = 'shop', highlight_limit = 1, deck_height = 0.75, thin_draw = 1, texture_pack = true, index = i})
    end
end

function table.size(table)
    local size = 0
    for _,_ in pairs(table) do
        size = size + 1
    end
    return size
end

function generate_texture_pack_areas_ui()
    local texture_ui_element = {}
    local count = 1
    for i=1, 2 do
        local row = {n = G.UIT.R, config = {colour = G.C.CLEAR}, nodes = {}}
        for j=1, 5 do
            if count > table.size(TexturePacks) then break end
            table.insert(row.nodes, {n = G.UIT.O, config = {object = Malverk.texture_pack_areas[count], r = 0.1, id = "texture_pack_"..count}})
            count = count + 1
        end
        table.insert(texture_ui_element, row)
    end

    populate_texture_select_areas(Malverk.texture_pack_areas_page.page)

    return {n=G.UIT.R, config={align = "tm", minh = 6.3, minw = 5, colour = G.C.CLEAR,
        padding = 0.15, r = 0.1, emboss = 0.05}, nodes = texture_ui_element}
end

function populate_texture_select_areas(page)
    local count = 1 + page * 10
    for i=1, 10 do
        if count > table.size(TexturePacks) then return end
        local card = create_texture_card(Malverk.texture_pack_areas[i], TexturePacks_Utils.keys[count])
        for _, texture in ipairs(Malverk.config.selected) do
            if texture == TexturePacks_Utils.keys[count] then card.texture_selected = true end
        end
        if not Malverk.texture_pack_areas[i].cards then Malverk.texture_pack_areas[i].cards = {} end
        Malverk.texture_pack_areas[i]:emplace(card)
        count = count + 1
    end
end

local card_hover_ref = Card.hover
function Card:hover()
    if self.params.texture_pack and (not self.states.drag.is or G.CONTROLLER.HID.touch) and not self.no_ui and not G.debug_tooltip_toggle then
        self:juice_up(0.05, 0.03)
        play_sound('paper1', math.random()*0.2 + 0.9, 0.35)
        if self.children.alert and not self.config.center.alerted then
            self.config.center.alerted = true
            G:save_progress()
        end

        local col = self.params.deck_preview and G.UIT.C or G.UIT.R
        local info_col = self.params.deck_preview and G.UIT.R or G.UIT.C
        local back = Back(self.config.center)

        local badges = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR, align = 'cm'}, nodes = {}}
        SMODS.create_mod_badges(TexturePacks[self.params.texture_pack], badges.nodes)
        if badges.nodes.mod_set then badges.nodes.mod_set = nil end

        local loc_txt = {}
        localize({type='descriptions', set = 'texture_packs', key = self.params.texture_pack, nodes = loc_txt})
        local desc_node = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR, align = 'cm'}, nodes = {desc_from_rows(loc_txt, true)}}
        
        local changes
        if self.params.texture_pack ~= 'default' then
            changes = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR, align = 'cm'}, nodes ={}}
            local objects = {}
            for _, texture in pairs(TexturePacks[self.params.texture_pack].textures) do
                local set = AltTextures[texture].set
                -- if set == 'Enhanced' then set = 'Enhancement' end
                local count = #AltTextures[texture].keys
                objects[set] = (objects[set] or 0) + count
            end
            for set, count in pairs(objects) do
                local text_node = {n=G.UIT.R, nodes = {
                    {n=G.UIT.C, nodes = {{n=G.UIT.T, config = {text = localize('b_change')..' '..count..' ', scale = 0.28*G.LANG.font.DESCSCALE, colour = G.C.UI.TEXT_DARK}}}},
                    {n=G.UIT.C, nodes = {{n=G.UIT.T, config = {text = localize(AltTextures_Utils.loc_keys[set]), scale = 0.28*G.LANG.font.DESCSCALE, colour = G.C.SECONDARY_SET[set] or G.C.IMPORTANT}}}},
                }}
                changes.nodes[#changes.nodes + 1] = text_node
            end
        end

        self.config.h_popup = {n=G.UIT.C, config={align = "cm", padding=0.1}, nodes={
            {n=col, config={align=(self.params.deck_preview and 'bm' or 'cm')}, nodes = {
                {n=G.UIT.C, config={align = "cm", minh = 1.5, r = 0.1, colour = G.C.L_BLACK, padding = 0.1, outline=1}, nodes={
                    -- Name
                    {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4}, nodes={
                        {n=G.UIT.O, config={object = UIBox{
                            definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
                                {n=G.UIT.O, config={object = DynaText({string = localize({type = 'name_text', set = 'texture_packs', key = self.params.texture_pack}), maxw = 4, colours = {G.C.WHITE}, shadow = true, bump = true, scale = 0.5, pop_in = 0, silent = true})}},
                            }},
                            config = {offset = {x=0,y=0}, align = 'cm', parent = e}}}
                        },
                    }},
                    -- Description Text
                    {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, minh = 1.3, maxh = 3, minw = 3, maxw = 4, r = 0.1}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition = desc_node, config = {offset = {x=0,y=0}}}}}
                    }},
                    -- TODO: Add box detailing number of changes
                    changes and {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, minh = 1.3, minw = 3, maxw = 4, r = 0.1, padding = 0.2}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition = changes, config = {offset = {x=0,y=0}}}}}
                    }},
                    -- Badges
                    badges.nodes[1] and {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition = badges, config = {offset = {x=0,y=0}}}}}
                    }},
                }}
            }},
            
        }}
        self.config.h_popup_config = self:align_h_popup()

        Node.hover(self)
    else
       card_hover_ref(self) 
    end
end

local card_highlight = Card.highlight
function Card:highlight(highlighted)
    if self.params.texture_priority then 
        self.highlighted = highlighted
        if highlighted then
            self.children.use_button = UIBox{
                definition = create_texture_pack_buttons(self), 
                config = {align = 'bm', offset = {x=0, y=-0.4}, parent = self}
            }
        end
        return
    end
    card_highlight(self, highlighted)
    if highlighted and self.area.config.texture_pack then
        self.children.use_button = UIBox{
            definition = create_texture_pack_buttons(self, self.texture_selected), 
            config = {align = 'bm', offset = {x=0, y=-0.4}, parent = self}
        }
    end
end

local applied_shader = SMODS.Shader({key = 'texture_selected', path = 'applied.fs'})

function create_texture_pack_buttons(card, active)
    local apply
    if card.area.config.type == 'joker' then
        apply = {n=G.UIT.C, config={align = "cm"}, nodes={
            {n=G.UIT.C, config={ref_table = card, align = "bm", maxw = G.CARD_W * 0.5, padding = 0.1, r=0.08, minw = 0.5 * G.CARD_W, minh = 0.8, hover = true, colour = G.C.RED, button = 'remove_texture'}, nodes={
                {n=G.UIT.T, config={text = localize('b_remove'), colour = G.C.UI.TEXT_LIGHT, scale = 0.35, shadow = true}}
            }}
        }}
    else
        apply = {n=G.UIT.C, config={align = "cm"}, nodes={
                {n=G.UIT.C, config={ref_table = card, align = "bm", maxw = G.CARD_W * 0.5, padding = 0.1, r=0.08, minw = 0.5 * G.CARD_W, minh = 0.8, hover = true, colour = active and G.C.GREY or G.C.GREEN, button = not active and 'apply_texture'}, nodes={
                    {n=G.UIT.T, config={text = active and localize('b_applied') or localize('b_apply'), colour = G.C.UI.TEXT_LIGHT, scale = 0.35, shadow = true}}
                }}
            }}
    end
    local t = {n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
        {n=G.UIT.C, config={align = 'cm'}, nodes={
            {n=G.UIT.R, config={align = 'cm'}, nodes={
                apply
            }},
        }},
    }}
    return t
end

G.FUNCS.remove_texture = function(e)
    local texture = e.config.ref_table.params.texture_pack
    e.config.ref_table:highlight()
    e.config.ref_table:start_dissolve()
    for _, area in pairs(Malverk.texture_pack_areas) do
        if #area.cards > 0 and area.cards[1].params.texture_pack == texture then
            area.cards[1].texture_selected = false
            area.cards[1]:highlight()
            area.cards[1]:juice_up()
        end
    end
    Malverk.update_priority(texture)
end

G.FUNCS.apply_texture = function(e)
    if e.config.ref_table.texture_selected then
        e.config.ref_table.texture_selected = false
        e.config.ref_table:juice_up()
    else
        e.config.ref_table.texture_selected = true
        e.config.ref_table:juice_up()
        e.config.ref_table:highlight()
        local card = create_texture_card(Malverk.texture_pack_priority_area, e.config.ref_table.params.texture_pack)
        card.params.texture_priority = true
        Malverk.texture_pack_priority_area:emplace(card)
        Malverk.update_priority()
    end
end

G.FUNCS.malverk_change_page = function(e)
    Malverk.change_page(Malverk.texture_pack_areas_page, e.config.direction)
end

Malverk.change_page = function(page_ref, change)
    page_ref.page = page_ref.page + change
    page_ref.page = page_ref.page % page_ref.total
    page_ref.text = 'Page '..(page_ref.page+1)..'/'..page_ref.total
    alt_text_clean_up()
    populate_texture_select_areas(page_ref.page)
end

alt_text_clean_up = function()
    if not Malverk.texture_pack_areas then return end
    for j = 1, #Malverk.texture_pack_areas do
        if Malverk.texture_pack_areas[j].cards then
            remove_all(Malverk.texture_pack_areas[j].cards)
            Malverk.texture_pack_areas[j].cards = {}
        end
    end
end

function create_texture_card(area, texture_pack)
    local texture = AltTextures[TexturePacks[texture_pack].textures[1]]
    local card = Card(area.T.x, area.T.y, G.CARD_W, G.CARD_H,
        nil, copy_table(G.P_CENTER_POOLS.Joker[1]),
        {texture_pack = texture_pack})
    
    local layer = texture.animated and 'animatedSprite' or texture.set == 'Sticker' and 'front' or 'center'    
    local game_table = AltTextures_Utils.game_table[texture.set] or 'P_CENTERS'
    local scale = math.max(texture.atlas.px/71, texture.atlas.py/95)*1.5
    local W = G.CARD_W*(texture.atlas.px/71)/scale
    local H = G.CARD_H*(texture.atlas.py/95)/scale
    

    if texture.animated then
        card.T.w = W
        card.T.h = H
        card.children.animatedSprite = AnimatedSprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ANIMATION_ATLAS[texture.atlas.key], type(texture.display_pos) == 'table' and texture.display_pos or (texture.display_pos and (texture.original_sheet and G[game_table][texture.display_pos].default_pos or G[game_table][texture.display_pos].pos)) or G[game_table][texture.keys[1]].pos)
        card.children.animatedSprite.T.w = W
        card.children.animatedSprite.T.h = H
        card.children.animatedSprite:set_role({major = card, role_type = 'Glued', draw_major = card})
        card.children.animatedSprite:rescale()
        card.children.center:remove()
        card.children.back:remove()
        card.no_shadow = true
        return card
    end

    if layer == 'front' and not card.children[layer] then
        card.children.center.atlas.name = 'centers'
        card.children.center.sprite_pos = {x=1,y=0}
        card.children.center:reset()
        card.children[layer] = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[texture.atlas.key], G[game_table][texture.keys[1]].pos)
        card.children[layer].states.hover = card.states.hover
        card.children[layer].states.click = card.states.click
        card.children[layer].states.drag = card.states.drag
        card.children[layer].states.collide.can = false
        card.children[layer]:set_role({major = card, role_type = 'Glued', draw_major = card})
    end
    
    if texture_pack ~= 'default' then
        card.children[layer].atlas.name = texture.atlas.key
    else
        card.children[layer].atlas.name = 'Joker'
    end
    
    if texture.original_sheet and texture.keys then
        card.children[layer].sprite_pos = G[game_table][texture.keys[1]].default_pos or G[game_table][texture.keys[1]].pos
    end
    
    if texture.display_pos then
        card.children[layer].sprite_pos = type(texture.display_pos) == 'table' and texture.display_pos or (texture.original_sheet and G[game_table][texture.display_pos].default_pos or G[game_table][texture.display_pos].pos)
    end
    
    card.children[layer]:reset()

    if texture.animated then return card end

    if texture.atlas.px ~= 71 and texture.atlas.py ~= 95 and not texture.animated then
        card.T.w = W
        card.T.h = H
        card.children[layer] = Sprite(card.T.x, card.T.y, G.CARD_W, G.CARD_H, G.ASSET_ATLAS[texture.atlas.key], card.children.center.sprite_pos)
        card.children[layer].states.hover = card.states.hover
        card.children[layer].states.click = card.states.click
        card.children[layer].states.drag = card.states.drag
        card.children[layer].states.collide.can = false
        card.children[layer]:set_role({major = card, role_type = 'Glued', draw_major = card})
    end

    if texture.soul_keys and table.contains(texture.soul_keys, texture.keys[1]) then
        card.config[layer].soul_pos = {x = 1 % texture.columns, y = math.floor(1/texture.columns)}
        card.children.floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[texture.atlas.key], card.config[layer].soul_pos)
    end
        
    return card
end

local release_ref = Node.stop_drag
function Node:stop_drag()
    release_ref(self)
    if self.params and self.params.texture_priority then
        Malverk.update_priority()
    end
end

function Malverk.update_priority(removed_key)
    Malverk.config.selected = {}
    for _, card in ipairs(Malverk.texture_pack_priority_area.cards) do
        if card.params.texture_pack ~= removed_key then
            Malverk.config.selected[#Malverk.config.selected + 1] = card.params.texture_pack
        end
    end
    Malverk.update_atlas()
    SMODS.save_mod_config(Malverk)
end

local align_ref = CardArea.align_cards
function CardArea:align_cards()
    if self.config.texture_pack then
        for k, card in ipairs(self.cards) do
            if not card.states.drag.is then 
                card.T.r = 0
                local max_cards = math.max(#self.cards, self.config.temp_limit)
                card.T.x = self.T.x + self.T.w/2 - card.T.w/2
                local highlight_height = G.HIGHLIGHT_H
                if not card.highlighted then highlight_height = 0 end
                card.T.y = self.T.y + self.T.h/2 - card.T.h/2 - highlight_height
                card.T.x = card.T.x + card.shadow_parrallax.x/30
            end
        end
        table.sort(self.cards, function (a, b) return a.T.x + a.T.w/2 < b.T.x + b.T.w/2 end)
    else
        align_ref(self)
    end
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end