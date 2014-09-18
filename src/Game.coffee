Deck = require('./Deck').Deck
Player = require('./Player').Player
_ = require('underscore')

class Game
  constructor: ({ numberOfPlayers }) ->
    @players = []
    for i in [0..numberOfPlayers-1]
      @players.push new Player(i+1)
    @deck = new Deck()

  start: ->
    @deck.shuffle()
    @deck.deal(6, to: @players)
    @attacker = @players[0]
    @defender = @players[1]
    @attackingCards = []

  attack: (player, card) ->
    if player == @defender
      throw new Error("Defender may not attack")

    if (@thereAreNoCardsInPlay() && player == @attacker) || @cardValueIsInPlay(card)
      @attackingCards.push(card)
      player.hand = _(player.hand).without(card)
    else
      throw new Error("Card value is not yet in play")

  defend: (player, attackingCard, with: defendingCard) ->

  pass: (player) ->

  take: (player) ->

  thereAreNoCardsInPlay: -> @attackingCards.length == 0

  cardValueIsInPlay: (card) ->
    _(@attackingCards).some (otherCard) -> otherCard.value == card.value

exports.Game = Game
