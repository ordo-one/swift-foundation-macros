//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#if FOUNDATION_FRAMEWORK

@_implementationOnly import _ForSwiftFoundation
import CoreFoundation
@_implementationOnly import os
@_implementationOnly import CoreFoundation_Private.CFLocale
@_implementationOnly import Foundation_Private.NSLocale

/// Entry points for the ObjC and C code to call into the common Swift implementation.
@objc
extension NSLocale {
    @objc
    static var _autoupdatingCurrent: NSLocale {
        LocaleCache.cache.autoupdatingCurrentNSLocale()
    }

    @objc
    static var _current: NSLocale {
        LocaleCache.cache.currentNSLocale()
    }

    @objc
    static var _system: NSLocale {
        LocaleCache.cache.systemNSLocale()
    }

    @objc
    private class func _newLocaleWithIdentifier(_ idStr: String) -> NSLocale {
        LocaleCache.cache.fixedNSLocale(idStr)
    }

    @objc
    private class func _newLocaleAsIfCurrent(_ name: String?, overrides: CFDictionary?, disableBundleMatching: Bool) -> NSLocale? {
        let inner = LocaleCache.cache.localeAsIfCurrent(name: name, cfOverrides: overrides, disableBundleMatching: disableBundleMatching)
        return _NSSwiftLocale(inner)
    }

    @objc(_currentLocaleWithBundleLocalizations:disableBundleMatching:)
    private class func _currentLocaleWithBundleLocalizations(_ availableLocalizations: [String], allowsMixedLocalizations: Bool) -> NSLocale? {
        guard let inner = LocaleCache.cache.localeAsIfCurrentWithBundleLocalizations(availableLocalizations, allowsMixedLocalizations: allowsMixedLocalizations) else {
            return nil
        }
        return _NSSwiftLocale(inner)
    }

    @objc
    private class func _resetCurrent() {
        LocaleCache.cache.reset()
    }

    @objc
    private class func _preferredLanguagesForCurrentUser(_ forCurrentUser: Bool) -> [String] {
        LocaleCache.cache.preferredLanguages(forCurrentUser: forCurrentUser)
    }

    @objc
    class var _availableLocaleIdentifiers: [String] {
        Locale.availableLocaleIdentifiers
    }

    // This is internal, but silence the compiler's warnings about deprecation by deprecating this, too.
    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    @objc
    class var _isoLanguageCodes: [String] {
        Locale.isoLanguageCodes
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    @objc
    class var _isoCountryCodes: [String] {
        Locale.isoRegionCodes
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    @objc
    class var _isoCurrencyCodes: [String] {
        Locale.isoCurrencyCodes
    }

    @objc
    class var _commonISOCurrencyCodes: [String] {
        Locale.commonISOCurrencyCodes
    }

    @objc
    class var _preferredLanguages: [String] {
        Locale.preferredLanguages
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    @objc(_componentsFromLocaleIdentifier:)
    class func _components(fromLocaleIdentifier string: String) -> [String : String] {
        Locale.components(fromIdentifier: string)
    }

    @objc(_localeIdentifierFromComponents:)
    class func _localeIdentifier(fromComponents dict: [String : Any]) -> String {
        // n.b. the CFLocaleCreateLocaleIdentifierFromComponents API is normally [String: String], but for 'convenience' allows a `Calendar` value for "kCFLocaleCalendarKey"/"calendar". We call through to a compatibility version of `Locale.identifier(fromComponents:)` to support this.
        Locale.identifier(fromComponents: dict)
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    @objc(_canonicalLocaleIdentifierFromString:)
    class func _canonicalLocaleIdentifier(from string: String) -> String {
        Locale.canonicalIdentifier(from: string)
    }

    @objc(_canonicalLanguageIdentifierFromString:)
    class func _canonicalLanguageIdentifier(from string: String) -> String {
        Locale.canonicalLanguageIdentifier(from: string)
    }

    @objc(_localeIdentifierFromWindowsLocaleCode:)
    class func _localeIdentifier(fromWindowsLocaleCode: UInt32) -> String? {
        Locale.identifier(fromWindowsLocaleCode: Int(fromWindowsLocaleCode))
    }

