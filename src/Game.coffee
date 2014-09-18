Deck = require('./Deck').Deck

class Game
  constructor: ({ numberOfPlayers }) ->
    @players = []
    for i in [0..numberOfPlayers-1]
      @players.push new Player()
    @deck = new Deck()

  start: ->
    @deck.deal(6, to: @players)

class Player
  constructor: ->
    @hand = []

exports.Game = Game
exports.Player = Player
