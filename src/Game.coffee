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
    @trumpCard = @deck.cards[0]
    @trumps = @trumpCard.suit

  attack: (player, card) ->
    if player == @defender
      throw new Error("Defender may not attack")

    # Should we check that the card is in the player's hand?

    unless (@thereAreNoCardsInPlay() && player == @attacker) || @cardValueIsInPlay(card)
      throw new Error("Card value is not yet in play")

    @attackingCards.push(card)
    player.hand = _(player.hand).without(card)

  defend: (player, attackingCard, with: defendingCard) ->
    unless player == @defender
      throw new Error("Only the defender can defend")
    unless _(@attackingCards).contains(attackingCard)
      throw new Error("Card is not attacking")

    # Should we check that the card is in the player's hand?

    unless @cardComparisonValue(defendingCard) > @cardComparisonValue(attackingCard)
      throw new Error("#{defendingCard} is too low to defend #{@attackingCard}")

    attackingCard.defendedBy = defendingCard

  pass: (player) ->

  take: (player) ->

  thereAreNoCardsInPlay: -> @attackingCards.length == 0

  cardValueIsInPlay: (card) ->
    _(@attackingCards).some (otherCard) -> otherCard.value == card.value

  cardComparisonValue: (card) ->
    if card.suit == @trumps
      card.value + Deck.HIGHEST_CARD_VALUE
    else
      card.value

exports.Game = Game
