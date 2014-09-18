sinon = require('sinon')
expect = require('chai').expect
chai = require("chai")
sinonChai = require("sinon-chai")
_ = require("underscore")

chai.use(sinonChai)

Game = require('./Game').Game
Player = require('./Player').Player
Deck = require('./Deck').Deck
subject = null

describe 'Game', ->
  game = null

  beforeEach ->
    game = new Game(numberOfPlayers: 4)

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
      subject = -> game.start()

    it 'should shuffle the deck', ->
      sinon.stub(game.deck, 'shuffle')
      subject()
      expect(game.deck.shuffle).to.have.been.calledWith()

    it 'should deal six cards to each player', ->
      sinon.stub(game.deck, 'deal')
      subject()
      expect(game.deck.deal).to.have.been.calledWith(6, to: game.players)

    it "should be the first player's turn to attack", ->
      subject()
      expect(game.attacker).to.equal(game.players[0])

    it "should be the second player's turn defend", ->
      subject()
      expect(game.defender).to.equal(game.players[1])

  describe 'attack(player, card)', ->
    player = null
    card = null

    beforeEach ->
      game.start()
      card = { value: 2, suit: Deck.Suits.Hearts }
      subject = -> player.hand.push(card); game.attack(player, card)

    itShouldAttackWithTheCard = ->
      it 'should attack with the card', ->
        subject()
        expect(game.attackingCards).to.include(card)

      it "should remove the card from the player's hand", ->
        subject()
        expect(player.hand).not.to.include(card)

    context 'and no cards are yet in play', ->
      context 'but the player is the attacker', ->
        beforeEach ->
          player = game.attacker

        itShouldAttackWithTheCard()

      context 'and the player is not the attacker', ->
        beforeEach ->
          player = _(game.players).without(game.attacker, game.defender)[0]

        it 'should be forbidden', ->
          expect(subject).to.throw()

    context 'and there are cards in play', ->
      beforeEach ->
        player = game.attacker

      context "including a card of the same value", ->
        beforeEach ->
          game.attackingCards.push({ value: card.value, suit: Deck.Suits.Clubs })

        itShouldAttackWithTheCard()

      context "but the card value hasn't yet been played", ->
        beforeEach ->
          game.attackingCards.push({ value: card.value+1, suit: Deck.Suits.Hearts})

        it 'should be forbidden', ->
          expect(subject).to.throw()

    context 'if the player is the defender', ->
      beforeEach ->
        player = game.defender

      it 'should be forbidden', ->
        expect(subject).to.throw()
