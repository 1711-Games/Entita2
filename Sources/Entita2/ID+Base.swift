/// A protocol for anything that identifies something and can be represented as bytes
public protocol Identifiable: Hashable {
    var _bytes: Bytes { get }
}

public extension Entita2 {
    struct ID<Value: Codable & Hashable>: Identifiable {
        public let value: Value

        @inlinable public var _bytes: Bytes {
            getBytes(value)
        }

        public init(value: Value) {
            self.value = value
        }
    }
}

extension Entita2.ID: Equatable {}
