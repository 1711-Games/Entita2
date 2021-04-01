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

    static func loadBy(IDBytes: Bytes, within transaction: AnyTransaction? = nil) async throws -> Self? {
        try await Self.loadByRaw(
            IDBytes: Self.IDBytesAsKey(bytes: IDBytes)
        )
    }

    static func loadByRaw(IDBytes: Bytes, within transaction: AnyTransaction? = nil) async throws -> Self? {
        return try await self.afterLoadRoutines0(
            maybeBytes: try await self.storage.load(by: IDBytes, within: transaction),
            within: transaction
        )
    }

    static func load(by ID: Identifier, within transaction: AnyTransaction? = nil) async throws -> Self? {
        try await Self.loadByRaw(IDBytes: Self.IDAsKey(ID: ID), within: transaction)
    }

    static func afterLoadRoutines0(maybeBytes: Bytes?, within transaction: AnyTransaction?) async throws -> Self? {
        guard let bytes = maybeBytes else {
            return nil
        }

        let entity: Self = try Self(from: bytes, format: Self.format)

        try await entity.afterLoad0(within: transaction)
        try await entity.afterLoad(within: transaction)

        return entity
    }

    func afterLoad0(within transaction: AnyTransaction?) async throws {}
    func afterLoad(within transaction: AnyTransaction?) async throws {}
    func beforeSave0(within transaction: AnyTransaction?) async throws {}
    func beforeSave(within transaction: AnyTransaction?) async throws {}
    func afterSave0(within transaction: AnyTransaction?) async throws {}
    func afterSave(within transaction: AnyTransaction?) async throws {}
    func beforeInsert0(within transaction: AnyTransaction?) async throws {}
    func beforeInsert(within transaction: AnyTransaction?) async throws {}
    func afterInsert(within transaction: AnyTransaction?) async throws {}
    func afterInsert0(within transaction: AnyTransaction?) async throws {}
    func beforeDelete0(within transaction: AnyTransaction?) async throws {}
    func beforeDelete(within transaction: AnyTransaction?) async throws {}
    func afterDelete0(within transaction: AnyTransaction?) async throws {}
    func afterDelete(within transaction: AnyTransaction?) async throws {}

    func getPackedSelf() throws -> Bytes {
        let result: Bytes

        do {
            result = try self.pack(to: Self.format)
        } catch {
            throw Entita2.E.SaveError("Could not save entity: \(error)")
        }

        return result
    }

    //MARK: - Public 0-methods
    
    /// This method is not intended to be used directly. Use `save()` method.
    func save0(by ID: Identifier? = nil, within transaction: AnyTransaction?) async throws {
        let IDBytes: Bytes
        if let ID = ID {
            IDBytes = Self.IDAsKey(ID: ID)
        } else {
            IDBytes = self.getIDAsKey()
        }

        return try await Self.storage.save(
            bytes: self.getPackedSelf(),
            by: IDBytes,
            within: transaction
        )
    }

    /// This method is not intended to be used directly. Use `save()` method.
    func delete0(within transaction: AnyTransaction?) async throws {
        try await Self.storage.delete(
            by: self.getIDAsKey(),
            within: transaction
        )
    }

    /// This method is not intended to be used directly
    func commit0(transaction: AnyTransaction?) async throws {
        try await transaction?.commit()
    }

    internal func commit0IfNecessary(commit: Bool, transaction: AnyTransaction?) async throws {
        if commit  {
            try await self.commit0(transaction: transaction)
        }
    }

    @usableFromInline
    internal static func unwrapAnyTransactionOrBegin(_ anyTransaction: AnyTransaction?) async throws -> AnyTransaction {
        if let transaction = anyTransaction {
            return transaction
        }
        return try await Self.storage.begin()
    }

    // MARK: - Public CRUD methods

    /// Inserts current entity to DB within given transaction
    func insert(within transaction: AnyTransaction? = nil, commit: Bool = true) async throws {
        let transaction = try await Self.unwrapAnyTransactionOrBegin(transaction)
        
        try await self.beforeInsert0(within: transaction)
        try await self.beforeInsert(within: transaction)
        try await self.save0(by: nil, within: transaction)
        try await self.afterInsert0(within: transaction)
        try await self.afterInsert(within: transaction)
        try await self.commit0IfNecessary(commit: commit, transaction: transaction)
    }

    /// Saves current entity to DB
    func save(within transaction: AnyTransaction? = nil, commit: Bool = true) async throws {
        try await self.save(by: nil, within: transaction, commit: commit)
    }

    /// Saves current entity to DB within given transaction
    func save(by ID: Identifier? = nil, within transaction: AnyTransaction? = nil, commit: Bool = true) async throws {
        let transaction = try await Self.unwrapAnyTransactionOrBegin(transaction)

        try await self.beforeSave0(within: transaction)
        try await self.beforeSave(within: transaction)
        try await self.save0(by: ID, within: transaction)
        try await self.afterSave0(within: transaction)
        try await self.afterSave(within: transaction)
        try await self.commit0IfNecessary(commit: commit, transaction: transaction)
    }

    /// Deletes current entity from DB within given transaction
    func delete(within transaction: AnyTransaction? = nil, commit: Bool = true) async throws {
        let transaction = try await Self.unwrapAnyTransactionOrBegin(transaction)

        try await self.beforeDelete0(within: transaction)
        try await self.beforeDelete(within: transaction)
        try await self.delete0(within: transaction)
        try await self.afterDelete0(within: transaction)
        try await self.afterDelete(within: transaction)
        try await self.commit0IfNecessary(commit: commit, transaction: transaction)
    }
}
