_ = require('underscore')
suit = (name) ->
  { name: name }

generateCards = ->
  result = []
  for name, suit of Deck.Suits
    for value in [2..14]
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
  @Suits: Object.freeze({
    Hearts: suit('Hearts'),
    Clubs: suit('Clubs'),
    Diamonds: suit('Diamonds'),
    Spades: suit('Spades')
  })

  constructor: ->
    @cards = generateCards()

  deal: (cardsPerPlayer, { to: players })->
    cardsToDeal = cardsPerPlayer * players.length
    for i in [0 .. cardsToDeal-1]
      player = players[i % players.length]
      player.hand.push(@cards.pop())

  shuffle: ->
    @cards = _(@cards).shuffle()

Card = class Card
  constructor: (@value, @suit) ->

  inspect: -> "(#{valueName @value} of #{@suit.name})"

exports.Deck = Deck
