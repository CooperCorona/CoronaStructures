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

open class CCSoundPlayer: NSObject {
   
    // MARK: - Properties
    
    fileprivate var sounds:[String:CCSound] = [:]
    fileprivate var allKeys:[String] = []
    ///The valid keys for all the sounds.
    open var keys:[String] { return self.allKeys }
    
    ///Stores files from .loadFiles so they can be reloaded later if neccessary
    fileprivate var files:[String:String] = [:]
    fileprivate var isDestroyed = false
    
    /**
    If *false*, then
    
        .playSound(_, atVolume:)
    
    doesn't play sounds and always returns *false*.
    */
    open var enabled = true
    ///If *false*, then sounds don't play.
    open var soundsEnabled    = true
    ///If *false*, then music (CCSound objects that are designated at creation as music).
    open var musicEnabled     = true
    
    /**
    Default property dictionaries for files with a given extension.
    When loading a file with an extension corresponding to a key in
    this dictionary, then the sound file's propertyDictionary is set
    to the corresponding dictionary in defaultProperties.
    */
    open var defaultProperties:[String:[String:String]] = [:]
    
    // MARK: - Singleton
    
    public static let sharedInstance:CCSoundPlayer = CCSoundPlayer()
    
    // MARK: - Setup
    
    ///Initialize a *CCSoundPlayer* object
    public override init() {
        
    }//initialize
    
    open func loadData(_ data:[[String:String]], musicExtensions:[String]) {
        
        func isMusic(_ file:String) -> Bool {
            for musicExtension in musicExtensions {
                if file.hasSuffix(musicExtension) {
                    return true
                }
            }
            return false
        }
        
        var files:[String:String] = [:]
        for dict in data {
            guard let key = dict["Key"], let file = dict["File"] else {
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
    open func loadFiles(_ files:[String:String]) {
        
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
    
    fileprivate func propertyDictForFile(_ file:String) -> [String:String]? {
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
    open func loadFiles(_ files:[String:String], onQueue:DispatchQueue) {
        
        onQueue.async { [unowned self] in
            self.loadFiles(files)
        }
        
    }//load files on background queue
    
    // MARK: - Logic
    
    ///Returns sound for key (if it exists).
    open subscript(key:String) -> CCSound? {
        return self.sounds[key]
    }
    
    /**
    Plays sound that corresponds to *key*.

    :param: _ The key of the sound to play.
    :returns: true if the sound will play, false otherwise.
    */
    open func playSound(_ key:String) -> Bool {
        
        if !self.enabled {
            return false
        }
        
        if let sound = self[key] {
            
            if sound.isMusic && !self.musicEnabled {
                return false
            } else if !sound.isMusic && !self.soundsEnabled {
                return false
            }
            
            let _ = sound.play()
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
    open func playSound(_ key:String, atVolume volume:CGFloat) -> Bool {
      
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
    open func destroySounds() {
        if (self.isDestroyed) {
            return
        }
        
        autoreleasepool() { [unowned self] in
            self.sounds.removeAll(keepingCapacity: false)
        }
        
        self.isDestroyed = true
    }
    
    ///Only reloads sounds if necessary.
    open func restoreSounds() {
        if (self.isDestroyed) {
            self.loadFiles(self.files)
            self.isDestroyed = false
        }
    }
    
    /**
     Stops playing a specific sound. Returns true if the sound was stopped
     and false if the sound was nil or if the sound was not stopped.
     */
    open func stopSound(_ key:String) -> Bool {
        return self.sounds[key]?.stop() ?? false
    }
    
    ///Stops playing all sounds.
    open func stopAllSounds() {
        for (_, sound) in self.sounds {
            let _ = sound.stop()
        }
        
    }
    
}

extension CCSoundPlayer {
    
    /**
    Gets sound for corresponding key.

    :param: _ Key for desired sound.
    :returns: The sound corresponding to the given key.
    If the sound doesn't exist, return nil.
    */
    public class func soundForKey(_ key:String) -> CCSound? {
        return CCSoundPlayer.sharedInstance[key]
    }
    
    /**
    Plays sound that corresponds to *key*.
    
    :param: _ The key of the sound to play.
    :returns: true if the sound will play, false otherwise.
    */
    public class func playSound(_ key:String) -> Bool {
        return CCSoundPlayer.sharedInstance.playSound(key)
    }
    
    /**
    Plays sound that corresponds to *key* at *volume*.
    
    :param: _ The key of the sound to play.
    :param: atVolume The volume to play the sound at.
    :returns: true if the sound will play, false otherwise.
    */
    public class func playSound(_ key:String, atVolume volume:CGFloat) -> Bool {
        return CCSoundPlayer.sharedInstance.playSound(key, atVolume: volume)
    }
    
    /**
    Stops playing a specific sound. Returns true if the sound was stopped
    and false if the sound was nil or if the sound was not stopped.
    */
    public class func stopSound(_ key:String) -> Bool {
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
    public class func set(_ forExtension:String, forPropertyDictionary dict:[String:String]) {
        CCSoundPlayer.sharedInstance.defaultProperties[forExtension] = dict
    }
    
}

extension CCSoundPlayer: Sequence {
    
    public typealias Iterator = Array<CCSound>.Iterator
    
    public func makeIterator() -> Iterator {
        return self.sounds.map() { $0.1 } .makeIterator()
    }
    
}
