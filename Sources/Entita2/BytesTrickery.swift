// taken from LGNCore

public typealias Byte = UInt8
public typealias Bytes = [Byte]

/// Returns raw underlying byte array from given String
@usableFromInline
internal func getBytes(_ string: String) -> Bytes {
    return Bytes(string.utf8)
}

/// Returns raw underlying byte array from given input
@usableFromInline
internal func getBytes<Input>(_ input: Input) -> Bytes {
    return withUnsafeBytes(of: input) { Bytes($0) }
}

internal extension ArraySlice where Element == Byte {
    /// Performs failable conversion from current byte array to target structure
    ///
    /// Caution! This operation is unsafe by its nature, and should be performed only when you're confident.
    /// It fails only when memory layout size differs from current byte array size, and it's more of a sanity check
    /// rather than safety check. Unpacked structure might be malformed, and you wouldn't know until you use it for the
    /// first time.
    @usableFromInline
    func cast<R>(file: StaticString = #file, line: UInt = #line) throws -> R {
        guard MemoryLayout<R>.size == self.count else {
            throw Entita2.E.CastError(
                """
                Memory layout size for result type '\(R.self)' (\(MemoryLayout<R>.size) bytes) does \
                not match with given byte array length (\(self.count) bytes: \(self)) \
                @ \(file):\(line)
                """
            )
        }
        return self.withUnsafeBytes {
            $0.baseAddress!.assumingMemoryBound(to: R.self).pointee
        }
    }

    /// Performs failable conversion from current byte array to String of given encoding
    @usableFromInline
    func cast(encoding: String.Encoding = .ascii) throws -> String {
        guard let result = String(bytes: self, encoding: encoding) else {
            throw Entita2.E.CastError("Could not cast byte array to ASCII String")
        }
        return result
    }
}

internal extension Array where Element == Byte {
    /// Converts current byte array to an ASCII String
    ///
    /// Caution! This operation is potentially unsafe, you should use it only for debug purposes.
    @usableFromInline
    var _string: String {
        return String(bytes: self, encoding: .ascii)!
    }

    /// Adds `NUL` octet (zero byte) to the end of current byte array
    @usableFromInline
    mutating func addNul() {
        self.append(0)
    }

    @usableFromInline
    var hexString: String {
        self.map { String(format: "%02hhx", $0) }.joined()
    }

    /// Performs failable conversion from current byte array to target structure
    ///
    /// Caution! This operation is unsafe by its nature, and should be performed only when you're confident.
    /// It fails only when memory layout size differs from current byte array size, and it's more of a sanity check
    /// rather than safety check. Unpacked structure might be malformed, and you wouldn't know until you use it for the
    /// first time.
    @usableFromInline
    func cast<R>(file: StaticString = #file, line: UInt = #line) throws -> R {
        guard MemoryLayout<R>.size == self.count else {
            throw Entita2.E.CastError(
                """
                Memory layout size for result type '\(R.self)' (\(MemoryLayout<R>.size) bytes) does \
                not match with given byte array length (\(self.count) bytes: \(self)) \
                @ \(file):\(line)
                """
            )
        }
        return self.withUnsafeBytes {
            $0.baseAddress!.assumingMemoryBound(to: R.self).pointee
        }
    }

    /// Performs failable conversion from current byte array to String of given encoding
    @usableFromInline
    func cast(encoding: String.Encoding = .ascii) throws -> String {
        guard let result = String(bytes: self, encoding: encoding) else {
            throw Entita2.E.CastError("Could not cast byte array to ASCII String")
        }
        return result
    }

    /// Appends a byte array to the end of current byte array
    @usableFromInline
    mutating func append(_ bytes: Bytes) {
        self.append(contentsOf: bytes)
    }

    /// Appends a byte array to the beginning of current byte array
    @usableFromInline
    mutating func prepend(_ bytes: Bytes) {
        self.insert(contentsOf: bytes, at: 0)
    }
}

