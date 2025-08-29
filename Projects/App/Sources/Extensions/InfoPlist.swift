import Foundation

@propertyWrapper
struct InfoPlist<Value> {
	private let key: String
	private let keyPath: [String]?
	private let bundle: Bundle
	private let defaultValue: Value

	var wrappedValue: Value {
		if let keyPath {
			return InfoPlist.value(for: keyPath, in: bundle) ?? defaultValue
		} else {
			return (bundle.object(forInfoDictionaryKey: key) as? Value) ?? defaultValue
		}
	}

	init(_ key: String, bundle: Bundle = .main, default defaultValue: Value) {
		self.key = key
		self.keyPath = nil
		self.bundle = bundle
		self.defaultValue = defaultValue
	}

	init(_ keyPath: [String], bundle: Bundle = .main, default defaultValue: Value) {
		self.key = keyPath.first ?? ""
		self.keyPath = keyPath
		self.bundle = bundle
		self.defaultValue = defaultValue
	}

	private static func value(for keyPath: [String], in bundle: Bundle) -> Value? {
		var current: Any? = bundle.infoDictionary
		for key in keyPath {
			if let dict = current as? [String: Any] {
				current = dict[key]
			} else {
				return nil
			}
		}
		return current as? Value
	}
}

extension InfoPlist where Value: ExpressibleByNilLiteral {
	init(_ key: String, bundle: Bundle = .main) {
		self.init(key, bundle: bundle, default: nil)
	}

	init(_ keyPath: [String], bundle: Bundle = .main) {
		self.init(keyPath, bundle: bundle, default: nil)
	}
}