    @objc(_windowsLocaleCodeFromLocaleIdentifier:)
    class func _windowsLocaleCode(fromLocaleIdentifier localeIdentifier: String) -> UInt32 {
        if let result = Locale.windowsLocaleCode(fromIdentifier: localeIdentifier) {
            return UInt32(result)
        }
        return 0
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    @objc(_characterDirectionForLanguage:)
    class func _characterDirection(forLanguage isoLangCode: String) -> NSLocale.LanguageDirection {
        NSLocale.LanguageDirection(rawValue: Locale.characterDirection(forLanguage: isoLangCode).rawValue) ?? .rightToLeft
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    @objc(_lineDirectionForLanguage:)
    class func _lineDirection(forLanguage isoLangCode: String) -> NSLocale.LanguageDirection {
        NSLocale.LanguageDirection(rawValue: Locale.lineDirection(forLanguage: isoLangCode).rawValue) ?? .rightToLeft
    }

    @objc(_numberingSystemForLocaleIdentifier:)
    class func _numberingSystem(forLocaleIdentifier identifier: String) -> String? {
        let components = Locale.Components(identifier: identifier)
        if let system = components.numberingSystem {
            return system.identifier
        }
        if let defaultSystem = Locale.NumberingSystem.defaultNumberingSystem(for: identifier) {
            return defaultSystem.identifier
        }
        return nil
    }

    @objc(_validNumberingSystemsForLocaleIdentifier:)
    class func _validNumberingSystems(forLocaleIdentifier identifier: String) -> [String] {
        Locale.NumberingSystem.validNumberingSystems(for: identifier).map { $0.identifier }
    }

    @objc(_localeIdentifierByReplacingLanguageCodeAndScriptCodeForLangCode:desiredComponents:)
    class func _localeIdentifierByReplacingLanguageCodeAndScriptCode(_ localeIDWithDesiredLangCode: String, desiredComponents localeIDWithDesiredComponents: String) -> String? {
        _Locale.localeIdentifierByReplacingLanguageCodeAndScriptCode(localeIDWithDesiredLangCode: localeIDWithDesiredLangCode, localeIDWithDesiredComponents: localeIDWithDesiredComponents)
    }

    @objc(_localeIdentifierByAddingLikelySubtags:)
    class func _localeIdentifierByAddingLikelySubtags(_ localeID: String) -> String {
        _Locale.localeIdentifierWithLikelySubtags(localeID)
    }

    @objc(_localeWithNewCalendarIdentifier:)
    func _localeWithNewCalendarIdentifier(_ calendarIdentifier: String?) -> NSLocale? {
        guard let calendarIdentifier else {
            // No real need to copy here; Locale is immutable
            return self
        }

        guard let swiftLocale = self as? _NSSwiftLocale else {
            // We do not support this function for custom subclasses of NSLocale
            return nil
        }

        guard let id = Calendar._fromNSCalendarIdentifier(NSCalendar.Identifier(rawValue: calendarIdentifier)) else {
            return nil
        }

        let copy = swiftLocale.locale.copy(newCalendarIdentifier: id)
        return _NSSwiftLocale(copy)
    }

    @objc(_doesNotRequireSpecialCaseHandling)
    func _doesNotRequireSpecialCaseHandling() -> Bool {
        let locale: Locale
        if let swiftLocale = self as? _NSSwiftLocale {
            locale = swiftLocale.locale
        } else {
            // Unable to use cached locale; create a new one
            locale = Locale(identifier: localeIdentifier)
        }

        return locale.doesNotRequireSpecialCaseHandling
    }
}

/// Wraps an NSLocale with a more Swift-like `Locale` API.
/// This is only used in the case where we have custom Objective-C subclasses of `NSLocale`. It is assumed that the subclass is Sendable.
/// TODO: It is a bit of a TBD if this extra effort to preserve a subclass sent to Swift from ObjC is worth it for `struct Locale`.
internal final class _NSLocaleSwiftWrapper: @unchecked Sendable, Hashable, CustomDebugStringConvertible {
    let _wrapped: NSLocale

