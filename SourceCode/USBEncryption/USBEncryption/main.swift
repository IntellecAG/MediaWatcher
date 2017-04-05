//
//  main.swift
//  USBEncryption
//
//  Created by DEGEN, Dominic on 07.03.17.
//  Copyright © 2017 DEGEN, Dominic. All rights reserved.
//
//  Changelog
//  2017-04-05  1.0     Initial Version
//
//


import Foundation
import DiskArbitration
import WebKit

let allocator: CFAllocator;
let cfallocator: UnsafeMutablePointer<CFAllocatorContext>;
//Specify a timeframe that will be used later on in order to verify if a message should be displayed. We used 10 seconds to avoid notifying about volumes that are connected since a longer time
let lastSeconds = Date(timeIntervalSinceNow: TimeInterval(-10))

let disk: DADisk;

NSLog("MediaWatcher has been launched by a launchdaemon or manual action. Checking all mounted Devices for unencrypted Devices.")
//Declaration of an array to store the found volumes
var unencryptedVolumes = [NSString]()
//opening session for accessing the Disk informations using the Disk Arbitration Framework
if let session = DASessionCreate(kCFAllocatorDefault) {
    //Checking for mounted volumes
    let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [], options: [])!
    //Looping through all volumes
    for volume in mountedVolumes {
        //Creation of disk objects
        if let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, volume as CFURL) {
           //Diskinfo1 is only used for Debug purposes and should be removed in a productive version
           let diskinfo1 = DADiskCopyDescription(disk);
           print(diskinfo1.debugDescription)
              if  let diskinfo = DADiskCopyDescription(disk) as? [NSString: Any] {
                if diskinfo[kDADiskDescriptionDeviceInternalKey] as? Bool == false{
                    if(diskinfo[kDADiskDescriptionMediaContentKey] as! String).range(of: "Windows") == nil{
                        if (diskinfo[kDADiskDescriptionVolumeTypeKey] as! String).range(of:"Encrypted") != nil{
                        }
                        else {
                            if let time = diskinfo["DAAppearanceTime"] as? Double {
                                let date = Date(timeIntervalSinceReferenceDate: time)
                                NSLog("Unencrypted Disk found! Volume Name: \(diskinfo[kDADiskDescriptionVolumeNameKey] as! String) Checking if the User was notified...")
                                if(date>lastSeconds){
                                    NSLog("Not notified yet, adding it to the notification list.")
                                    unencryptedVolumes.append(diskinfo[kDADiskDescriptionVolumeNameKey] as! NSString)
                                }
                                else{
                                    NSLog("User has already been notified but the medium is still connected...")
                                }
                            }
                  
                        }
                    }
                    else{
                        if(diskinfo[kDADiskDescriptionMediaWritableKey] as? Bool) != false{
                            if let time = diskinfo["DAAppearanceTime"] as? Double {
                                let date = Date(timeIntervalSinceReferenceDate: time)
                                NSLog("Unencrypted Disk found! Volume Name: \(diskinfo[kDADiskDescriptionVolumeNameKey] as! String) Checking if the User was notified...")
                                if(date>lastSeconds){
                                    NSLog("Not notified yet, adding it to the notification list.")
                                    unencryptedVolumes.append(diskinfo[kDADiskDescriptionVolumeNameKey] as! NSString)
                                }
                                else{
                                     NSLog("User has already been notified but the medium is still connected...")
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
}
//Checking if any unencrypted volumes have been found
if (unencryptedVolumes.count > 0){
    NSLog("Found entries in the notification stack")
    for volume in unencryptedVolumes{
        let task = Process()
        task.launchPath = "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        //The Message needs to be updated with individual data
        task.arguments = ["-windowType", "hud", "-icon", "/Library/Application Support/PathToLogo/logo_rgb.png", "-title", "Warning about the Disk :)", "-button1", "Agree", "-defaultButton", "1", "-startlaunchd"]
        task.launch()
        task.waitUntilExit()
    }
}
