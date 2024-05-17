//
//  BLEManager.swift
//  PALApp
//
//  Created by Eric Bariaux on 27/04/2024.
//

import Foundation
import CoreBluetooth
import Combine

enum BLEStatus {
    case off
    case on
    case scanning
    case connecting
    case connected
    case linked
    case disconnected
}

struct DiscoveredDevice: Identifiable, Hashable {
    var id: UUID
    var name: String
}

class BLEManager : NSObject, ObservableObject {

    @Published var status: BLEStatus = .off
    
    @Published var discoveredPeripheralsMap: [UUID: CBPeripheral] = [:]
    var discoveredPeripherals: [DiscoveredDevice] {
        return discoveredPeripheralsMap.values.map({ peripheral in
            let name = peripheral.name ?? peripheral.identifier.uuidString
            return DiscoveredDevice(id: peripheral.identifier, name: name)
        }).sorted { $0.name < $1.name }
    }
    var servicesRegistry: [CBUUID: CBService] = [:]
    var characteristicsRegistry: [CBUUID: CBCharacteristic] = [:]

    let valueChanges = PassthroughSubject<(CBUUID, Data), Error>()
    
    var connectedDevice: Friend?
    
    private var wearableRegistry: [any WearableDevice.Type] = []

    private var manager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var scanServices: [CBUUID] = []
    private var shouldStartScanning = false
    
    func registerDevice(wearable: any WearableDevice.Type) {
        if !scanServices.contains(wearable.scanServiceUUID) {
            wearableRegistry.append(wearable)
            scanServices.append(wearable.scanServiceUUID)
        }
        // TODO: return error if service with same scan UUID already registered
    }
    
    func resetDiscoveredDevices() {
        discoveredPeripheralsMap.removeAll()
    }
    
    func startScanning() {
        resetDiscoveredDevices()
        if manager == nil {
            manager = CBCentralManager(delegate: self, queue: nil)
        }
        if let manager, manager.state == .poweredOn {
            forceStartScanning()
        } else {
            shouldStartScanning = true
        }
    }
    
    func stopScanning() {
        status = .disconnected
        manager?.stopScan()
    }

    func connect(to: UUID) {
        if let manager, let peripheral = discoveredPeripheralsMap[to] {
            manager.stopScan()
            manager.connect(peripheral)
            status = .connecting
        }
    }
    
    func setNotify(enabled: Bool, forCharacteristics characteristicId: CBUUID) {
        if let peripheral, let characteritic = characteristicsRegistry[characteristicId] {
            peripheral.setNotifyValue(enabled, for: characteritic)
        }
    }
    
    /// Starts scan irrelevant of the power state of the manager, will result in error if not powered on
    private func forceStartScanning() {
        if let manager {
            manager.scanForPeripherals(withServices: scanServices)
            status = .scanning
        }
    }
}

extension BLEManager : CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        status = (central.state == .poweredOn ? .on : .off)
        if central.state == .poweredOn && shouldStartScanning {
            forceStartScanning()
            shouldStartScanning = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered \(peripheral.identifier) - \(String(describing: peripheral.name))")

        if discoveredPeripheralsMap[peripheral.identifier] == nil {
            discoveredPeripheralsMap[peripheral.identifier] = peripheral
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        status = .connected
        self.peripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        status = .disconnected
        print("Did disconnect \(peripheral)")
        if let error {
            print(error.localizedDescription)
        }
    }

}

extension BLEManager : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let services = peripheral.services {
            for service in services {
                if let wearable = wearableRegistry.first(where: { $0.scanServiceUUID == service.uuid }) {
                    connectedDevice = wearable.init(bleManager: self, name: peripheral.name ?? peripheral.identifier.uuidString) as! Friend
                    status = .linked
                }
            }
            
            for service in services {
                print("Discovered service \(service)")
                servicesRegistry[service.uuid] = service
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let characteristics = service.characteristics {
            for c in characteristics {
                characteristicsRegistry[c.uuid] = c
                print("Discovered characteristic \(c)")
                if let connectedDevice {
                    if connectedDevice.notifyCharacteristicsUUIDs.contains(c.uuid) {
                        print("Asking for notifications")
                        peripheral.setNotifyValue(true, for: c)
                        peripheral.readValue(for: c)
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        print("didUpdateValue \(characteristic)")
        if let v = characteristic.value {
            valueChanges.send((characteristic.uuid, v))
        }
    }

}
