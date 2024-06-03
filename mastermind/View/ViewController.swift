import UIKit

class ViewController: UIViewController {
  let colors: [UIColor] = [.red, .blue, .green, .yellow, .purple, .orange]
  let pegColorDefault: UIColor = .white
  let indicatorColorDefault: UIColor = .white
  let rows = 8
  let columns = 4
  let gameOutcomeLabelTextDefault: String = "Mastermind v1.0.0"
  
  var shuffledColors: [UIColor] = []
  var selectedColor: UIColor?
  var pegViews: [[UIView]] = []
  var indicatorsViews: [UIView] = []
  var buttons: [UIView] = []
  var secretPegs: [UIView] = []
  var currentRow: Int = 0
  var currentPosition: Int = 0
  var game: LogicEngine!
  var gameOutcomeLabel: UILabel!
  var currentColorIndex: Int = 0
  var isAnimating = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    game = LogicEngine(availableColors: colors)
    game.printSecretColors()
    
    let pegSize: CGFloat = 40.0
    let pegBorderWidth: CGFloat = 1.5
    let spacing: CGFloat = 20.0
    let margin: CGFloat = 60.0
    let boardWidth = CGFloat(columns) * (pegSize + spacing) - spacing + margin
    let boardHeight = CGFloat(rows+1) * (pegSize + spacing) - spacing + margin
    let gameBoard = UIView()
    gameBoard.frame = view.bounds
    gameBoard.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    self.view.addSubview(gameBoard)
    let startX = ((gameBoard.frame.width - boardWidth - spacing) / 2) + margin/2.0
    let startY = ((gameBoard.frame.height - boardHeight) / 2) + margin/2.0
    
    createSecretPegs(startX: startX, startY: startY, with: columns, pegSize: pegSize, spacing: spacing)
    
