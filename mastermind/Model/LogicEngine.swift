import UIKit

class LogicEngine {
  enum GuesOption {
    case correct
    case incorrect
    case incorrectPosition
  }
  
  private let minColorsCount = 4
  private var secretColors: [UIColor] = []
  private var availableColors: [UIColor]
  
  init(availableColors: [UIColor]) {
    self.availableColors = availableColors
    updateSecretColors()
  }
  
  func updateSecretColors() {
    guard availableColors.count >= minColorsCount else {
      print("Not enough colors to choose from.")
      return
    }
    
    secretColors = []
    var usedIndices: Set<Int> = []
    while secretColors.count < minColorsCount {
      let randomIndex = Int(arc4random_uniform(UInt32(availableColors.count)))
      if !usedIndices.contains(randomIndex) {
        secretColors.append(availableColors[randomIndex])
        usedIndices.insert(randomIndex)
      }
    }
  }
  
  func checkUserGuesses(userColors: [UIColor]) -> [GuesOption] {
    let len = min(secretColors.count, userColors.count)
    var correctGuesses = 0
    var incorrectPosition = 0
    var result: [GuesOption] = Array(repeating: .incorrect, count: len)
    for i in 0..<len {
      if (secretColors.contains(userColors[i])) {
        if (userColors[i] == secretColors[i]) {
          result[i] = .correct
          correctGuesses += 1
        } else {
          result[i] = .incorrectPosition
          incorrectPosition += 1
        }
      } else {
        result[i] = .incorrect
      }
    }
    print("You guessed \(correctGuesses) out of \(len) colors correctly.")
    print("You guessed \(incorrectPosition) out of \(len) colors at correct position.")
    return result
  }
  
  func printSecretColors() {
    for (index, color) in secretColors.enumerated() {
      print("Secret Color \(index + 1): \(color)")
    }
  }
}
