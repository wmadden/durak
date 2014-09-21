_ = require 'underscore'
class AI
  constructor: (@game, @player) ->

  perform: ->
    if @amAttacker()
      if @game.thereAreNoCardsInPlay()
        @player.attack(@player.hand[0]) if @player.hand.length > 0
      @addCardsToThoseInPlay()
      if @game.allCardsHaveBeenDefended()
        @player.acceptDefence()
    else if @amDefender() and not @game.thereAreNoCardsInPlay()
      @defend()
      if not @game.allCardsHaveBeenDefended()
        @player.concedeDefence()
    else
      @addCardsToThoseInPlay()

  amAttacker: -> @game.attacker == @player
  amDefender: -> @game.defender == @player

  defend: ->
    undefendedCards = _(@game.attackingCards).filter (card) -> not card.defendedBy?
    for card in undefendedCards
      @defendAgainst(card)

  defendAgainst: (attackingCard) ->
    for card in @player.hand
      if attackingCard.suit == @game.trumps
        continue unless card.suit == @game.trumps
        if card.value > attackingCard.value
          @player.defend(attackingCard, with: card)
          return
      else
        if card.suit == @game.trumps
          @player.defend(attackingCard, with: card)
          return
        else if card.suit == attackingCard.suit
          if card.value > attackingCard.value
            @player.defend(attackingCard, with: card)
            return

  addCardsToThoseInPlay: ->
    for card in @player.hand
      if @cardValueInPlay(card.value)
        if @game.defender.hand.length > @game.attackingCards.length
          @player.attack(card)

  cardValueInPlay: (value) ->
    _(@game.attackingCards).some (card) ->
      card.value == value || card.defendedBy?.value == value

exports.AI = AI
