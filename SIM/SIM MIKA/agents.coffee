# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# This model shows the basic structure of a model and is a good
# place to get started when you want to try building your own.
#
# To build your own model, extend class ABM.Model supplying the
# two built in methods `setup` and `step`.
#
#`@foo` signifies a variable or method that is part of the Model
# class.
#
# Note how this example uses CoffeeScript directly within the
# browser via [text/coffeescript tags](http://coffeescript.org/#scripts):

u = ABM.util # shortcut for ABM.util, some tools

log = (arg) -> console.log arg # log to the browser console


class ABM.TemplateModel extends ABM.Model
  # Initialize our model via the `setup` method. This model simply
  # creates a population of agents with arbitrary shapes on a grid
  # of patches colored in random shades of gray.
  #
# utilities
  patchRectangle: (point, dw, dh) ->
    @patches.patchRectangle @patches.patch(point), dw, dh, true

#global variable

  setup: -> # called by Model constructor
    @energyColor = u.color.green
    @workColor = u.color.orange
    @agents.setDefault "shape", "person"
    @amateur = u.color.red
    @professional = u.color.blue
    @superheroi = u.color.green
    for patch in @patches.create()
        patch.color = @workColor

    for patch in @patchRectangle {x:-10, y: -8}, 2, 2
         patch.color = @energyColor


    for agent in @agents.create 50
      agent.size = 3
      agent.position = {x : u.randomInt(15), y : u.randomInt(15)}
      agent.color = u.color.pink
      agent.comida = u.randomInt(250,500)
      agent.resistencia = u.randomInt(0,50)
      agent.velocitat = 0
      agent.quantitatmenjar = 0
      agent.menjant = 0
  # Update, or run our model for one step, via the second built in
  # method, `step`.
  step: -> # called by Model.animate
    for agent in @agents
        if agent.comida <= 0 and agent.quantitatmenjar < 5 and agent.menjant == 0
            agent.moveTo x : -10, y: -8
            agent.menjant = 1
        else if agent.quantitatmenjar < 5 or agent.comida >= 0 or agent.menjant == 1
            if agent.resistencia > 1250 and agent.velocitat > 1250
                agent.color = @superheroi

            else if agent.resistencia > 1100 and agent.velocitat > 1100
                agent.color = @professional
            else if agent.resistencia > 950 and agent.velocitat > 950
                agent.color = @amateur

            if agent.patch.color == @energyColor and agent.comida < 50
                if agent.resistencia > 100
                    agent.comida = u.randomInt(250,500)

                else if agent.resistencia > 50
                    agent.comida += u.randomInt(125,250)

                else agent.comida +=u.randomInt(50,100)

            else if agent.patch.color == @energyColor and agent.comida >= 50
                if  agent.menjant == 1
                    agent.menjant = 0
                    agent.quantitatmenjar += 1
                    agent.moveTo x : u.randomInt(0,-12), y: -12
                    agent.forward 0.6
                else
                    agent.rotate u.degreesToRadians(120)
                    agent.forward 0.6
            else
                actualres = u.randomInt(2,7)
                actualvel = u.randomInt(2,9)
                agent.resistencia += actualres
                agent.velocitat += actualvel
                agent.comida = agent.comida - actualres - actualvel
                agent.forward 0.6

            if agent.patch.isOnEdge()
                agent.rotate u.degreesToRadians(120)
                agent.forward 0.6




window.model = new ABM.TemplateModel({
  div: "world",
  isTorus: true
})
window.model.start()

# Uses the AgentBase library (03-02-2017 release)
# https://github.com/wybo/agentbase/commit/3501302567c018da82601cd858be2ea6d0b9c74d