    init(adoptingReference reference: NSLocale) {
        self._wrapped = reference
    }

    func bridgeToObjectiveC() -> NSLocale {
        return _wrapped.copy() as! NSLocale
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_wrapped.hash)
    }

    public static func ==(lhs: _NSLocaleSwiftWrapper, rhs: _NSLocaleSwiftWrapper) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public var debugDescription: String {
        _wrapped.debugDescription
    }

    // MARK: -

    func identifierDisplayName(for identifier: String) -> String? {
        return _wrapped.displayName(forKey: .identifier, value: identifier)
    }

    func languageCodeDisplayName(for languageCode: String) -> String? {
        return _wrapped.displayName(forKey: .languageCode, value: languageCode)
    }

    func countryCodeDisplayName(for regionCode: String) -> String? {
        return _wrapped.displayName(forKey: .countryCode, value: regionCode)
    }

    func scriptCodeDisplayName(for scriptCode: String) -> String? {
        return _wrapped.displayName(forKey: .scriptCode, value: scriptCode)
    }

    func variantCodeDisplayName(for variantCode: String) -> String? {
        return _wrapped.displayName(forKey: .variantCode, value: variantCode)
    }

    func calendarIdentifierDisplayName(for calendarIdentifier: Calendar.Identifier) -> String? {
        // NSLocale doesn't export a constant for this
        let result = CFLocaleCopyDisplayNameForPropertyValue(unsafeBitCast(_wrapped, to: CFLocale.self), .calendarIdentifier, Calendar._toNSCalendarIdentifier(calendarIdentifier).rawValue as CFString) as String?
        return result
    }

    func currencyCodeDisplayName(for currencyCode: String) -> String? {
        return _wrapped.displayName(forKey: .currencyCode, value: currencyCode)
    }
    
    func currencySymbolDisplayName(for currencySymbol: String) -> String? {
        return _wrapped.displayName(forKey: .currencySymbol, value: currencySymbol)
    }

    func collationIdentifierDisplayName(for collationIdentifier: String) -> String? {
        return _wrapped.displayName(forKey: .collationIdentifier, value: collationIdentifier)
    }

    func collatorIdentifierDisplayName(for collatorIdentifier: String) -> String? {
        return _wrapped.displayName(forKey: .collatorIdentifier, value: collatorIdentifier)
    }

    // MARK: -
    //

    var identifier: String {
        return _wrapped.localeIdentifier
    }

    var languageCode: String? {
        return _wrapped.object(forKey: .languageCode) as? String
    }

    var countryCode: String? {
        if let result = _wrapped.object(forKey: .countryCode) as? String {
            if result.isEmpty {
                return nil
            } else {
                return result
            }
        } else {
            return nil
        }
    }

    var scriptCode: String? {
        return _wrapped.object(forKey: .scriptCode) as? String
    }

    var variantCode: String? {
        if let result = _wrapped.object(forKey: .variantCode) as? String {
            if result.isEmpty {
                return nil
            } else {
                return result
            }
        } else {
            return nil
        }
    }

    var exemplarCharacterSet: CharacterSet? {
        return _wrapped.object(forKey: .exemplarCharacterSet) as? CharacterSet
    }

    var calendar: Calendar {
        if let result = _wrapped.object(forKey: .calendar) as? Calendar {
            // NSLocale should not return nil here
            return result
        } else {
            return Calendar(identifier: .gregorian)
        }
    }

    var calendarIdentifier: Calendar.Identifier {
        return Calendar._fromNSCalendarIdentifier(NSCalendar.Identifier(rawValue: _wrapped.calendarIdentifier)) ?? .gregorian
    }

    var collationIdentifier: String? {
        return _wrapped.object(forKey: .collationIdentifier) as? String
    }

    var usesMetricSystem: Bool {
        // NSLocale should not return nil here, but just in case
        if let result = (_wrapped.object(forKey: .usesMetricSystem) as? NSNumber)?.boolValue {
            return result
        } else {
            return false
        }
    }

    var decimalSeparator: String? {
        return _wrapped.object(forKey: .decimalSeparator) as? String
    }

