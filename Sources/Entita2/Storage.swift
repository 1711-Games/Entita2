import NIO

public typealias E2Storage = Entita2Storage

public protocol Entita2Storage {
    /// Begins a transaction if `Storage` is transactional
    func begin(on eventLoop: EventLoop) -> EventLoopFuture<AnyTransaction>

    /// Tries to load bytes from storage for given key within a transaction
    func load(
        by key: Bytes,
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Bytes?>

    /// Saves given bytes at given key within a transaction
    func save(
        bytes: Bytes,
        by key: Bytes,
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void>

    /// Deletes a given key (and value) from storage within a transaction
    func delete(
        by key: Bytes,
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void>
}
