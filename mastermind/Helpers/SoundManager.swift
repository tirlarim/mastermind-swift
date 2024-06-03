import AVFoundation

class SoundManager {
  static let shared = SoundManager()
  
  private var victorySoundPlayer: AVAudioPlayer?
  private var loseSoundPlayer: AVAudioPlayer?
  private var clickSoundPlayer: AVAudioPlayer?
  private var backgroundMusicPlayer: AVAudioPlayer?
  
  private init() {
    setupAudioSession()
    loadSounds()
  }
  
  private func setupAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Failed to set up audio session: \(error)")
    }
  }
  
  private func loadSound(filename: String, fileExtension: String) -> AVAudioPlayer? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
      print("Could not find file: \(filename).\(fileExtension)")
      return nil
    }
    
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.prepareToPlay()
      return player
    } catch {
      print("Error loading sound: \(error)")
      return nil
    }
  }
  
  // TODO: make loadSounds async
  private func loadSounds() {
    if victorySoundPlayer == nil {
      victorySoundPlayer = loadSound(filename: "win_sound", fileExtension: "m4a")
    }
    if loseSoundPlayer == nil {
      loseSoundPlayer = loadSound(filename: "lose_sound", fileExtension: "m4a")
    }
    if clickSoundPlayer == nil {
      clickSoundPlayer = loadSound(filename: "click_classic", fileExtension: "m4a")
    }
    if backgroundMusicPlayer == nil {
      backgroundMusicPlayer = loadSound(filename: "background_sound", fileExtension: "m4a")
      backgroundMusicPlayer?.numberOfLoops = -1
    }
  }
  
  func playVictorySound() {
    victorySoundPlayer?.play()
  }
  
  func setVictorySoundVolume(_ volume: Float) {
    victorySoundPlayer?.volume = volume
  }
  
  func playLoseSound() {
    loseSoundPlayer?.play()
  }
  
  func setLoseSoundVolume(_ volume: Float) {
    loseSoundPlayer?.volume = volume
  }
  
  func playClickSound() {
    clickSoundPlayer?.play()
  }
  
  func setClickMusicVolume(_ volume: Float) {
    backgroundMusicPlayer?.volume = volume
  }
  
  func playBackgroundMusic() {
    backgroundMusicPlayer?.play()
  }
  
  func stopBackgroundMusic() {
    backgroundMusicPlayer?.stop()
  }
  
  func setBackgroundMusicVolume(_ volume: Float) {
    backgroundMusicPlayer?.volume = volume
  }
}
