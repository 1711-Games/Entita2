/// A very abstract transaction
public protocol AnyTransaction: Sendable {
    /// Commits current transaction
    func commit() async throws
}
