//
//  CCSoundPlayer.swift
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

public class CCSoundPlayer: NSObject {
   
    // MARK: - Properties
    
    private var sounds:[String:CCSound] = [:]
    private var allKeys:[String] = []
    ///The valid keys for all the sounds.
    public var keys:[String] { return self.allKeys }
    
    ///Stores files from .loadFiles so they can be reloaded later if neccessary
    private var files:[String:String] = [:]
    private var isDestroyed = false
    
    /**
    If *false*, then
    
        .playSound(_, atVolume:)
    
    doesn't play sounds and always returns *false*.
    */
    public var enabled = true
    ///If *false*, then sounds don't play.
    public var soundsEnabled    = true
    ///If *false*, then music (CCSound objects that are designated at creation as music).
    public var musicEnabled     = true
    
    /**
    Default property dictionaries for files with a given extension.
    When loading a file with an extension corresponding to a key in
    this dictionary, then the sound file's propertyDictionary is set
    to the corresponding dictionary in defaultProperties.
    */
    public var defaultProperties:[String:[String:String]] = [:]
    
    // MARK: - Setup
    
    ///Initialize a *CCSoundPlayer* object
    public override init() {
        
    }//initialize
    
    public func loadData(data:[[String:String]], musicExtensions:[String]) {
        
        func isMusic(file:String) -> Bool {
            for musicExtension in musicExtensions {
                if file.hasSuffix(musicExtension) {
                    return true
                }
            }
            return false
        }
        
        var files:[String:String] = [:]
        for dict in data {
            guard let key = dict["Key"], file = dict["File"] else {
                continue
            }
            files[key] = file
            
            let sound = CCSound(file: file)
            
            if isMusic(file) {
                sound.loops = true
                sound.isMusic = true
            }
            
            if let loopStr = dict["Loops"] {
                sound.loops = loopStr.getBoolValue()
            }
            if let volumeStr = dict["Volume"] {
                sound.defaultVolume = volumeStr.getCGFloatValue()
            }
            
            self.sounds[key] = sound
        }
        
        self.files = files
    }
    
    /**
    Loads files with dictionary.
    
    :param: _ Dictionary of files to load. The keys are what you
    want the files to be called, the objects are what the paths
    of the files are.
    */
    public func loadFiles(files:[String:String]) {
        
        self.files = files
        
        for (key, file) in files {
            self.allKeys.append(key)
            
            let curSound = CCSound(file: file)
            if let d = self.propertyDictForFile(file) {
                curSound.propertyDictionary = d
            }
            
            self.sounds[key] = curSound
        }
        
    }//load files
    
    private func propertyDictForFile(file:String) -> [String:String]? {
        for (key, dict) in self.defaultProperties {
            if file.hasSuffix(key) {
                return dict
            }
        }
        return nil
    }
    
    /**
    Loads files with dictionary on desired dispatch queue.

    :param: _ Dictionary of files to load. The keys are what you
    want the files to be called, the objects are what the paths
    of the files are.
    :param: onQueue What dispatch queue to load on.
    */
    public func loadFiles(files:[String:String], onQueue:dispatch_queue_t) {
        
        dispatch_async(onQueue) { [unowned self] in
            self.loadFiles(files)
        }
        
    }//load files on background queue
    
    // MARK: - Logic
    
    ///Returns sound for key (if it exists).
    public subscript(key:String) -> CCSound? {
        return self.sounds[key]
    }
    
    /**
    Plays sound that corresponds to *key*.

    :param: _ The key of the sound to play.
    :returns: true if the sound will play, false otherwise.
    */
    public func playSound(key:String) -> Bool {
        
        if !self.enabled {
            return false
        }
        
        if let sound = self[key] {
            
            if sound.isMusic && !self.musicEnabled {
                return false
            } else if !sound.isMusic && !self.soundsEnabled {
                return false
            }
            
            sound.play()
            return true
        } else {
            return false
        }
    }
    
