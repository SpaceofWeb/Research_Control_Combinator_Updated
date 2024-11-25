local recipe = table.deepcopy(data.raw["recipe"]["constant-combinator"])

recipe.name = "Research_Control_Combinator"
recipe.enabled = true
recipe.ingredients = {
    {type = "item", name = "electronic-circuit", amount = 5},
    {type = "item", name = "iron-plate", amount = 2}
}
recipe.results = {
    {type = "item", name = "Research_Control_Combinator", amount = 1}
}
recipe.localised_name = {"", "Research Control Combinator"}

data:extend({recipe})