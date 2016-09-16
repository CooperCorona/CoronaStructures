//
//  CCSound.swift
//  Gravity
//
//  Created by Cooper Knaak on 5/12/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import AVFoundation

/**
Uses Core Audio to load and play a given sound file.
Desired format is .caf

To use the terminal to convert sounds to .caf, use *afconvert* like so:

  afconvert INPUT_FILE -f caf -d LEI16@44100
  -c 2 -o OUTPUT_FILE
*/
open class CCSound: NSObject {
    
    fileprivate enum State {
        case ready
        case playing
        case paused
        case invalid
    }
    
    fileprivate let engine = AVAudioEngine()
    fileprivate let player = AVAudioPlayerNode()
    
    ///Whether or not the sound can play.
    open let canPlay:Bool
    fileprivate var state = State.invalid
    
    fileprivate let file:AVAudioFile?
    fileprivate let buffer:AVAudioPCMBuffer?
    
    ///The file name passed in during initialization.
    open let fileName:String
    
    ///The default volume to play, used on *.play()*.
    open var defaultVolume:CGFloat = 1.0 {
        didSet {
            if self.defaultVolume < 0.0 {
                self.defaultVolume = 0.0
            } else if self.defaultVolume > 1.0 {
                self.defaultVolume = 1.0
            }
        }
    }
    
    ///Whether or not the file loops indefinitely. Default value is *false*.
    open var loops = false
    open internal(set) var isMusic = false
    
    open var isPlaying:Bool { return self.state == .playing }
    
    open var propertyDictionary:[String:String] {
        get {
            return [
                "defaultVolume":"\(self.defaultVolume)",
                "loops":"\(self.loops)"
            ]
        }
        set {
            for (key, value) in newValue {
                switch key {
                case "defaultVolume":
                    self.defaultVolume = value.getCGFloatValue()
                case "loops":
                    self.loops = value.getBoolValue()
                default:
                    break
                }
            }
        }
    }
    
    /**
    Initialize a *CCSound* object by loading *file* in the main bundle.
    :param: _ The file (including extension) in the main bundle to load.
    :return: A *CCSound* object.
     */
    public init(file:String) {
        
        self.fileName = file
        
        self.engine.attach(self.player)
        self.engine.connect(self.player, to: self.engine.mainMixerNode, format: self.engine.mainMixerNode.outputFormat(forBus: 0))
        
        if let path = Bundle.main.path(forResource: fileName, ofType: nil){
            
            do {
                let url = URL(fileURLWithPath: path)
                
                let file = try AVAudioFile(forReading: url/*, error: &loadFileError*/)
                let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                
                try file.read(into: buffer/*, error: &readFileError*/)
                
                self.engine.prepare()
                try self.engine.start()
                self.canPlay = true
                
                self.file   = file
                self.buffer = buffer
                self.state  = .ready
            } catch {
                self.file = nil
                self.buffer = nil
                self.canPlay = false
            }
        } else {
            self.file = nil
            self.buffer = nil
            self.canPlay = false
        }
        
    }//initialize
    
    ///Invokes start on engine, returning true if successful and false if not, setting state accordingly.
    fileprivate func tryStart() -> Bool {
        do {
            try self.engine.start()
        } catch {
            self.state = .invalid
            return false
        }
        
        return true
    }
    
    /**
    Prepares the sound to play depending on the current state.

    :returns - true if the sound is able to play.
    */
    fileprivate func prepare() -> Bool {
        if !self.engine.isRunning {
            return self.tryStart()
        }
        
        switch self.state {
        case .ready:
            return true
        case .playing:
            return true
        case .paused:
            return self.tryStart()
        case .invalid:
            return false
        }
        
    }
    
    fileprivate func playSound() -> Bool {
        
        if let buffer = self.buffer , self.canPlay {
        
            if !self.prepare() {
                return false
            }
            
            var options = AVAudioPlayerNodeBufferOptions.interrupts
            if self.loops {
                options.formUnion(.loops)
            }
            self.player.scheduleBuffer(buffer, at: nil, options: options) { [unowned self] in
                self.state = .ready
            }
            self.player.play()
            self.state = .playing
            return true
        }
        
        return false
    }
    
    ///Resets all variables to defaults, then plays sound.
    open func play() -> Bool {
        
        self.player.volume = Float(self.defaultVolume)
        
        return self.playSound()
        
    }//play
    
    /**
    Sets volume, then plays sound.
    
    :param: _ The volume of the sound (will be clamped to [0.0, 1.0]).
    :returns: Whether or not the sound will play.
*/
    open func playAtVolume(_ volume:CGFloat) -> Bool {
        
        self.player.volume = Float(volume)
        
        return self.playSound()
    }
    
    ///Stops playing the sound. Returns true if the sound was previously playing and false otherwise.
    open func stop() -> Bool {
        if self.player.isPlaying {
            self.player.stop()
            return true
        }
        return false
    }
    
    /**
     Pauses the sound.
     
     : returns - true if the sound was succesfully paused, false otherwise.
    */
    open func pause() -> Bool {
        switch self.state {
        case .playing:
            self.player.pause()
            self.state = .paused
            return true
        default:
            return false
        }
    }
    
}