    /**
    Plays sound that corresponds to *key* at *volume*.

    :param: _ The key of the sound to play.
    :param: atVolume The volume to play the sound at.
    :returns: true if the sound will play, false otherwise.
    */
    public func playSound(key:String, atVolume volume:CGFloat) -> Bool {
      
        if !self.enabled {
            return false
        }
        
        if let sound = self.sounds[key] {
            return sound.playAtVolume(volume)
        } else {
            return false
        }
    }
    
    
    ///Purges sounds from memory. Use .restoreSounds() to reload them.
    public func destroySounds() {
        if (self.isDestroyed) {
            return
        }
        
        autoreleasepool() { [unowned self] in
            self.sounds.removeAll(keepCapacity: false)
        }
        
        self.isDestroyed = true
    }
    
    ///Only reloads sounds if necessary.
    public func restoreSounds() {
        if (self.isDestroyed) {
            self.loadFiles(self.files)
            self.isDestroyed = false
        }
    }
    
    /**
     Stops playing a specific sound. Returns true if the sound was stopped
     and false if the sound was nil or if the sound was not stopped.
     */
    public func stopSound(key:String) -> Bool {
        return self.sounds[key]?.stop() ?? false
    }
    
    ///Stops playing all sounds.
    public func stopAllSounds() {
        for (_, sound) in self.sounds {
            sound.stop()
        }
        
    }
    
}

extension CCSoundPlayer {
    
    // MARK: - Singleton
    
    public class var sharedInstance:CCSoundPlayer {
        struct StaticInstance {
            static var instance:CCSoundPlayer! = nil
            static var onceToken:dispatch_once_t = 0
        }
        
        dispatch_once(&StaticInstance.onceToken) {
            StaticInstance.instance = CCSoundPlayer()
        }
        
        return StaticInstance.instance
    }
    
    /**
    Gets sound for corresponding key.

    :param: _ Key for desired sound.
    :returns: The sound corresponding to the given key.
    If the sound doesn't exist, return nil.
    */
    public class func soundForKey(key:String) -> CCSound? {
        return CCSoundPlayer.sharedInstance[key]
    }
    
    /**
    Plays sound that corresponds to *key*.
    
    :param: _ The key of the sound to play.
    :returns: true if the sound will play, false otherwise.
    */
    public class func playSound(key:String) -> Bool {
        return CCSoundPlayer.sharedInstance.playSound(key)
    }
    
    /**
    Plays sound that corresponds to *key* at *volume*.
    
    :param: _ The key of the sound to play.
    :param: atVolume The volume to play the sound at.
    :returns: true if the sound will play, false otherwise.
    */
    public class func playSound(key:String, atVolume volume:CGFloat) -> Bool {
        return CCSoundPlayer.sharedInstance.playSound(key, atVolume: volume)
    }
    
    /**
    Stops playing a specific sound. Returns true if the sound was stopped
    and false if the sound was nil or if the sound was not stopped.
    */
    public class func stopSound(key:String) -> Bool {
        return CCSoundPlayer.sharedInstance.sounds[key]?.stop() ?? false
    }
    
    ///Stops playing all sounds.
    public class func stopAllSounds() {
        CCSoundPlayer.sharedInstance.stopAllSounds()
    }
    
    /**
     Sets the default property dictionary for a given extension.
     
     - parameter dict: The default property dictionary.
     - paramter forExtension: The extension of a sound file that should use the given dictionary.
    */
    public class func set(forExtension:String, forPropertyDictionary dict:[String:String]) {
        CCSoundPlayer.sharedInstance.defaultProperties[forExtension] = dict
    }
    
}

extension CCSoundPlayer: SequenceType {
    
    public typealias Generator = Array<CCSound>.Generator
    
    public func generate() -> Generator {
        return self.sounds.map() { $0.1 } .generate()
    }
    
}