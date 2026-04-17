//
//  UserAgentBuilder.swift
//  1TrulbargrovarStrinel
//
//  Builds a Safari-like User-Agent from actual device info (OS version, platform).
//  No hardcoding of device-specific values; WebView is not indicated.
//

import UIKit

enum UserAgentBuilder {

    /// Builds a User-Agent string that reflects the current device (OS version, platform)
    /// and does not indicate in-app WebView usage. Uses only runtime device info.
    static func build() -> String {
        let device = UIDevice.current
        let osVersion = device.systemVersion
        let osVersionUnderscore = osVersion.replacingOccurrences(of: ".", with: "_")
        let model = device.model
        let platform: String
        let cpuPart: String
        if model.hasPrefix(LoadingScrambledLine.uaPlatformIPad) {
            platform = LoadingScrambledLine.uaPlatformIPad
            cpuPart = LoadingScrambledLine.uaCpuOSPrefixIPad + osVersionUnderscore
        } else if model.hasPrefix("iPod") {
            platform = LoadingScrambledLine.uaPlatformIPod
            cpuPart = LoadingScrambledLine.uaCpuOSPrefixIPhone + osVersionUnderscore
        } else {
            platform = LoadingScrambledLine.uaPlatformIPhone
            cpuPart = LoadingScrambledLine.uaCpuOSPrefixIPhone + osVersionUnderscore
        }

        return [
            "\(LoadingScrambledLine.uaMozillaPrefix)\(platform)\(LoadingScrambledLine.uaSemicolonSpacer)\(cpuPart)\(LoadingScrambledLine.uaLikeMacOSXSuffix)",
            LoadingScrambledLine.uaAppleWebKitChunk,
            "\(LoadingScrambledLine.uaVersionPrefix)\(osVersion)",
            LoadingScrambledLine.uaSafariTail
        ].joined(separator: " ")
    }
}
