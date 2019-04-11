//
//  ViewController.swift
//  AudioCtrl
//
//  Created by Tomás Vega on 4/10/19.
//  Copyright © 2019 Tomás Vega. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, MPMediaPickerControllerDelegate {
    var audioPlayer = AVAudioPlayer()
    var timer:Timer!
    var mp = MPMusicPlayerController.systemMusicPlayer
    var trackTimer: Timer!
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var trackTime: UILabel!
    @IBOutlet weak var pickButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    
    @IBAction func pickSong(_ sender: UIButton) {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = false
        myMediaPickerVC.popoverPresentationController?.sourceView = sender
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mp.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true, completion: nil)
        mp.play()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)

        let audio = mediaItemCollection.items[0]
        
        if let title = audio.title {
            trackTitle.text = title
        }
        if let artist = audio.artist {
            trackArtist.text = artist
        }
        
        trackTime.value(forKey: "00:00")

    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func startTimer(time: Double) {
        timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @IBAction func playOrPauseMusic(_ sender: Any) {
        let state = mp.playbackState
        print(state)
        if state == MPMusicPlaybackState.playing  {
            mp.pause()
            stopTimer()
        } else {
            mp.play()
            startTimer(time: 1.0)
        }
    }
    
    @IBAction func rewind(_ sender: UIButton) {
        mp.beginSeekingBackward()
        stopTimer()
        startTimer(time: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.mp.endSeeking()
            self.stopTimer()
            self.startTimer(time: 1.0)
        }
    }
    
    @IBAction func fastforward(_ sender: UIButton) {
        mp.beginSeekingForward()
        stopTimer()
        startTimer(time: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.mp.endSeeking()
            self.stopTimer()
            self.startTimer(time: 1.0)
        }
    }
    
    let volumeSliderValues: [Float] = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    var volumeValue: Float = 1.0
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        let index = round(sender.value)
        volumeSlider.setValue(Float(index), animated: false)
        volumeValue = volumeSliderValues[Int(index)]
        updateVolume()
    }
    
    func setupVolumeSlider() {
        let numSteps = volumeSliderValues.count-1
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = Float(numSteps)
        volumeSlider.isContinuous = true
        let val = volumeSliderValues[numSteps/2]
        volumeSlider.setValue(5.0, animated: false)
        volumeValue = val
        updateVolume()
    }
    
    func updateVolume() {
//        volumeLabel.text = "\(volumeValue)"
        MPVolumeView.setVolume(volumeValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVolumeSlider()
    }
    
    @objc func updateTime() {
        let currentTime = Int(mp.currentPlaybackTime)
        let minutes = currentTime/60
        let seconds = currentTime - minutes * 60
        trackTime.text = String(format: "%02d:%02d", minutes,seconds) as String
    }
    
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        // Need to use the MPVolumeView in order to change volume, but don't care about UI set so frame to .zero
        let volumeView = MPVolumeView(frame: .zero)
        // Search for the slider
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        // Update the slider value with the desired volume.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
        // Optional - Remove the HUD
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            volumeView.alpha = 0.000001
            window.addSubview(volumeView)
        }
    }
}


