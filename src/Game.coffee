Deck = require('./Deck').Deck
Player = require('./Player').Player
_ = require('underscore')

class Game
  constructor: ({ numberOfPlayers }) ->
    @players = []
    for i in [0..numberOfPlayers-1]
      @players.push new Player(i, @)
    @deck = new Deck()
    @round = 0

  start: ->
    @deck.shuffle()
    @attacker = @players[0]
    @defender = @players[1]
    @trumpCard = @deck.cards[0]
    @trumps = @trumpCard.suit
    @deck.deal(upTo: 6, to: @players)
    @progressToNextRound()

  progressToNextRound: ->
    @checkForEndConditions()
    return if @isFinished

    @round += 1
    @deck.deal(upTo: 6, to: @players)
    @attackingCards = []

  checkForEndConditions: ->
    playersWithCards = _(@players).filter (player) -> player.hand.length > 0
    if playersWithCards.length <= 1
      @finalResult = { durak: playersWithCards[0] }
      @isFinished = true

  attack: (player, card) ->
    if player == @defender
      throw new Error("Defender may not attack")

    # Should we check that the card is in the player's hand?

    unless (@thereAreNoCardsInPlay() && player == @attacker) || @cardValueIsInPlay(card)
      throw new Error("Card value is not yet in play")

    unless @defender.hand.length > @undefendedCards().length
      throw new Error("Defender can't defend any more cards than are already in play")

    player.hand = _(player.hand).without(card)
    @attackingCards.push(card)

  defend: (player, attackingCard, with: defendingCard) ->
    unless player == @defender
      throw new Error("Only the defender can defend")
    unless _(@attackingCards).contains(attackingCard)
      throw new Error("Card is not attacking")

    # Should we check that the card is in the player's hand?

    defendCard = =>
      player.hand = _(player.hand).without(defendingCard)
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

    @attacker = @nextPlayerWithCardsAfter(@attacker)
    @defender = @nextPlayerWithCardsAfter(@attacker)
    @progressToNextRound()

  concedeDefence: (player) ->
    unless player == @defender
      throw new Error('Only the defender may concede the round')

    unless @attackingCards.length > 0
      throw new Error('The round may not be conceded until an attack has been made')

    if @allCardsHaveBeenDefended()
      throw new Error('May not concede a successful defence')

    assignCardsInPlayToDefender = =>
      for card in @attackingCards
        @defender.hand.push(card)
        @defender.hand.push(card.defendedBy) if card.defendedBy?

    resetDefendedCards = =>
      for card in @attackingCards
        delete card.defendedBy

    assignCardsInPlayToDefender()
    resetDefendedCards()
    @attacker = @nextPlayerWithCardsAfter(@defender)
    @defender = @nextPlayerWithCardsAfter(@attacker)
    @progressToNextRound()

  undefendedCards: ->
    _(@attackingCards).filter (card) -> not card.defendedBy?

  thereAreNoCardsInPlay: -> @attackingCards.length == 0

  cardValueIsInPlay: (card) ->
    _(@attackingCards).some (otherCard) ->
      otherCard.value == card.value || otherCard.defendedBy?.value == card.value

  allCardsHaveBeenDefended: ->
    for card in @attackingCards
      unless card.defendedBy?
        return false
    return true

  nextPlayerWithCardsAfter: (player) ->
    index = @players.indexOf(player)
    tail = @players[index+1..]
    head = if index > 0 then @players[..index-1] else []
    otherPlayersInOrder = tail.concat head
    _(otherPlayersInOrder).find (player) -> player.hand.length > 0

exports.Game = Game
