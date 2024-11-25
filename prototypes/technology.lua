local technology = table.deepcopy(data.raw["technology"]["circuit-network"])

technology.name = "research-control-combinator"
technology.localised_name = {"", "Research Control Combinator"}
technology.effects = {
    {type = "unlock-recipe", recipe = "Research_Control_Combinator"}
}
technology.unit = {
    count = 50,
    ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
    time = 30
}
technology.prerequisites = {"circuit-network"}
technology.order = "a-d-d"

data:extend({technology})
