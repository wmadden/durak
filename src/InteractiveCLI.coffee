prompt = require 'prompt'
_ = require('underscore')
Promise = require('es6-promise').Promise
Game = require('./Game').Game
AI = require('./AI').AI

class InteractiveCLI
  run: ->
    prompt.message = ''
    prompt.delimiter = ''
    prompt.start()
    @startNewGame()
      .then( => @playGame() )
      .catch( (error) -> console.log("Error: #{error}") )

  startNewGame: ->
    askForNumber('How many players?', between: [2, 6], defaultValue: 2)
      .then(
        (numberOfPlayers) =>
          console.log "Starting #{numberOfPlayers} player game"

          @game = new Game({ numberOfPlayers })
          @humanPlayer = @game.players[0]
          for aiPlayer in _(@game.players).without(@humanPlayer)
            aiPlayer.ai = new AI(@game, aiPlayer)
          @game.start()

          console.log('Dealing cards... Done!')
          @printTrumpCard()

          @currentPlayer = @game.attacker
        , (error) -> console.log("Error: #{error}")
      )

  playGame: ->
    if @game.isFinished
      @printGameResult()
      return

    if @roundHasAdvanced()
      @printRoundInfo()
      @currentPlayer = @game.attacker
      printBlankLine() if @currentPlayer.ai?

    nextPlayer = =>
      currentPlayerIndex = @game.players.indexOf(@currentPlayer)
      nextPlayerIndex = (currentPlayerIndex + 1) % @game.players.length
      @game.players[nextPlayerIndex]

    @performPlayerAction(@currentPlayer).then =>
      @currentPlayer = nextPlayer()
      @playGame()

  roundHasAdvanced: ->
    if not @lastRound? || @game.round > @lastRound
      @lastRound = @game.round
      return true

  performPlayerAction: (player) ->
    if player.ai?
      Promise.resolve(player.ai.perform())
    else
      @performHumanAction()

  performHumanAction: ->
    new Promise (resolve, reject) =>
      printBlankLine()
      @printCardsInPlay()
      @printPlayersHand()

      (if @humanPlayer == @game.attacker
        @offerAttackerMenu()
      else if @humanPlayer == @game.defender
        @offerDefenderMenu()
      else
        @offerWatcherMenu()
      ).then(
        resolve, (error) =>
          console.log "Sorry, that's not allowed.", error.message + "."
          printBlankLine()
          @performHumanAction().then(resolve)
      )

  offerAttackerMenu: ->
    options = []
    attackAction = (card) =>
      =>
        @humanPlayer.attack(card)
    for card in sortedHand(@humanPlayer.hand)
      options.push [
        "Attack with the #{card}", attackAction(card)
      ]

    if @game.attackingCards.length > 0 and @game.allCardsHaveBeenDefended()
      options.push [
        "Accept defence", => @humanPlayer.acceptDefence()
      ]
    offerMenu("What would you like to do?", options)

  offerDefenderMenu: ->
    options = []
    defendAction = (card) =>
      => @offerDefendCardMenu(card)

    undefendedCards = _(@game.attackingCards).filter (card) -> not card.defendedBy?
    for card in undefendedCards
      options.push [
        "Defend the #{card}", defendAction(card)
      ]
    options.push [
      "Concede", => @humanPlayer.concedeDefence()
    ]
    offerMenu("What would you like to do?", options)

  offerDefendCardMenu: (attackingCard) ->
    options = []
    defendAction = (card) =>
      => @humanPlayer.defend(attackingCard, with: card)

    for card in sortedHand(@humanPlayer.hand)
      options.push [
        "the #{card}", defendAction(card)
      ]
    options.push [
      "Concede", => @humanPlayer.concedeDefence()
    ]
    options.push [
      "Back", => @offerDefenderMenu()
    ]

    offerMenu("Defend the #{attackingCard} with...", options)

  printTrumpCard: ->
    console.log "The trump card is", @game.trumpCard

  printRoundInfo: ->
    printBlankLine()
    console.log "Round #{@game.round} (#{@game.deck.cards.length} cards remain)"
    if @game.attacker == @humanPlayer
      console.log 'You are attacking'
    else
      console.log "Player #{@game.attacker.number}'s turn to attack"
      if @game.defender == @humanPlayer
        console.log 'You are defending'
      else
        console.log "You're just watching"
    console.log "Trumps are #{@game.trumps.name}"

  printCardsInPlay: ->
    return unless @game.attackingCards.length > 0
    console.log 'Cards in play:'
    for card in @game.attackingCards
      if card.defendedBy?
        console.log "  #{card} defended by #{card.defendedBy}"
      else
        console.log "  #{card}, undefended"
    printBlankLine()

  printPlayersHand: ->
    console.log "Your hand:"
    for card in sortedHand(@humanPlayer.hand)
      console.log "  #{card}"
    printBlankLine()

  printGameResult: ->
    if @game.finalResult.durak?
      if @game.finalResult.durak == @humanPlayer
        console.log 'You are the durak!'
      else
        console.log "Player #{@game.finalResult.durak.number} is the durak!"
    else
      console.log "It's a draw!"

sortedHand = (hand) -> _(hand).sortBy((card) -> card.comparisonValue())

printBlankLine = -> console.log ''

askForNumber = (description, { between: [minimum, maximum], defaultValue }) ->
  new Promise (resolve, reject) ->
    schema = [{
      description: description
      type: 'number'
      default: defaultValue
      minimum
      maximum
      message: 'Must be a number'
    }]

    prompt.get schema, (err, result) ->
      reject(err) if err
      resolve(result.question)

offerMenu = (description, options) ->
  console.log description
  for [optionDescription], index in options
    console.log "  #{index+1})", optionDescription
  askForNumber('>', between: [1, options.length]).then(
    (menuItem) ->
      optionIndex = menuItem - 1
      [optionDescription, optionCallback] = options[optionIndex]
      printBlankLine()
      optionCallback()
    (error) -> reject(error)
  )

exports.InteractiveCLI = InteractiveCLI
