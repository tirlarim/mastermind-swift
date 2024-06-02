import UIKit

class ViewController: UIViewController {
  let colors: [UIColor] = [.red, .blue, .green, .yellow, .purple, .orange]
  var selectedColor: UIColor?
  var pegViews: [[UIView]] = []
  var indicatorsViews: [UIView] = []
  var currentRow: Int = 0
  var currentPosition: Int = 0
  let rows = 9
  let columns = 4
  var game: LogicEngine!
  var gameOutcomeLabel: UILabel!
  
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
    
    let startX = (gameBoard.frame.width - boardWidth - spacing) / 2
    let startY = (gameBoard.frame.height - boardHeight) / 2
    
    for row in 0..<rows {
      var rowPegs: [UIView] = []
      for col in 0..<columns {
        let peg = UIView()
        let xPosition = startX + CGFloat(col) * (pegSize + spacing) + margin/2.0
        let yPosition = startY + CGFloat(rows-row) * (pegSize + spacing) + margin/2.0
        peg.frame = CGRect(x: xPosition, y: yPosition, width: pegSize, height: pegSize)
        peg.backgroundColor = UIColor.white
        peg.layer.borderWidth = pegBorderWidth
        peg.layer.borderColor = UIColor.black.cgColor
        peg.layer.cornerRadius = pegSize / 2
        gameBoard.addSubview(peg)
        rowPegs.append(peg)
      }
      pegViews.append(rowPegs)
      createIndicators(startX + CGFloat(columns) * (pegSize + spacing) + margin/2.0, startY + CGFloat(rows-row) * (pegSize + spacing) + margin/2.0)
    }
    createColorSelectionButtons()
    createGameOutcomeLabel()
  }
  
  func createIndicators(_ posX: CGFloat, _ posY: CGFloat) {
    let spacing: CGFloat = 20.0
    let indicatorSize: CGFloat = 10.0
    let indicatorBorderWidth: CGFloat = 1.5
    let indicatorColor = UIColor.red
    let indicatorsMargin = CGVector(dx: 0.0, dy: indicatorSize/4.0)
    
    for indicatorsRow in 0..<2 {
      for indicatorsCol in 0..<2 {
        let peg = UIView()
        let xPosition = posX + CGFloat(indicatorsRow) * spacing + indicatorsMargin.dx
        let yPosition = posY + CGFloat(indicatorsCol) * spacing + indicatorsMargin.dy
        peg.frame = CGRect(x: xPosition, y: yPosition, width: indicatorSize, height: indicatorSize)
        peg.backgroundColor = indicatorColor
        peg.layer.borderWidth = indicatorBorderWidth
        peg.layer.borderColor = UIColor.black.cgColor
        peg.layer.cornerRadius = indicatorSize / 2.0
        indicatorsViews.append(peg)
        self.view.addSubview(peg)
      }
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
      self.view.addSubview(button)
    }
  }
  
  func createGameOutcomeLabel() {
    gameOutcomeLabel = UILabel()
    gameOutcomeLabel.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 50)
    gameOutcomeLabel.textAlignment = .center
    gameOutcomeLabel.font = UIFont.systemFont(ofSize: 24)
    gameOutcomeLabel.textColor = UIColor.black
    gameOutcomeLabel.text = "Mastermind v1.0.0"
    self.view.addSubview(gameOutcomeLabel)
  }
  
  func updateGameOutcomeLabel(with message: String) {
    gameOutcomeLabel.text = message
  }
  
  @objc
  func colorButtonTapped(_ sender: UIButton) {
    guard let color = sender.backgroundColor else { return }
    selectedColor = color
    fillNextPegWithSelectedColor()
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
        showUserResult()
        currentRow += 1
      }
    }
  }
  
  func showUserResult() {
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
      switch result[i] {
      case .correct:
        indicatorsViews[currentRow*columns+i].backgroundColor = .green
        break
      case .incorrectPosition:
        indicatorsViews[currentRow*columns+i].backgroundColor = .blue
        break
      case .incorrect:
        indicatorsViews[currentRow*columns+i].backgroundColor = .white
      }
    }
    let isWin = result.allSatisfy {$0 == .correct}
    if (isWin) {
      updateGameOutcomeLabel(with: "You win!")
    } else if (currentRow == rows-1) {
      updateGameOutcomeLabel(with: "You lose!")
    }
  }
}
