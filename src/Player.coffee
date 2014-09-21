class Player
  constructor: (@number, @game) ->
    @hand = []

  attack: (card) ->
    console.log "Player #{@number} attacks with #{card}"
    @game.attack(@, card)

  defend: (attackingCard, with: defendingCard) ->
    console.log "Player #{@number} defends #{attackingCard} with #{defendingCard}"
    @game.defend(@, attackingCard, with: defendingCard)

  acceptDefence: ->
    console.log "Player #{@number} accepts defence"
    @game.acceptDefence(@)

  concedeDefence: ->
    console.log "Player #{@number} concedes"
    @game.concedeDefence(@)

exports.Player = Player
