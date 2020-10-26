import NIO

public extension Entita2Entity {
    /// Defines whether full name for ID should be full or short
    /// Defaults to `false` (hence short)
    static var fullEntityName: Bool {
        false
    }

    @inlinable static var entityName: String {
        let components = String(reflecting: Self.self).components(separatedBy: ".")
        return components[
            (Self.fullEntityName ? 1 : components.count - 1)...
        ].joined(separator: ".")
    }

    static func IDBytesAsKey(bytes: Bytes) -> Bytes {
        getBytes(Self.entityName + ":") + bytes
    }

    static func IDAsKey(ID: Identifier) -> Bytes {
        Self.IDBytesAsKey(bytes: ID._bytes)
    }

    func getIDAsKey() -> Bytes {
        Self.IDAsKey(ID: getID())
    }

    static func loadBy(
        IDBytes: Bytes,
        within transaction: AnyTransaction? = nil,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Self?> {
        Self.loadByRaw(
            IDBytes: Self.IDBytesAsKey(bytes: IDBytes),
            on: eventLoop
        )
    }

    static func loadByRaw(
        IDBytes: Bytes,
        within transaction: AnyTransaction? = nil,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Self?> {
        self.storage
            .load(by: IDBytes, within: transaction, on: eventLoop)
            .flatMap { self.afterLoadRoutines0(maybeBytes: $0, within: transaction, on: eventLoop) }
    }

    static func load(
        by ID: Identifier,
        within transaction: AnyTransaction? = nil,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Self?> {
        Self.loadByRaw(IDBytes: Self.IDAsKey(ID: ID), within: transaction, on: eventLoop)
    }

    static func afterLoadRoutines0(
        maybeBytes: Bytes?,
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Self?> {
        guard let bytes = maybeBytes else {
            return eventLoop.makeSucceededFuture(nil)
        }
        let entity: Self
        do {
            entity = try Self(from: bytes, format: Self.format)
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
        return entity
            .afterLoad0(within: transaction, on: eventLoop)
            .flatMap { entity.afterLoad(within: transaction, on: eventLoop) }
            .map { _ in entity }
    }

    func afterLoad0(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func afterLoad(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func beforeSave0(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func beforeSave(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func afterSave0(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func afterSave(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func beforeInsert0(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func beforeInsert(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func afterInsert(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func afterInsert0(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func beforeDelete0(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func beforeDelete(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func afterDelete0(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    func afterDelete(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        eventLoop.future
    }

    /// Though this method isn't actually asynchronous,
    /// it's deliberately stated as `EventLoopFuture<Bytes>` to get rid of `throws` keyword
    func getPackedSelf(on eventLoop: EventLoop) -> EventLoopFuture<Bytes> {
        return eventLoop.submit {
            let result: Bytes

            do {
                result = try self.pack(to: Self.format)
            } catch {
                throw Entita2.E.SaveError("Could not save entity: \(error)")
            }

            return result
        }
    }

    //MARK: - Public 0-methods
    
    /// This method is not intended to be used directly. Use `save()` method.
    func save0(
        by ID: Identifier? = nil,
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        let IDBytes: Bytes
        if let ID = ID {
            IDBytes = Self.IDAsKey(ID: ID)
        } else {
            IDBytes = self.getIDAsKey()
        }

        return self
            .getPackedSelf(on: eventLoop)
            .flatMap { payload in
                Self.storage.save(
                    bytes: payload,
                    by: IDBytes,
                    within: transaction,
                    on: eventLoop
                )
            }
    }

    /// This method is not intended to be used directly. Use `save()` method.
    func delete0(
        within transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        Self.storage.delete(
            by: self.getIDAsKey(),
            within: transaction,
            on: eventLoop
        )
    }

    /// This method is not intended to be used directly
    func commit0(transaction: AnyTransaction?, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return transaction?.commit() ?? eventLoop.makeSucceededFuture(())
    }

    internal func commit0IfNecessary(
        commit: Bool,
        transaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        commit
            ? self.commit0(transaction: transaction, on: eventLoop)
            : eventLoop.future
    }

    @usableFromInline
    internal static func unwrapAnyTransactionOrBegin(
        _ anyTransaction: AnyTransaction?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<AnyTransaction> {
        eventLoop.future
            .flatMap {
                if let transaction = anyTransaction {
                    return eventLoop.makeSucceededFuture(transaction)
                }
                return Self.storage.begin(on: eventLoop)
            }
    }

    // MARK: - Public CRUD methods

    /// Inserts current entity to DB within given transaction
    func insert(
        within transaction: AnyTransaction? = nil,
        commit: Bool = true,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        Self
            .unwrapAnyTransactionOrBegin(transaction, on: eventLoop)
            .flatMap { tr in
                eventLoop.future
                    .flatMap { self.beforeInsert0(within: tr, on: eventLoop) }
                    .flatMap { self.beforeInsert(within: tr, on: eventLoop) }
                    .flatMap { self.save0(by: nil, within: tr, on: eventLoop) }
                    .flatMap { self.afterInsert0(within: tr, on: eventLoop) }
                    .flatMap { self.afterInsert(within: tr, on: eventLoop) }
                    .flatMap { self.commit0IfNecessary(commit: commit, transaction: tr, on: eventLoop) }
            }
    }

    /// Saves current entity to DB
    func save(
        within transaction: AnyTransaction? = nil,
        commit: Bool = true,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        self.save(by: nil, within: transaction, commit: commit, on: eventLoop)
    }

    /// Saves current entity to DB within given transaction
    func save(
        by ID: Identifier? = nil,
        within transaction: AnyTransaction? = nil,
        commit: Bool = true,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        Self
            .unwrapAnyTransactionOrBegin(transaction, on: eventLoop)
            .flatMap { tr in
                eventLoop.future
                    .flatMap { self.beforeSave0(within: tr, on: eventLoop) }
                    .flatMap { self.beforeSave(within: tr, on: eventLoop) }
                    .flatMap { self.save0(by: ID, within: tr, on: eventLoop) }
                    .flatMap { self.afterSave0(within: tr, on: eventLoop) }
                    .flatMap { self.afterSave(within: tr, on: eventLoop) }
                    .flatMap { self.commit0IfNecessary(commit: commit, transaction: tr, on: eventLoop) }
            }
    }

    /// Deletes current entity from DB within given transaction
    func delete(
        within transaction: AnyTransaction? = nil,
        commit: Bool = true,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        Self
            .unwrapAnyTransactionOrBegin(transaction, on: eventLoop)
            .flatMap { tr in
                eventLoop.future
                    .flatMap { self.beforeDelete0(within: tr, on: eventLoop) }
                    .flatMap { self.beforeDelete(within: tr, on: eventLoop) }
                    .flatMap { self.delete0(within: tr, on: eventLoop) }
                    .flatMap { self.afterDelete0(within: tr, on: eventLoop) }
                    .flatMap { self.afterDelete(within: tr, on: eventLoop) }
                    .flatMap { self.commit0IfNecessary(commit: commit, transaction: tr, on: eventLoop) }
            }
    }
}
