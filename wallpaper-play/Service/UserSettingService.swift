import Foundation
import AppKit
import LaunchAtLogin

protocol UserSettingService {
    var launchAtLogin: Bool { get set }
    var visibilityIcon: Bool { get set }
    var openThisWindowAtFirst: Bool { get set }
}

class UserSettingServiceImpl: UserSettingService {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var launchAtLogin: Bool {
        get {
            LaunchAtLogin.isEnabled
        }
        set {
            LaunchAtLogin.isEnabled = newValue
        }
    }
    
    var visibilityIcon: Bool {
        get {
            if userDefaults.object(forKey: "visibilityIcon") == nil {
                userDefaults.set(true, forKey: "visibilityIcon")
            }
            return userDefaults.bool(forKey: "visibilityIcon")
        }
        set {
            userDefaults.set(newValue, forKey: "visibilityIcon")
        }
    }

    var openThisWindowAtFirst: Bool {
        get {
            if userDefaults.object(forKey: "openThisWindowAtFirst") == nil {
                userDefaults.set(true, forKey: "openThisWindowAtFirst")
            }
            return userDefaults.bool(forKey: "openThisWindowAtFirst")
        }
        set {
            userDefaults.set(newValue, forKey: "openThisWindowAtFirst")
        }
    }
}
