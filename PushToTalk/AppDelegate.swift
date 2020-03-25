//
//  AppDelegate.swift
//  PushToTalk
//
//  Created by Ahmy Yulrizka on 17/03/15.
//  Copyright (c) 2015 yulrizka. All rights reserved.
//

import Cocoa
import AudioToolbox
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var menuItemToggle: NSMenuItem!

  var enable = true

  var talkIcon:NSImage?
  var muteIcon:NSImage?

  let statusItem = NSStatusBar.system.statusItem(withLength: -1)

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    talkIcon = NSImage(named: "talk")
    muteIcon = NSImage(named: "mute")
    updateToggleTitle()

    statusItem.image = muteIcon
    statusItem.menu = statusMenu

    // handle when application is on background
    NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.flagsChanged, handler: handleFlagChangedEvent)

    // handle when application is on foreground
    NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.flagsChanged, handler: { (theEvent) -> NSEvent? in
      self.handleFlagChangedEvent(theEvent)
      return theEvent
    })
  }

  func handleFlagChangedEvent(_ theEvent:NSEvent!) {
    if !self.enable {
      return
    }

    if theEvent.modifierFlags.contains(NSEvent.ModifierFlags.function) {
      self.toggleMic(true)
    } else {
      self.toggleMic(false)
    }
  }

  func toggleMic(_ enable:Bool) {
    if (enable) {
      toggleMute(false)
      statusItem.image = talkIcon
    } else {
      toggleMute(true)
      statusItem.image = muteIcon
    }
  }

  func getDefaultInputDevice(_ defaultOutputDeviceID:inout UInt32)  {
    defaultOutputDeviceID = AudioDeviceID(0)
    var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))

    var getDefaultInputDevicePropertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultInputDevice),
      mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

    let err = AudioObjectGetPropertyData(
      AudioObjectID(kAudioObjectSystemObject),
      &getDefaultInputDevicePropertyAddress,
      0,
      nil,
      &defaultOutputDeviceIDSize,
      &defaultOutputDeviceID)

    if (err != kAudioHardwareNoError) {
      NSLog("Error setting audio object property data #%d", err);
    }
  }

  func toggleMute(_ mute:Bool) {
		// https://github.com/paulreimer/ofxAudioFeatures/blob/master/src/ofxAudioDeviceControl.mm
    var defaultInputDeviceId = AudioDeviceID(0)
    getDefaultInputDevice(&defaultInputDeviceId)

    var address = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioDevicePropertyMute),
      mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeInput),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

    let size = UInt32(MemoryLayout<UInt32>.size)
    var mute:UInt32 = mute ? 1 : 0;

    let err = AudioObjectSetPropertyData(defaultInputDeviceId, &address, 0, nil, size, &mute)

    if (err != kAudioHardwareNoError) {
      NSLog("Error setting audio object property data #%d", err);
    }
  }

  func updateToggleTitle() {
    if (enable) {
      menuItemToggle.title = "Disable"
      statusItem.image = muteIcon
    } else {
      menuItemToggle.title = "Enable"
      statusItem.image = talkIcon
    }
  }

  @IBAction func toggleAction(_ sender: NSMenuItem) {
    enable = !enable
    toggleMute(enable)
    updateToggleTitle()
  }

  @IBAction func menuItemQuitAction(_ sender: NSMenuItem) {
    toggleMute(false)
    exit(0)
  }
}