    var groupingSeparator: String? {
        return _wrapped.object(forKey: .groupingSeparator) as? String
    }

    var currencySymbol: String? {
        return _wrapped.object(forKey: .currencySymbol) as? String
    }

    var currencyCode: String? {
        return _wrapped.object(forKey: .currencyCode) as? String
    }

    var collatorIdentifier: String? {
        return _wrapped.object(forKey: .collatorIdentifier) as? String
    }

    var quotationBeginDelimiter: String? {
        return _wrapped.object(forKey: .quotationBeginDelimiterKey) as? String
    }

    var quotationEndDelimiter: String? {
        return _wrapped.object(forKey: .quotationEndDelimiterKey) as? String
    }

    var alternateQuotationBeginDelimiter: String? {
        return _wrapped.object(forKey: .alternateQuotationBeginDelimiterKey) as? String
    }

    var alternateQuotationEndDelimiter: String? {
        return _wrapped.object(forKey: .alternateQuotationEndDelimiterKey) as? String
    }
}

extension NSLocale.Key {
    // Extra keys used by CoreFoundation
    static var cfLocaleCollatorID = NSLocale.Key(rawValue: "locale:collator id")
}

/// Wraps a Swift `struct Locale` with an `NSLocale`, so that it can be used from Objective-C.
/// The goal is to forward as much of the implementation as possible into Swift.
@objc(_NSSwiftLocale)
internal class _NSSwiftLocale: _NSLocaleBridge {
    var locale: Locale

    internal init(_ locale: Locale) {
        self.locale = locale
        // The superclass does not care at all what the identifier is. Avoid a potentially recursive call into the Locale cache here by just using an empty string.
        super.init(localeIdentifier: "")
    }

    // MARK: - Coding

    override var classForCoder: AnyClass {
        if locale == Locale.autoupdatingCurrent {
            return NSAutoLocale.self
        } else {
            return NSLocale.self
        }
    }
    
    override init(localeIdentifier string: String) {
        self.locale = Locale(identifier: string)
        super.init(localeIdentifier: "")
    }

    // Even though we do not expect init(coder:) to be called, we have to implement it per the DI rules - and if we implement it, we are required to override this method to prove that we support secure coding.
    override static var supportsSecureCoding: Bool { true }

    required init?(coder: NSCoder) {
        // TODO: This will never be invoked as long as we have a "placeholder" NSLocale in CoreFoundation
        guard coder.allowsKeyedCoding else {
            coder.failWithError(CocoaError(CocoaError.coderReadCorrupt, userInfo: [NSDebugDescriptionErrorKey : "Cannot be decoded without keyed coding"]))
            return nil
        }

        guard let ident = coder.decodeObject(of: NSString.self, forKey: "NS.identifier") as? String else {
            coder.failWithError(CocoaError(CocoaError.coderReadCorrupt, userInfo: [NSDebugDescriptionErrorKey : "Identifier has been corrupted"]))
            return nil
        }

        locale = Locale(identifier: ident)

        // Must call a DI; this one does nothing so it's safe to call here.
        super.init(localeIdentifier: "")
    }

    override func encode(with coder: NSCoder) {
        if coder.allowsKeyedCoding {
            coder.encode(locale.identifier, forKey: "NS.identifier")
        } else {
            coder.failWithError(CocoaError(CocoaError.coderReadCorrupt, userInfo: [NSDebugDescriptionErrorKey : "Cannot be encoded without keyed coding"]))
        }
    }

    // MARK: -

