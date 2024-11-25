local item = table.deepcopy(data.raw["item"]["constant-combinator"])

item.name = "Research_Control_Combinator"
item.place_result = "Research_Control_Combinator"
item.icon = data.raw["constant-combinator"]["constant-combinator"].icon
item.icon_size = data.raw["constant-combinator"]["constant-combinator"].icon_size
item.order = "z[Research_Control_Combinator]"

data:extend({item})
