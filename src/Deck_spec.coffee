sinon = require('sinon')
expect = require('chai').expect
chai = require("chai")
sinonChai = require("sinon-chai")
_ = require("underscore")

chai.use(sinonChai)

Game = require('./Game').Game
Deck = require('./Deck').Deck
subject = null

describe 'Deck', ->

  describe 'a new Deck', ->
    beforeEach ->
      subject = -> new Deck()

    it 'should have 36 cards', ->
      expect(subject().cards.length).to.equal(36)

    it 'should have 8 cards in each suit', ->
      cards = subject().cards
      cardsInSuit = (suit) ->
        _(cards).filter (card) -> card.suit == suit

      expect(cardsInSuit(Deck.Suits.Hearts)).to.have.length(9)
      expect(cardsInSuit(Deck.Suits.Clubs)).to.have.length(9)
      expect(cardsInSuit(Deck.Suits.Diamonds)).to.have.length(9)
      expect(cardsInSuit(Deck.Suits.Spades)).to.have.length(9)

  describe 'deal(upTo: numberOfCards, to: players)', ->
    deck = null
    numberOfCards = null
    player1 = null
    player2 = null
    players = null

    beforeEach ->
      deck = new Deck()
      players = [player1 = { hand: [] }, player2 = { hand: [] }]
      subject = -> deck.deal(upTo: numberOfCards, to: players)

    it "should put the given number of cards in the players' hands", ->
      numberOfCards = 2
      subject()
      expect(player1.hand).to.have.length(numberOfCards)
      expect(player2.hand).to.have.length(numberOfCards)

    context 'when a player already has some cards', ->
      beforeEach ->
        player1.hand.push { value: 4, suit: Deck.Suits.Hearts }

      it 'should deal up to the given number of cards', ->
        numberOfCards = 2
        subject()
        expect(player1.hand).to.have.length(numberOfCards)
        expect(player2.hand).to.have.length(numberOfCards)

    context 'when a player already has enough cards', ->
      beforeEach ->
        player1.hand.push { value: 4, suit: Deck.Suits.Hearts }
        player1.hand.push { value: 5, suit: Deck.Suits.Hearts }

      it 'should do nothing', ->
        numberOfCards = 2
        subject()
        expect(player1.hand).to.have.length(numberOfCards)
        expect(player2.hand).to.have.length(numberOfCards)

    context "when it doesn't have enough cards", ->
      beforeEach ->
        deck.cards = deck.cards[0..0]

      it 'should deal as many cards as there are to the players in order', ->
        numberOfCards = 2
        subject()
        expect(player1.hand).to.have.length(1)
        expect(player2.hand).to.have.length(0)

    context "when it is empty", ->
      beforeEach ->
        deck.cards = []

      it 'should do nothing', ->
        numberOfCards = 2
        subject()
        expect(player1.hand).to.have.length(0)
        expect(player2.hand).to.have.length(0)
