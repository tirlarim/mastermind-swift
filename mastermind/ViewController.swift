import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Define the number of rows and columns for the game board
    let rows = 10
    let columns = 4
    
    // Define the size of each peg
    let pegSize: CGFloat = 30.0
    let spacing: CGFloat = 10.0
    
    // Calculate the total width and height of the game board
    let boardWidth = CGFloat(columns) * (pegSize + spacing) - spacing
    let boardHeight = CGFloat(rows) * (pegSize + spacing) - spacing
    
    // Create a UIView to represent the game board
    let gameBoard = UIView()
    gameBoard.frame = CGRect(x: (view.frame.width - boardWidth) / 2, y: 100, width: boardWidth, height: boardHeight)
    gameBoard.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    
    // Add the game board to the main view
    self.view.addSubview(gameBoard)
    
    // Create and add pegs to the game board
    for row in 0..<rows {
      for col in 0..<columns {
        let peg = UIView()
        let xPosition = CGFloat(col) * (pegSize + spacing)
        let yPosition = CGFloat(row) * (pegSize + spacing)
        peg.frame = CGRect(x: xPosition, y: yPosition, width: pegSize, height: pegSize)
        peg.backgroundColor = UIColor.white
        peg.layer.borderWidth = 1.0
        peg.layer.borderColor = UIColor.black.cgColor
        peg.layer.cornerRadius = pegSize / 2
        gameBoard.addSubview(peg)
      }
    }
  }
}
