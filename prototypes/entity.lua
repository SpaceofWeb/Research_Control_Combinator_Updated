local combinator = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
combinator.localised_name = {"", "Research Control Combinator"}
combinator.name = "Research_Control_Combinator"
combinator.minable = {mining_time = 0.1, result = "Research_Control_Combinator"}
combinator.item_slot_count = 10
combinator.icon = data.raw["constant-combinator"]["constant-combinator"].icon
combinator.icon_size = data.raw["constant-combinator"]["constant-combinator"].icon_size
combinator.control_behavior = nil
data:extend({combinator})
