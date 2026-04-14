//
//  AppLegalURL.swift
//  136KexmexcregrexPrellil
//

import Foundation

/// Legal and policy URLs (replace hosts when your pages are ready).
enum AppLegalURL: String {
    case privacyPolicy = "https://kexmexcregrex136prellil.site/privacy/102"
    case termsOfUse = "https://kexmexcregrex136prellil.site/terms/102"

    var url: URL? {
        URL(string: rawValue)
    }
}
