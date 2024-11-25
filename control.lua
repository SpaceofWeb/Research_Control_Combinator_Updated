-- Debug flag: set to true to enable debug logging
local debug = false

local function log_debug(message)
    if debug then
        game.print("[DEBUG] " .. message)
    end
end

-- Function to map signal names to research technologies
local function map_signal_to_research(signal_name)
    local research_map = {
        ["signal-1"] = "stronger-explosives-7",
        ["signal-2"] = "refined-flammables-7",
        ["signal-3"] = "plastic-bar-productivity",
        ["signal-4"] = "rocket-fuel-productivity",
        ["signal-5"] = "health",
        ["signal-6"] = "asteroid-productivity",
        ["signal-7"] = "railgun-damage-1",
        ["signal-8"] = "research-productivity",
        ["signal-9"] = "artillery-shell-damage-1",
        ["signal-A"] = "artillery-shell-range-1",
        ["signal-B"] = "artillery-shell-speed-1",
        ["signal-C"] = "electric-weapons-damage-4",
        ["signal-D"] = "follower-robot-count-5",
        ["signal-E"] = "laser-weapons-damage-7",
        ["signal-F"] = "low-density-structure-productivity",
        ["signal-G"] = "mining-productivity-3",
        ["signal-H"] = "physical-projectile-damage-7",
        ["signal-I"] = "processing-unit-productivity",
        ["signal-J"] = "railgun-shooting-speed-1",
        ["signal-K"] = "rocket-part-productivity",
        ["signal-L"] = "scrap-recycling-productivity",
        ["signal-M"] = "steel-plate-productivity",
        ["signal-N"] = "worker-robots-speed-7"
    }
    return research_map[signal_name]
end

-- Validate and extract signals from a combinator
local function get_signals_from_combinator(combinator)
    if not combinator.valid then
        return {}
    end

    -- Get the circuit network for combinator input
    local red_network = combinator.get_circuit_network(defines.wire_connector_id.combinator_input_red)
    local green_network = combinator.get_circuit_network(defines.wire_connector_id.combinator_input_green)

    -- Combine signals from both networks
    local signals = {}
    if red_network and red_network.signals then
        for _, signal in ipairs(red_network.signals) do
            table.insert(signals, signal)
        end
    end
    if green_network and green_network.signals then
        for _, signal in ipairs(green_network.signals) do
            table.insert(signals, signal)
        end
    end

    return signals
end

-- Process all registered combinators
local function process_combinators()
    if not storage.combinators then
        log_debug("storage.combinators is nil. Skipping processing.")
        return
    end

    for unit_number, combinator_data in pairs(storage.combinators) do
        -- Validate combinator data
        if not combinator_data or not combinator_data.entity or not combinator_data.entity.valid then
            storage.combinators[unit_number] = nil
        else
            local combinator = combinator_data.entity
            local signals = get_signals_from_combinator(combinator)

            -- Skip if no signals
            if #signals > 0 then
                -- Process signals
                for _, signal in ipairs(signals) do
                    if signal.signal and signal.signal.type == "virtual" then
                        local research_name = map_signal_to_research(signal.signal.name)
                        if research_name then
                            local force = game.forces.player
                            if force.current_research and force.current_research.name == research_name then
                                log_debug("Research already set: " .. research_name)
                            else
                                -- Clear the research queue and add new research
                                force.research_queue = {}
                                local success = force.add_research(research_name)
                                
                                if success then
                                    log_debug("Set research to: " .. research_name)
                                else
                                    log_debug("Failed to set research: " .. research_name)
                                end
                            end
                        else
                            log_debug("No research mapped for signal: " .. signal.signal.name)
                        end
                    end
                end
            end
        end
    end
end

-- Handle combinator placement
local function on_built(event)
    local entity = event.created_entity or event.entity
    if not entity or entity.name ~= "Research_Control_Combinator" then return end

    storage.combinators = storage.combinators or {}
    storage.combinators[entity.unit_number] = {
        entity = entity,
        position = entity.position,
        surface = entity.surface.name,
    }
    log_debug("Added combinator with unit number: " .. entity.unit_number)
end

-- Handle combinator removal
local function on_destroy(event)
    local entity = event.entity
    if not entity or entity.name ~= "Research_Control_Combinator" then return end

    if storage.combinators then
        storage.combinators[entity.unit_number] = nil
        log_debug("Removed combinator with unit number: " .. entity.unit_number)
    end
end

-- Initialize storage
local function on_init()
    storage.combinators = storage.combinators or {}
    log_debug("Initialized mod storage.")
end

-- Reinitialize combinators on game reload
local function reinitialize_combinators_on_tick()
    for unit_number, data in pairs(storage.combinators or {}) do
        local surface = game.surfaces[data.surface]
        if surface then
            local entity = surface.find_entity("Research_Control_Combinator", data.position)
            if entity and entity.valid then
                data.entity = entity
            else
                storage.combinators[unit_number] = nil
                log_debug("Removed invalid combinator with unit number: " .. unit_number)
            end
        end
    end
    -- Unregister the one-time on_tick handler
    script.on_event(defines.events.on_tick, nil)
end

-- Register events
local function register_events()
    script.on_event(defines.events.on_built_entity, on_built)
    script.on_event(defines.events.on_robot_built_entity, on_built)
    script.on_event(defines.events.script_raised_built, on_built)
    script.on_event(defines.events.script_raised_revive, on_built)

    script.on_event(defines.events.on_entity_died, on_destroy)
    script.on_event(defines.events.on_pre_player_mined_item, on_destroy)
    script.on_event(defines.events.on_robot_pre_mined, on_destroy)
    script.on_event(defines.events.script_raised_destroy, on_destroy)

    script.on_nth_tick(60, process_combinators)
end

script.on_init(on_init)
script.on_load(function()
    script.on_event(defines.events.on_tick, reinitialize_combinators_on_tick)
end)
register_events()
