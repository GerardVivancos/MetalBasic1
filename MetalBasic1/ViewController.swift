//
//  ViewController.swift
//  MetalBasic1
//
//  Created by garbage on 01/08/2020.
//  Copyright © 2020 tmcg. All rights reserved.
//

import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController {
    
    var mtkView: MTKView!
    var deviceList: [MTLDevice]!
    //var deviceObserver: NSObject!
    var renderer: Renderer!

    

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to ViewController is not an MTKView!")
            return
        }
        
        initializeDeviceList()
        guard let device = chooseDevice(preferLowPower: true) else {
            return
        }
        
        mtkView.device = device
        print("Selected device is \(mtkView.device!.name)")
        
        guard let tempRenderer = Renderer(mtkView: mtkView) else {
            print("Renderer failed to initialize")
            return
        }
        renderer = tempRenderer

        mtkView.delegate = renderer

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // Only for devices where GPUs can be hot attached and detached
    // notification can be "wasAttached", "removalRequested" or "wasRemoved"
    func handleExternalGPUEvents(device: MTLDevice, notification: MTLDeviceNotificationName) {
        print("GPU event received for device \(device.registryID)(\(device.name)): \(notification.rawValue)")
        switch notification {
        case .wasAdded:
            // Handle addition
            break
        case .removalRequested:
            // Handle safe disconnect
            break
        case .wasRemoved:
            // Handle removal
            break
        default:
            break
        }
    }

    func initializeDeviceList() {
        let devicesWithObserver = MTLCopyAllDevicesWithObserver(handler: { (device, name) in
            self.handleExternalGPUEvents(device: device, notification: name)
        })
        deviceList = devicesWithObserver.devices
        //deviceObserver = devicesWithObserver.observer
        
        guard let devices = deviceList else { return }
        for device in devices {
            print("Device: \(device.name).\n - Is Low Power? \(device.isLowPower)")
        }
    }
    
    func chooseDevice(preferLowPower: Bool) -> MTLDevice? {
        var lowPowerGPUs = [MTLDevice]()
        var highPowerGPUs = [MTLDevice]()
        
        guard let devices = deviceList else { return nil }
        
        for device in devices {
            if device.isLowPower {
                lowPowerGPUs.append(device)
            } else {
                highPowerGPUs.append(device)
            }
        }
        
        if preferLowPower {
            return lowPowerGPUs.first
        } else {
            return highPowerGPUs.first
        }
    }
}

