import Foundation
import MessagePack

public extension Entita2Entity {
    init(from bytes: Bytes, format: Entita2.Format = Self.format) throws {
        let result: Self
        switch format {
        case .JSON: result = try JSONDecoder().decode(Self.self, from: Data(bytes))
        case .MsgPack: result = try MessagePackDecoder().decode(Self.self, from: Data(bytes))
        }
        self = result
    }

    func pack(to format: Entita2.Format = Self.format) throws -> Bytes {
        let result: Bytes
        switch format {
        case .JSON: result = try Bytes(JSONEncoder().encode(self))
        case .MsgPack: result = try Bytes(MessagePackEncoder().encode(self))
        }
        return result
    }
}
