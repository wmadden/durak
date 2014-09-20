_ = require('underscore')
suit = (name) ->
  { name: name }

generateCards = ->
  result = []
  for name, suit of Deck.Suits
    for value in [2..Deck.HIGHEST_CARD_VALUE]
      result.push new Card( value, suit )
  result

valueName = (value) ->
  return value if value <= 10
  switch value
    when 11 then 'Jack'
    when 12 then 'Queen'
    when 13 then 'King'
    when 14 then 'Ace'

Deck = class Deck
  @HIGHEST_CARD_VALUE: 14
  @Suits: Object.freeze({
    Hearts: suit('Hearts'),
    Clubs: suit('Clubs'),
    Diamonds: suit('Diamonds'),
    Spades: suit('Spades')
  })

  constructor: ->
    @cards = generateCards()

  deal: (upTo: cardsPerPlayer, to: players)->
    for player in players
      cardsNeeded = cardsPerPlayer - player.hand.length
      for i in [1 .. cardsNeeded]
        return if @cards.length == 0
        player.hand.push(@cards.pop())

  shuffle: ->
    @cards = _(@cards).shuffle()

Card = class Card
  constructor: (@value, @suit) ->

  inspect: -> "#{valueName @value} of #{@suit.name}"

  toString: -> "#{valueName @value} of #{@suit.name}"

  valueOf: ->
    suitNumber = _(Deck.Suits).values().indexOf(@suit)
    suitValue = Deck.HIGHEST_CARD_VALUE * suitNumber
    suitValue + @value

exports.Deck = Deck
