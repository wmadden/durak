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
      expect(game.deck.deal).to.have.been.calledWith(upTo: 6, to: game.players)

    it 'should be the first round', ->
      subject()
      expect(game.round).to.equal(1)

    it "should be the first player's turn to attack", ->
      subject()
      expect(game.attacker).to.equal(game.players[0])

    it "should be the second player's turn defend", ->
      subject()
      expect(game.defender).to.equal(game.players[1])

    it 'should expose the trump card', ->
      subject()
      expect(game.trumpCard).to.exist

    it 'should pick the trump suit', ->
      subject()
      expect(game.trumps).to.equal(game.trumpCard.suit)

  itShouldBeForbidden = ->
    it 'should be forbidden', ->
      expect(subject).to.throw()

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

        itShouldBeForbidden()

    context 'and there are cards in play', ->
      beforeEach ->
        player = game.attacker

      context 'but the defender has no more cards than are already in play', ->
        beforeEach ->
          game.attackingCards.push({ value: card.value, suit: Deck.Suits.Clubs })
          game.defender.hand = [{ value: card.value, suit: Deck.Suits.Diamonds }]

        itShouldBeForbidden()

      context "including a card of the same value", ->
        beforeEach ->
          game.attackingCards.push({ value: card.value, suit: Deck.Suits.Clubs })

        it 'should attack with the card', ->
          subject()
          expect(game.attackingCards).to.include(card)

        it "should remove the card from the player's hand", ->
          subject()
          expect(player.hand).not.to.include(card)

      context "including a card defended by a card of the same value", ->
        beforeEach ->
          game.attackingCards.push(attackingCard = { value: card.value + 1, suit: Deck.Suits.Clubs })
          attackingCard.defendedBy = { value: card.value, suit: Deck.Suits.Clubs }

        itShouldAttackWithTheCard()

      context "but the card value hasn't yet been played", ->
        beforeEach ->
          game.attackingCards.push({ value: card.value+1, suit: Deck.Suits.Hearts})

        itShouldBeForbidden()

    context 'if the player is the defender', ->
      beforeEach ->
        player = game.defender

  describe 'defend(player, attackingCard, with: defendingCard)', ->
    player = null
    attackingCard = null
    defendingCard = null

    beforeEach ->
      attackingCard = { value: 5, suit: Deck.Suits.Hearts }
      defendingCard = { value: 6, suit: Deck.Suits.Hearts }
      game.start()
      game.trumps = Deck.Suits.Diamonds
      game.attacker.hand.push(attackingCard)
      game.attack(game.attacker, attackingCard)
      game.defender.hand.push(defendingCard)

      subject = -> game.defend(player, attackingCard, with: defendingCard)

    itShouldDefendAgainstTheAttackingCard = ->
      it 'should defend the attacking card', ->
        subject()
        expect(attackingCard.defendedBy).to.equal(defendingCard)

      it "should remove the card from the player's hand", ->
        subject()
        expect(game.defender.hand).to.not.include(defendingCard)

    context 'if the player is not the defender', ->
      beforeEach ->
        player = game.attacker

      itShouldBeForbidden()

    context 'when the player is the defender', ->
      beforeEach ->
        player = game.defender

      context 'but the attacking card is not in play', ->
        beforeEach ->
          game.attackingCards = []

        itShouldBeForbidden()

      context 'and the defending card is a trump', ->
        beforeEach ->
          defendingCard.suit = game.trumps

        context 'and the attacking card is not', ->
          beforeEach ->
            attackingCard.suit = Deck.Suits.Clubs

          itShouldDefendAgainstTheAttackingCard()

        context 'and the attacking card is a higher trump', ->
          beforeEach ->
            attackingCard.suit = game.trumps
            attackingCard.value = 10

          itShouldBeForbidden()

        context 'and the attacking card is a lower trump', ->
          beforeEach ->
            attackingCard.suit = game.trumps
            attackingCard.value = 2

          itShouldDefendAgainstTheAttackingCard()

      context 'and the defending card is not a trump', ->
        context 'and they are different suits', ->
          beforeEach ->
            defendingCard.suit = Deck.Suits.Clubs

          itShouldBeForbidden()

        context 'and they are the same suit', ->
          context 'and the attacking card is lower in value', ->
            beforeEach ->
              attackingCard.value = 4

            itShouldDefendAgainstTheAttackingCard()

          context 'but the attacking card is higher in value', ->
            beforeEach ->
              attackingCard.value = 6

            itShouldBeForbidden()

  itShouldProgressTo = (expectedAttackerIndex, expectedDefenderIndex)->
    it "should progress the attacker to player #{expectedAttackerIndex}", ->
      subject()
      expect(game.attacker).to.equal(game.players[expectedAttackerIndex])

    it "should progress the defender to player #{expectedDefenderIndex}", ->
      subject()
      expect(game.defender).to.equal(game.players[expectedDefenderIndex])

  describe 'acceptDefence', ->
    player = null

    beforeEach ->
      game.start()
      subject = -> game.acceptDefence(player)

    context 'when the player is attacking', ->
      beforeEach ->
        player = game.attacker

      context "but they haven't attacked yet", ->
        itShouldBeForbidden()

      context 'and they have attacked', ->
        beforeEach ->
          game.attacker.hand.push(card = { value: 5, suit: Deck.Suits.Hearts })
          game.attack(game.attacker, card)

        context 'but not all the cards have been defended yet', ->
          itShouldBeForbidden()

        context 'and all cards have been defended', ->
          beforeEach ->
            game.defender.hand.push(card = { value: 6, suit: Deck.Suits.Hearts })
            game.defend(game.defender, game.attackingCards[0], with: card)

          context 'and the deck is not empty', ->
            itShouldProgressTo(1, 2)

            it 'should clear the attacking cards', ->
              subject()
              expect(game.attackingCards).to.be.empty

            it 'should progress to the next round', ->
              nextRound = game.round + 1
              subject()
              expect(game.round).to.equal(nextRound)

            it 'should deal up to six cards to each player', ->
              sinon.stub(game.deck, 'deal')
              subject()
              expect(game.deck.deal).to.have.been.calledWith(upTo: 6, to: game.players)

          context 'and the deck is empty', ->
            beforeEach ->
              game.deck.cards = []

            context 'and the defender has no cards', ->
              beforeEach ->
                game.defender.hand = []

              context 'and there are other players who still have cards', ->
                it 'should make the next player with cards the attacker', ->
                  subject()
                  expect(game.attacker).to.equal(game.players[2])

                it 'should make the following player the defender', ->
                  subject()
                  expect(game.defender).to.equal(game.players[3])

            context 'and only one player has cards', ->
              beforeEach ->
                game.players[1].hand = []
                game.players[2].hand = []
                game.players[3].hand = []

              it 'should be finished', ->
                subject()
                expect(game.isFinished).to.equal(true)

              it 'should make the player the Durak', ->
                subject()
                expect(game.finalResult).to.eql({ durak: game.players[0] })

            context 'and no players have cards', ->
              beforeEach ->
                game.players[0].hand = []
                game.players[1].hand = []
                game.players[2].hand = []
                game.players[3].hand = []

              it 'should be finished', ->
                subject()
                expect(game.isFinished).to.equal(true)

              it 'should be a draw', ->
                subject()
                expect(game.durak).to.be.undefined

    context 'when the player is not attacking', ->
      beforeEach ->
        player = game.defender

      itShouldBeForbidden()

  describe 'concedeDefence', ->
    player = null

    beforeEach ->
      game.start()
      subject = -> game.concedeDefence(player)

    context 'when the player is not defending', ->
      beforeEach ->
        player = game.attacker

      itShouldBeForbidden()

    context 'when the player is defending', ->
      beforeEach ->
        player = game.defender

      context "but they haven't been attacked yet", ->
        itShouldBeForbidden()

      context 'and they have been attacked', ->
        card1 = null
        card2 = null
        card3 = null

        beforeEach ->
          game.attacker.hand.push(card1 = { value: 5, suit: Deck.Suits.Hearts })
          game.attacker.hand.push(card2 = { value: 5, suit: Deck.Suits.Clubs })
          game.defender.hand.push(card3 = { value: 6, suit: Deck.Suits.Hearts })
          game.attack(game.attacker, card1)
          game.attack(game.attacker, card2)
          game.defend(game.defender, card1, with: card3)

        context 'and not all the cards have been defended yet', ->
          itShouldProgressTo(2, 3)

          it "should put the cards in play in the conceding player's hand", ->
            concedingPlayer = game.defender
            subject()
            expect(concedingPlayer.hand).to.include.members([card1, card2, card3])

          it "should reset the defended cards", ->
            subject()
            expect(card1.defendedBy).to.not.exist

          it 'should clear the attacking cards', ->
            subject()
            expect(game.attackingCards).to.be.empty

          it 'should progress to the next round', ->
            nextRound = game.round + 1
            subject()
            expect(game.round).to.equal(nextRound)

          it 'should deal six cards to each player', ->
            sinon.stub(game.deck, 'deal')
            subject()
            expect(game.deck.deal).to.have.been.calledWith(upTo: 6, to: game.players)

          context 'and the deck is empty', ->
            beforeEach ->
              game.deck.cards = []

            context 'and the next player has no cards', ->
              beforeEach ->
                game.players[2].hand = []

              context 'and there are other players who still have cards', ->
                it 'should make the next player with cards the attacker', ->
                  subject()
                  expect(game.attacker).to.equal(game.players[3])

                it 'should make the following player the defender', ->
                  subject()
                  expect(game.defender).to.equal(game.players[0])

            context 'and no other players have cards', ->
              beforeEach ->
                game.players[0].hand = []
                game.players[2].hand = []
                game.players[3].hand = []

              it 'should be finished', ->
                subject()
                expect(game.isFinished).to.equal(true)

              it 'should make the defender the Durak', ->
                subject()
                expect(game.finalResult).to.eql({ durak: game.players[1] })

        context 'but all cards have been defended', ->
          beforeEach ->
            game.defender.hand.push(card = { value: 6, suit: Deck.Suits.Clubs })
            game.defend(game.defender, card2, with: card)

          itShouldBeForbidden()