    // Primitives. Silence the deprecation warning used here.
    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    override func object(forKey key: NSLocale.Key) -> Any? {
        switch key {
        case .identifier: return self.localeIdentifier
        case .languageCode: return self.languageCode
        case .countryCode: return self.countryCode
        case .scriptCode: return self.scriptCode
        case .variantCode: return self.variantCode
        case .exemplarCharacterSet: return self.exemplarCharacterSet
        case .calendarIdentifier: return self.calendarIdentifier
        case .calendar: return locale.calendar
        case .collationIdentifier: return self.collationIdentifier
        case .usesMetricSystem: return self.usesMetricSystem
        case .measurementSystem:
            switch locale.measurementSystem {
            case .us: return NSLocaleMeasurementSystemUS
            case .uk: return NSLocaleMeasurementSystemUK
            case .metric: return NSLocaleMeasurementSystemMetric
            default: return NSLocaleMeasurementSystemMetric
            }
        case .temperatureUnit:
            switch locale.temperatureUnit {
            case .celsius: return NSLocaleTemperatureUnitCelsius
            case .fahrenheit: return NSLocaleTemperatureUnitFahrenheit
            default: return NSLocaleTemperatureUnitCelsius
            }
        case .decimalSeparator: return self.decimalSeparator
        case .groupingSeparator: return self.groupingSeparator
        case .currencySymbol: return self.currencySymbol
        case .currencyCode: return self.currencyCode
        case .collatorIdentifier, .cfLocaleCollatorID: return self.collatorIdentifier
        case .quotationBeginDelimiterKey: return self.quotationBeginDelimiter
        case .quotationEndDelimiterKey: return self.quotationEndDelimiter
        case .alternateQuotationBeginDelimiterKey: return self.alternateQuotationBeginDelimiter
        case .alternateQuotationEndDelimiterKey: return self.alternateQuotationEndDelimiter
        default:
            return nil
        }
    }

    override func displayName(forKey key: NSLocale.Key, value: Any) -> String? {
        guard let value = value as? String else {
            return nil
        }

        switch key {
        case .identifier: return self.localizedString(forLocaleIdentifier: value)
        case .languageCode: return self.localizedString(forLanguageCode: value)
        case .countryCode: return self.localizedString(forCountryCode: value)
        case .scriptCode: return self.localizedString(forScriptCode: value)
        case .variantCode: return self.localizedString(forVariantCode: value)
        case .exemplarCharacterSet: return nil
        case .calendar: return self.localizedString(forCalendarIdentifier: value)
        case .collationIdentifier: return self.localizedString(forCollationIdentifier: value)
        case .usesMetricSystem: return nil
        case .measurementSystem: return nil
        case .decimalSeparator: return nil
        case .groupingSeparator: return nil
        case .currencySymbol: return self.localizedString(forCurrencySymbol: value)
        case .currencyCode: return self.localizedString(forCurrencyCode: value)
        case .collatorIdentifier: return self.localizedString(forCollatorIdentifier: value)
        case .quotationBeginDelimiterKey: return nil
        case .quotationEndDelimiterKey: return nil
        case .alternateQuotationBeginDelimiterKey: return nil
        case .alternateQuotationEndDelimiterKey: return nil
        default:
            return nil
        }
    }

    // MARK: -

