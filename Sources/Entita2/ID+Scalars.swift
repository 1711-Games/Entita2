public extension Identifiable {
    var _bytes: Bytes {
        getBytes(self)
    }
}

extension Int: Identifiable {}
extension String: Identifiable {}
