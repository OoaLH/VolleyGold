//
//  NetworkMonitor.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import Network

class NetworkMonitor {
    static public let shared = NetworkMonitor()
    
    public var monitoring: Bool = false
    
    public var usingCellular: Bool = false
    
    public var reachable: Bool = false
    
    private let cellular: NWPathMonitor = {
        let monitor = NWPathMonitor(requiredInterfaceType: .cellular)
        monitor.pathUpdateHandler = { path in
            switch path.status {
            case .satisfied:
                shared.usingCellular = shared.wifi.currentPath.status == .unsatisfied
                shared.reachable = true
            default:
                shared.usingCellular = false
                shared.reachable = shared.wifi.currentPath.status == .satisfied
            }
        }
        return monitor
    }()
    
    private let wifi: NWPathMonitor = {
        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        monitor.pathUpdateHandler = { path in
            switch path.status {
            case .satisfied:
                shared.usingCellular = false
                shared.reachable = true
            case .unsatisfied:
                shared.usingCellular = shared.cellular.currentPath.status == .satisfied
                shared.reachable = shared.cellular.currentPath.status == .satisfied
            default:
                shared.usingCellular = false
                shared.reachable = shared.cellular.currentPath.status == .satisfied
            }
        }
        return monitor
    }()
    
    public func start() {
        if monitoring {
            print("already started.")
            return
        }
        monitoring = true
        let queue = DispatchQueue(label: "Monitor")
        cellular.start(queue: queue)
        wifi.start(queue: queue)
    }
    
    public func stop() {
        monitoring = false
        cellular.cancel()
        wifi.cancel()
    }
}

