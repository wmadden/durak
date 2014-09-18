sinon = require('sinon')
expect = require('chai').expect
chai = require("chai")
sinonChai = require("sinon-chai")

chai.use(sinonChai)

{ Game, Player } = require('./Game')
Deck = require('./Deck').Deck
subject = null

describe 'Game', ->
  game = null

  describe 'a new Game', ->
    numberOfPlayers = null

    beforeEach ->
      options = { numberOfPlayers: numberOfPlayers = 4 }
      subject = -> new Game(options)

    it 'should have a deck of cards', ->
      expect(subject().deck).to.be.an.instanceof(Deck)

    it 'should have the specified number of players', ->
      game = subject()
      expect(game.players).to.have.length(numberOfPlayers)
      for player in game.players
        expect(player).to.be.an.instanceof(Player)

  describe 'start()', ->
    beforeEach ->
      game = new Game(numberOfPlayers: 4)
      subject = -> game.start()

    it 'should deal six cards to each player', ->
      sinon.stub(game.deck, 'deal')
      subject()
      expect(game.deck.deal).to.have.been.calledWith(6, to: game.players)

      # for player in game.players
        # expect(player.hand).to.have.length(6)
