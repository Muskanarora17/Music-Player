//
//  SongViewController.swift
//  Music Player
//
//  Created by Muskan on 23/10/20.
//

import UIKit
import AVKit
import MediaPlayer

class SongViewController: UIViewController {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var pipButton: UIButton!
    
    var songs: [Song] = []
    var position: Int = 0
    
    
    var player: AVAudioPlayer?
    
    var progress = Progress()
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        setupRemoteTransportControls()
        setupNowPlaying()
        
        
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            print("Play command - is playing: \(self.player!.isPlaying)")
            if !self.player!.isPlaying {
                player?.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            print("Pause command - is playing: \(self.player!.isPlaying)")
            if self.player!.isPlaying {
                player?.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            print("Next track command - is playing: \(self.player!.isPlaying)")

                nextSong(self)
            setupNowPlaying()

            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            print("Previous track command - is playing: \(self.player!.isPlaying)")

            previousSong(self)
             
            setupNowPlaying()

            return .success
        }
    }
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            if swipeGesture.direction == .right {
                print("Swiped right")
                previousSong(swipeGesture)
            }
            
            else if swipeGesture.direction == .left {
                print("Swiped left")
                nextSong(swipeGesture)
            }
            
        }
    }
    
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songs[position].trackName.capitalized

        if let image = UIImage(named: songs[position].trackName) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        tabBarController?.tabBar.isHidden = true
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.alpha = 0.5
        
        playSound()
        
        let minutes = Int(player!.duration/60)
        let seconds = Int((player?.duration.truncatingRemainder(dividingBy: 60))!)
        
        if seconds < 10 {
            self.endTime.text = String("\(minutes):0\(seconds)")
        }
        else {
            self.endTime.text = String("\(minutes):\(seconds)")
        }
        
        
        progress = Progress(totalUnitCount: Int64(player?.duration ?? 0))
        
        progressView.progress = 0.0
        progress.completedUnitCount = 0
        
        // 2
        
        setTimer()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        player?.stop()
        
        tabBarController?.tabBar.isHidden = false
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    
    
    func playSound() {
        
        songImage.layer.borderWidth = 10
        songImage.layer.borderColor = UIColor.black.withAlphaComponent(0.9).cgColor
        
        bgImage.image = UIImage(named: songs[position].imageName)
        songImage.image = UIImage(named: songs[position].imageName)
        songNameLabel.text = songs[position].trackName.capitalized
        
        guard let url = Bundle.main.url(forResource: songs[position].trackName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
            
            
        }
        
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setTimer() {
        
        if !progress.isPaused {
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                guard self.progress.isFinished == false else {
                    timer.invalidate()
                    return
                }
                
                let minutes = Int(self.player!.currentTime/60)
                let seconds = Int((self.player?.currentTime.truncatingRemainder(dividingBy: 60))!)
                
                if seconds < 10 {
                    self.startTime.text = String("\(minutes):0\(seconds)")
                }
                else {
                    self.startTime.text = String("\(minutes):\(seconds)")
                }
                self.progress.completedUnitCount += 1
                self.progressView.setProgress(Float(self.progress.fractionCompleted), animated: true)
                
                
                
            }
            //progress.resume()
        }
        else {
            
            timer.invalidate()
        }
    }
    
    @IBAction func playPresses(_ sender: Any) {
        
        if (player!.isPlaying) {
            
            
            if #available(iOS 13.0, *) {
                playButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            
            progress.pause()
            setTimer()
            
            player?.pause()
            
            
            
        }
        else {
            
            if #available(iOS 13.0, *) {
                playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            player?.play()
            
            
            progress.resume()
            
            if progress.isPaused {
                print("true")
            }
            setTimer()
            //progress.resume()
        }
        
        
    }
    
    @IBAction func forwardPressed(_ sender: Any) {
        
        //player?.pause()
        //progress.pause()
        guard let currentTime = player?.currentTime else { return }
        
        //player?.stop()
        
        
        
        DispatchQueue.main.async {
            //            self.playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            //            self.progress.resume()
            //            self.setTimer()
            if self.player!.duration > currentTime + 30 {
                self.player?.currentTime = TimeInterval(currentTime + 30)
                self.progress.completedUnitCount += 30
            }
            
        }
        
        //setTimer()
        
        player?.play()
        
    }
    
    @IBAction func rewindPressed(_ sender: Any) {
        guard let currentTime = player?.currentTime else { return }
        
        
        
        DispatchQueue.main.async {
            //            self.playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            //            self.progress.resume()
            //            self.setTimer()
            if currentTime - 30 > 0 {
                self.player?.currentTime = TimeInterval(currentTime - 30)
                self.progress.completedUnitCount -= 30
            }
            
        }
        
    }
    
    @IBAction func nextSong(_ sender: Any) {
        if position < (songs.count - 1) {
            position = position + 1
            player?.stop()
            progressView.progress = 0.0
            progress.completedUnitCount = 0
            playSound()
            //            playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            //            self.progress.resume()
            //            self.setTimer()
        }
        
        else {
            
            position = 0
            
            progressView.progress = 0.0
            progress.completedUnitCount = 0
            playSound()
            //            playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            //            self.progress.resume()
            //            self.setTimer()
            
        }
        
        
    }
    
    @IBAction func previousSong(_ sender: Any) {
        
        if position > 0 {
            position = position - 1
            player?.stop()
            
            progressView.progress = 0.0
            progress.completedUnitCount = 0
            playSound()
            //        playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            //        self.progress.resume()
            //        self.setTimer()
        }
        else {
            
            position = songs.count - 1
            
            progressView.progress = 0.0
            progress.completedUnitCount = 0
            playSound()
            //        playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            //        self.progress.resume()
            //        self.setTimer()
            
            
        }
        
    }
    
}

