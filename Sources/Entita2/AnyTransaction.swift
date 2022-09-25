/// A very abstract transaction
public protocol Transaction: Sendable {
    /// Commits current transaction
    func commit() async throws
}
