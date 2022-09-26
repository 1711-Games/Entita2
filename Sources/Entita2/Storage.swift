public typealias E2Storage = Entita2Storage

public protocol Entita2Storage {
    /// Begins a transaction if `Storage` is transactional
    func begin() async throws -> any Entita2Transaction

    /// Tries to load bytes from storage for given key within a transaction
    func load(by key: Bytes, within transaction: (any Entita2Transaction)?) async throws -> Bytes?

    /// Saves given bytes at given key within a transaction
    func save(bytes: Bytes, by key: Bytes, within transaction: (any Entita2Transaction)?) async throws

    /// Deletes a given key (and value) from storage within a transaction
    func delete(by key: Bytes, within transaction: (any Entita2Transaction)?) async throws
}