    override var localeIdentifier: String {
        locale.identifier
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    override var languageCode: String {
        locale.languageCode ?? ""
    }

    override var languageIdentifier: String {
        let langIdentifier = locale.language.components.identifier
        let localeWithOnlyLanguage = Locale(identifier: langIdentifier)
        return localeWithOnlyLanguage.identifier(.bcp47)
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    override var countryCode: String? {
        locale.region?.identifier
    }

    override var regionCode: String? {
        locale.region?.identifier
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    override var scriptCode: String? {
        locale.scriptCode
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    override var variantCode: String? {
        locale.variantCode
    }

    override var calendarIdentifier: String {
        locale._calendarIdentifier.cfCalendarIdentifier
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    override var collationIdentifier: String? {
        locale.collationIdentifier
    }

    override var decimalSeparator: String {
        locale.decimalSeparator ?? ""
    }

    override var groupingSeparator: String {
        locale.groupingSeparator ?? ""
    }

    override var currencySymbol: String {
        locale.currencySymbol ?? ""
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    override var currencyCode: String? {
        locale.currencyCode
    }

    override var collatorIdentifier: String {
        locale.collatorIdentifier ?? ""
    }

    override var quotationBeginDelimiter: String {
        locale.quotationBeginDelimiter ?? ""
    }

    override var quotationEndDelimiter: String {
        locale.quotationEndDelimiter ?? ""
    }

    override var alternateQuotationBeginDelimiter: String {
        locale.alternateQuotationBeginDelimiter ?? ""
    }

    override var alternateQuotationEndDelimiter: String {
        locale.alternateQuotationEndDelimiter ?? ""
    }

    override var exemplarCharacterSet: CharacterSet {
        locale.exemplarCharacterSet ?? CharacterSet()
    }

    @available(macOS, deprecated: 13) @available(iOS, deprecated: 16) @available(tvOS, deprecated: 16) @available(watchOS, deprecated: 9)
    override var usesMetricSystem: Bool {
        locale.usesMetricSystem
    }

    override func localizedString(forLocaleIdentifier localeIdentifier: String) -> String {
        locale.localizedString(forIdentifier: localeIdentifier) ?? ""
    }

    override func localizedString(forLanguageCode languageCode: String) -> String? {
        locale.localizedString(forLanguageCode: languageCode)
    }

    override func localizedString(forCountryCode countryCode: String) -> String? {
        locale.localizedString(forRegionCode: countryCode)
    }

    override func localizedString(forScriptCode scriptCode: String) -> String? {
        locale.localizedString(forScriptCode: scriptCode)
    }

    override func localizedString(forVariantCode variantCode: String) -> String? {
        locale.localizedString(forVariantCode: variantCode)
    }

    override func localizedString(forCalendarIdentifier calendarIdentifier: String) -> String? {
        guard let id = Calendar._fromNSCalendarIdentifier(.init(calendarIdentifier)) else {
            return nil
        }
        return locale.localizedString(for: id)
    }

    override func localizedString(forCollationIdentifier collationIdentifier: String) -> String? {
        locale.localizedString(forCollationIdentifier: collationIdentifier)
    }

    override func localizedString(forCurrencyCode currencyCode: String) -> String? {
        locale.localizedString(forCurrencyCode: currencyCode)
    }

    override func localizedString(forCurrencySymbol currencySymbol: String) -> String? {
        locale.localizedString(forCurrencySymbol: currencySymbol)
    }

    override func localizedString(forCollatorIdentifier collatorIdentifier: String) -> String? {
        locale.localizedString(forCollatorIdentifier: collatorIdentifier)
    }

    override func _pref(forKey key: String) -> Any? {
        locale.pref(for: key)
    }

    override func _numberingSystem() -> String! {
        locale.numberingSystem.identifier
    }
}

// MARK: - Bridging

@available(macOS 10.10, iOS 8.0, watchOS 2.0, tvOS 9.0, *)
extension Locale : ReferenceConvertible {
    public typealias ReferenceType = NSLocale
}

@available(macOS 10.10, iOS 8.0, watchOS 2.0, tvOS 9.0, *)
extension Locale : _ObjectiveCBridgeable {
    @_semantics("convertToObjectiveC")
    public func _bridgeToObjectiveC() -> NSLocale {
        switch kind {
        case .autoupdating:
            return LocaleCache.cache.autoupdatingCurrentNSLocale()
        case .fixed(let l):
            return LocaleCache.cache.fixedNSLocale(l)
        case .bridged(let wrapper):
            return wrapper._wrapped
        }
    }

    public static func _forceBridgeFromObjectiveC(_ input: NSLocale, result: inout Locale?) {
        if !_conditionallyBridgeFromObjectiveC(input, result: &result) {
            fatalError("Unable to bridge \(_ObjectiveCType.self) to \(self)")
        }
    }

    public static func _conditionallyBridgeFromObjectiveC(_ input: NSLocale, result: inout Locale?) -> Bool {
        result = Locale(reference: input)
        return true
    }

    @_effects(readonly)
    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSLocale?) -> Locale {
        var result: Locale?
        _forceBridgeFromObjectiveC(source!, result: &result)
        return result!
    }
}

@available(macOS 10.10, iOS 8.0, watchOS 2.0, tvOS 9.0, *)
extension NSLocale : _HasCustomAnyHashableRepresentation {
    // Must be @nonobjc to avoid infinite recursion during bridging.
    @nonobjc
    public func _toCustomAnyHashable() -> AnyHashable? {
        return AnyHashable(self as Locale)
    }
}


// MARK: - NSLocale Deprecated API

@available(macOS 10.10, iOS 8.0, watchOS 2.0, tvOS 9.0, *)
extension Locale {
    /// Returns a list of available `Locale` language codes.
    @available(macOS, deprecated: 13, message: "Use `Locale.LanguageCode.isoLanguageCodes` instead")
    @available(iOS, deprecated: 16, message: "Use `Locale.LanguageCode.isoLanguageCodes` instead")
    @available(tvOS, deprecated: 16, message: "Use `Locale.LanguageCode.isoLanguageCodes` instead")
    @available(watchOS, deprecated: 9, message: "Use `Locale.LanguageCode.isoLanguageCodes` instead")
    public static var isoLanguageCodes: [String] {
        Locale.LanguageCode._isoLanguageCodeStrings
    }

    /// Returns a dictionary that splits an identifier into its component pieces.
    @available(macOS, deprecated: 13, message: "Use `Locale.Components(identifier:)` to access components")
    @available(iOS, deprecated: 16, message: "Use `Locale.Components(identifier:)` to access components")
    @available(tvOS, deprecated: 16, message: "Use `Locale.Components(identifier:)` to access components")
    @available(watchOS, deprecated: 9, message: "Use `Locale.Components(identifier:)` to access components")
    public static func components(fromIdentifier string: String) -> [String : String] {
        let comps = CFLocaleCreateComponentsFromLocaleIdentifier(kCFAllocatorSystemDefault, CFLocaleIdentifier(string as CFString))
        if let result = comps as? [String: String] {
            return result
        } else {
            return [:]
        }
    }

    /// Returns a list of available `Locale` region codes.
    @available(macOS, deprecated: 13, message: "Use `Locale.Region.isoRegions` instead")
    @available(iOS, deprecated: 16, message: "Use `Locale.Region.isoRegions` instead")
    @available(tvOS, deprecated: 16, message: "Use `Locale.Region.isoRegions` instead")
    @available(watchOS, deprecated: 9, message: "Use `Locale.Region.isoRegions` instead")
    public static var isoRegionCodes: [String] {
        // This was renamed from Obj-C
        Locale.Region.isoCountries
    }

    /// Returns a list of available `Locale` currency codes.
    @available(macOS, deprecated: 13, message: "Use `Locale.Currency.isoCurrencies` instead")
    @available(iOS, deprecated: 16, message: "Use `Locale.Currency.isoCurrencies` instead")
    @available(tvOS, deprecated: 16, message: "Use `Locale.Currency.isoCurrencies` instead")
    @available(watchOS, deprecated: 9, message: "Use `Locale.Currency.isoCurrencies` instead")
    public static var isoCurrencyCodes: [String] {
        Locale.Currency.isoCurrencies.map { $0.identifier }
    }

    /// Returns the character direction for a specified language code.
    @available(macOS, deprecated: 13, message: "Use `Locale.Language(identifier:).characterDirection`")
    @available(iOS, deprecated: 16, message: "Use `Locale.Language(identifier:).characterDirection`")
    @available(tvOS, deprecated: 16, message: "Use `Locale.Language(identifier:).characterDirection`")
    @available(watchOS, deprecated: 9, message: "Use `Locale.Language(identifier:).characterDirection`")
    public static func characterDirection(forLanguage isoLangCode: String) -> Locale.LanguageDirection {
        let language = Locale.Language(components: .init(identifier: isoLangCode))
        return language.characterDirection
    }

    /// Returns the line direction for a specified language code.
    @available(macOS, deprecated: 13, message: "Use `Locale.Language(identifier:).lineLayoutDirection`")
    @available(iOS, deprecated: 16, message: "Use `Locale.Language(identifier:).lineLayoutDirection`")
    @available(tvOS, deprecated: 16, message: "Use `Locale.Language(identifier:).lineLayoutDirection`")
    @available(watchOS, deprecated: 9, message: "Use `Locale.Language(identifier:).lineLayoutDirection`")
    public static func lineDirection(forLanguage isoLangCode: String) -> Locale.LanguageDirection {
        let language = Locale.Language(components: .init(identifier: isoLangCode))
        return language.lineLayoutDirection
    }

}

#endif
