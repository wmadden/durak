Deck = require('./Deck').Deck
Player = require('./Player').Player
_ = require('underscore')

class Game
  constructor: ({ numberOfPlayers }) ->
    @players = []
    for i in [0..numberOfPlayers-1]
      @players.push new Player(i)
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

    @_takeCardFromPlayer(player, card)
    @attackingCards.push(card)

  defend: (player, attackingCard, with: defendingCard) ->
    unless player == @defender
      throw new Error("Only the defender can defend")
    unless _(@attackingCards).contains(attackingCard)
      throw new Error("Card is not attacking")

    # Should we check that the card is in the player's hand?

    defendCard = =>
      @_takeCardFromPlayer(player, defendingCard)
      attackingCard.defendedBy = defendingCard

    if defendingCard.suit == @trumps
      if attackingCard.suit != @trumps
        defendCard()
      else if defendingCard.value > attackingCard.value
        defendCard()
      else
        throw new Error("#{defendingCard} is not a high enough trump to defend against #{attackingCard}")
    else if defendingCard.suit != attackingCard.suit
      throw new Error("#{defendingCard} is not the same suit as #{attackingCard}")
    else
      if defendingCard.value > attackingCard.value
        defendCard()
      else
        throw new Error("#{defendingCard} is not high enough to defend against #{attackingCard}")

  acceptDefence: (player) ->
    unless player == @attacker
      throw new Error('Only the attacking player may accept the defence')

    unless @attackingCards.length > 0
      throw new Error('You must attack at least once')

    unless @allCardsHaveBeenDefended()
      throw new Error('Not all cards have been defended')

    @attacker = @defender
    @defender = @playerAfter(@attacker)

  concedeDefence: (player) ->
    unless player == @defender
      throw new Error('Only the defender may concede the round')

    unless @attackingCards.length > 0
      throw new Error('The round may not be conceded until an attack has been made')

    if @allCardsHaveBeenDefended()
      throw new Error('May not concede a successful defence')

    @_assignCardsInPlayToDefender()
    @_resetDefendedCards()
    @attackingCards = []
    @attacker = @playerAfter(@defender)
    @defender = @playerAfter(@attacker)

  thereAreNoCardsInPlay: -> @attackingCards.length == 0

  cardValueIsInPlay: (card) ->
    _(@attackingCards).some (otherCard) -> otherCard.value == card.value

  allCardsHaveBeenDefended: ->
    for card in @attackingCards
      unless card.defendedBy?
        return false
    return true

  playerAfter: (player) ->
    index = @players.indexOf(player) + 1
    @players[index % @players.length]

  _resetDefendedCards: ->
    for card in @attackingCards
      delete card.defendedBy

  _assignCardsInPlayToDefender: ->
    for card in @attackingCards
      @defender.hand.push(card)
      @defender.hand.push(card.defendedBy) if card.defendedBy?

  _takeCardFromPlayer: (player, card) ->
    player.hand = _(player.hand).without(card)

exports.Game = Game
