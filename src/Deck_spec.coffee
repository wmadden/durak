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

    it 'should have 52 cards', ->
      expect(subject().cards.length).to.equal(52)

    it 'should have 13 cards in each suit', ->
      cards = subject().cards
      cardsInSuit = (suit) ->
        _(cards).filter (card) -> card.suit == suit

      expect(cardsInSuit(Deck.Suits.Hearts)).to.have.length(13)
      expect(cardsInSuit(Deck.Suits.Clubs)).to.have.length(13)
      expect(cardsInSuit(Deck.Suits.Diamonds)).to.have.length(13)
      expect(cardsInSuit(Deck.Suits.Spades)).to.have.length(13)

  describe 'deal(numberOfCards, to: players)', ->
    deck = null
    numberOfCards = null
    player1 = null
    player2 = null
    players = null

    beforeEach ->
      deck = new Deck()
      players = [player1 = { hand: [] }, player2 = { hand: [] }]
      subject = -> deck.deal(numberOfCards, to: players)

    it "should put the given number of cards in the players' hands", ->
      numberOfCards = 2
      player1Cards = [deck.cards[deck.cards.length-1], deck.cards[deck.cards.length-3]]
      player2Cards = [deck.cards[deck.cards.length-2], deck.cards[deck.cards.length-4]]
      subject()
      expect(player1.hand).to.contain.members(player1Cards)
      expect(player2.hand).to.contain.members(player2Cards)
