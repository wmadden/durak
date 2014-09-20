class Player
  constructor: (@number, @game) ->
    @hand = []

  attack: (card) ->
    @game.attack(@, card)

  defend: (attackingCard, with: defendingCard) ->
    @game.defend(@, attackingCard, with: defendingCard)

  acceptDefence: ->
    @game.acceptDefence(@)

  concedeDefence: ->
    @game.concedeDefence(@)

exports.Player = Player
