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
public class CCSound: NSObject {
    
    private enum State {
        case Ready
        case Playing
        case Paused
        case Invalid
    }
    
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    
    ///Whether or not the sound can play.
    public let canPlay:Bool
    private var state = State.Invalid
    
    private let file:AVAudioFile?
    private let buffer:AVAudioPCMBuffer?
    
    ///The file name passed in during initialization.
    public let fileName:String
    
    ///The default volume to play, used on *.play()*.
    public var defaultVolume:CGFloat = 1.0 {
        didSet {
            if self.defaultVolume < 0.0 {
                self.defaultVolume = 0.0
            } else if self.defaultVolume > 1.0 {
                self.defaultVolume = 1.0
            }
        }
    }
    
    ///Whether or not the file loops indefinitely. Default value is *false*.
    public var loops = false
    public internal(set) var isMusic = false
    
    public var isPlaying:Bool { return self.state == .Playing }
    
    public var propertyDictionary:[String:String] {
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
        
        self.engine.attachNode(self.player)
        self.engine.connect(self.player, to: self.engine.mainMixerNode, format: self.engine.mainMixerNode.outputFormatForBus(0))
        
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: nil){
            
            do {
                let url = NSURL(fileURLWithPath: path)
                
                let file = try AVAudioFile(forReading: url/*, error: &loadFileError*/)
                let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                
                try file.readIntoBuffer(buffer/*, error: &readFileError*/)
                
                self.engine.prepare()
                try self.engine.start()
                self.canPlay = true
                
                self.file   = file
                self.buffer = buffer
                self.state  = .Ready
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
    private func tryStart() -> Bool {
        do {
            try self.engine.start()
        } catch {
            self.state = .Invalid
            return false
        }
        
        return true
    }
    
    /**
    Prepares the sound to play depending on the current state.

    :returns - true if the sound is able to play.
    */
    private func prepare() -> Bool {
        if !self.engine.running {
            return self.tryStart()
        }
        
        switch self.state {
        case .Ready:
            return true
        case .Playing:
            return true
        case .Paused:
            return self.tryStart()
        case .Invalid:
            return false
        }
        
    }
    
    private func playSound() -> Bool {
        
        if let buffer = self.buffer where self.canPlay {
        
            if !self.prepare() {
                return false
            }
            
            var options = AVAudioPlayerNodeBufferOptions.Interrupts
            if self.loops {
                options.unionInPlace(.Loops)
            }
            self.player.scheduleBuffer(buffer, atTime: nil, options: options) { [unowned self] in
                self.state = .Ready
            }
            self.player.play()
            self.state = .Playing
            return true
        }
        
        return false
    }
    
    ///Resets all variables to defaults, then plays sound.
    public func play() -> Bool {
        
        self.player.volume = Float(self.defaultVolume)
        
        return self.playSound()
        
    }//play
    
    /**
    Sets volume, then plays sound.
    
    :param: _ The volume of the sound (will be clamped to [0.0, 1.0]).
    :returns: Whether or not the sound will play.
*/
    public func playAtVolume(volume:CGFloat) -> Bool {
        
        self.player.volume = Float(volume)
        
        return self.playSound()
    }
    
    ///Stops playing the sound. Returns true if the sound was previously playing and false otherwise.
    public func stop() -> Bool {
        if self.player.playing {
            self.player.stop()
            return true
        }
        return false
    }
    
    /**
     Pauses the sound.
     
     : returns - true if the sound was succesfully paused, false otherwise.
    */
    public func pause() -> Bool {
        switch self.state {
        case .Playing:
            self.player.pause()
            self.state = .Paused
            return true
        default:
            return false
        }
    }
    
}
