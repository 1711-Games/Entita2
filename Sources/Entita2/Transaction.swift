/// A very abstract transaction
public protocol Entita2Transaction: Sendable {
    /// Commits current transaction
    func commit() async throws
}