    for row in 0..<rows {
      var rowPegs: [UIView] = []
      for col in 0..<columns {
        let peg = UIView()
        let xPosition = startX + CGFloat(col) * (pegSize + spacing)
        let yPosition = startY + CGFloat(rows-row) * (pegSize + spacing)
        peg.frame = CGRect(x: xPosition, y: yPosition, width: pegSize, height: pegSize)
        peg.backgroundColor = pegColorDefault
        peg.layer.borderWidth = pegBorderWidth
        peg.layer.borderColor = UIColor.black.cgColor
        peg.layer.cornerRadius = pegSize / 2
        gameBoard.addSubview(peg)
        rowPegs.append(peg)
      }
      pegViews.append(rowPegs)
      createIndicators(startX + CGFloat(columns) * (pegSize + spacing)  + margin/4.0, startY + CGFloat(rows-row) * (pegSize + spacing)  + margin/4.0)
    }
    createColorSelectionButtons()
    createGameOutcomeLabel()
    startAnimation()
  }
  
  func createIndicators(_ posX: CGFloat, _ posY: CGFloat) {
    let spacing: CGFloat = 20.0
    let indicatorSize: CGFloat = 10.0
    let indicatorBorderWidth: CGFloat = 1.5
    let indicatorColor = indicatorColorDefault
    let offsetMain: CGFloat = 0.5
    let offsets: [[CGFloat]] = [[offsetMain, offsetMain],
                                [offsetMain, -offsetMain],
                                [-offsetMain, offsetMain],
                                [-offsetMain, -offsetMain]]
    for i in 0..<4 {
      let peg = UIView()
      let xPosition = posX + offsets[i][0] * spacing
      let yPosition = posY + offsets[i][1] * spacing
      peg.frame = CGRect(x: xPosition, y: yPosition, width: indicatorSize, height: indicatorSize)
      peg.backgroundColor = indicatorColor
      peg.layer.borderWidth = indicatorBorderWidth
      peg.layer.borderColor = UIColor.black.cgColor
      peg.layer.cornerRadius = indicatorSize / 2.0
      indicatorsViews.append(peg)
      self.view.addSubview(peg)
    }
  }
  
  func createColorSelectionButtons() {
    let buttonSize: CGFloat = 40.0
    let spacing: CGFloat = 10.0
    let totalWidth = CGFloat(colors.count) * (buttonSize + spacing) - spacing
    
    for (index, color) in colors.enumerated() {
      let button = UIButton()
      let xPosition = (view.frame.width - totalWidth) / 2 + CGFloat(index) * (buttonSize + spacing)
      let yPosition = view.frame.height - 100.0
      button.frame = CGRect(x: xPosition, y: yPosition, width: buttonSize, height: buttonSize)
      button.backgroundColor = color
      button.layer.cornerRadius = buttonSize / 2
      button.layer.borderWidth = 1.0
      button.layer.borderColor = UIColor.black.cgColor
      button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
      buttons.append(button)
      self.view.addSubview(button)
    }
  }
  
  @objc
  func colorButtonTapped(_ sender: UIButton) {
    guard let color = sender.backgroundColor else { return }
    selectedColor = color
    sender.isHidden = true
    fillNextPegWithSelectedColor()
  }
  
  func createGameOutcomeLabel() {
    gameOutcomeLabel = UILabel()
    gameOutcomeLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 50)
    gameOutcomeLabel.textAlignment = .center
    gameOutcomeLabel.font = UIFont.systemFont(ofSize: 24)
    gameOutcomeLabel.textColor = UIColor.black
    gameOutcomeLabel.text = gameOutcomeLabelTextDefault
    self.view.addSubview(gameOutcomeLabel)
  }
  
  func updateGameOutcomeLabel(with message: String) {
    gameOutcomeLabel.text = message
  }
  
  func fillNextPegWithSelectedColor() {
    guard let selectedColor = selectedColor else { return }
    
    if currentRow < pegViews.count {
      let rowPegs = pegViews[currentRow]
      
      if currentPosition < rowPegs.count {
        rowPegs[currentPosition].backgroundColor = selectedColor
        currentPosition += 1
      }
      
      if currentPosition >= rowPegs.count {
        currentPosition = 0
        if !showUserResult() {
          showAllButtons()
          currentRow += 1
        }
      }
    }
  }
  
  func showAllButtons() {
    for item in buttons {
      item.isHidden = false
    }
  }
  
  func hideAllButtons() {
    for item in buttons {
      item.isHidden = true
    }
  }
  
  func showUserResult() -> Bool {
    var currentColors: [UIColor] = [];
    let fallbackColor: UIColor = .white
    guard !colors.contains(fallbackColor) else {
      print("fallbackColor should not be in colors array. Exit.")
      exit(EXIT_FAILURE)
    }
    currentColors.reserveCapacity(columns)
    for i in 0..<columns {
      currentColors.append(pegViews[currentRow][i].backgroundColor ?? .white)
    }
    let result: [LogicEngine.GuesOption] = game.checkUserGuesses(userColors: currentColors)
    for i in 0..<columns {
      indicatorsViews[currentRow*columns+i].backgroundColor = option2color(option: result[i])
    }
    let isWin = result.allSatisfy {$0 == .correct}
    if (isWin || currentRow+1 == rows) {
      showEndGameState(isUserWin: isWin)
      return true
    }
    return false
  }
  
  func showEndGameState(isUserWin: Bool) {
    hideAllButtons()
    stopAnimation()
    revealSecretColorsWithAnimation()
    let winMsg: String = "Well done! You win in \(currentRow+1) guesses!"
    let loseMsg: String = "You Lose!"
    if isUserWin {
      updateGameOutcomeLabel(with: winMsg)
      print(winMsg)
    } else {
      updateGameOutcomeLabel(with: loseMsg)
      print(loseMsg)
    }
  }
  
  func createSecretPegs(startX: CGFloat, startY: CGFloat, with columns: Int, pegSize: CGFloat, spacing: CGFloat) {
    for col in 0..<columns {
      let peg = UIView()
      let xPosition = startX + CGFloat(col) * (pegSize + spacing)
      peg.frame = CGRect(x: xPosition, y: startY, width: pegSize, height: pegSize)
      peg.backgroundColor = indicatorColorDefault
      peg.layer.borderWidth = 1.0
      peg.layer.borderColor = UIColor.black.cgColor
      peg.layer.cornerRadius = pegSize / 2
      self.view.addSubview(peg)
      secretPegs.append(peg)
    }
    showResetBt(posX: startX + CGFloat(columns) * (pegSize + spacing), posY: startY)
  }
  
  func animateSecretPegs(index: Int = 0) {
    guard isAnimating else { return }
    
    if currentColorIndex >= colors.count || shuffledColors.isEmpty {
      currentColorIndex = 0
      shuffledColors = colors.shuffled()
    }
    
    if index < secretPegs.count {
      UIView.animate(withDuration: 0.5, animations: {
        self.secretPegs[index].backgroundColor = self.shuffledColors[self.currentColorIndex]
      }) { _ in
        self.currentColorIndex += 1
        self.animateSecretPegs(index: index + 1)
      }
    } else {
      animateSecretPegs(index: 0)
    }
  }
  
  @objc
  func startAnimation() {
    if !isAnimating {
      isAnimating = true
      animateSecretPegs()
    }
  }
  
  @objc
  func stopAnimation() {
    isAnimating = false
  }
  
  func revealSecretColorsWithAnimation() {
    let secretColors = game.getSecretColors()
    for (index, peg) in secretPegs.enumerated() {
      UIView.transition(with: peg, duration: 0.5, options: .transitionFlipFromLeft, animations: {
        peg.backgroundColor = secretColors[index]
      }, completion: nil)
    }
  }
  
  func showResetBt(posX: CGFloat, posY: CGFloat) {
    let button = UIButton(type: .system)
    button.frame = CGRect(x: posX, y: posY, width: 38, height: 38)
    let icon = UIImage(systemName: "memories")
    button.setImage(icon, for: .normal)
    button.tintColor = .systemBlue
    button.backgroundColor = .lightGray
    button.layer.cornerRadius = 10
    button.addTarget(self, action: #selector(printClick), for: .touchUpInside)
    self.view.addSubview(button)
  }
  
  @objc
  func printClick() {
    print("Restart Game")
    reset()
  }
  
  func reset() {
    selectedColor = nil
    for currentRow in pegViews {
      for peg in currentRow {
        peg.backgroundColor = pegColorDefault
      }
    }
    for indicatorsView in indicatorsViews {
      indicatorsView.backgroundColor = indicatorColorDefault
    }
    currentRow = 0
    currentPosition = 0
    updateGameOutcomeLabel(with: gameOutcomeLabelTextDefault)
    showAllButtons()
    startAnimation()
    game.updateSecretColors()
    game.printSecretColors()
  }
  
  private func option2color(option: LogicEngine.GuesOption) -> UIColor {
    switch option {
    case .correct:
      return .green
    case .incorrectPosition:
      return .blue
    case .incorrect:
      return .white
    }
  }
}
