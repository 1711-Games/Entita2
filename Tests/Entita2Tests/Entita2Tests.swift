@testable import Entita2
import Foundation
import MessagePack
import XCTest

final class Entita2Tests: XCTestCase {
    static let storage = DummyStorage()

    struct DummyStorage: E2Storage {
        struct DummyTransaction: Entita2Transaction {
            func commit() async throws {
                // noop
            }
        }

        func begin() throws -> any Entita2Transaction {
            DummyTransaction()
        }

        func load(by key: Bytes, within _: (any Entita2Transaction)?) async throws -> Bytes? {
            let result: Bytes?

            switch key {
            case TestEntity.sampleEntity.getIDAsKey(): // TestEntity
                result = getBytes("""
                    {
                        "string": "foo",
                        "ints": [322, 1337],
                        "subEntity": {
                            "myValue": "sikes",
                            "customID": 1337
                        },
                        "mapOfBooleans": {
                            "kek": false,
                            "lul": true
                        },
                        "bool": true,
                        "float": 322.1337,
                        "ID": "NHtKl8JnQj+oR4gCRvxpcg=="
                    }
                """)
            case TestEntity.sampleEntity.subEntity.getIDAsKey(): // TestEntity.SubEntity
                result = getBytes("""
                    {
                        "myValue": "sikes",
                        "customID": 1337
                    }
                """)
            case [0]: // invalid
                result = [1, 3, 3, 7, 3, 2, 2]
            default:
                result = nil
            }

            return result
        }

        func save(
            bytes _: Bytes,
            by _: Bytes,
            within _: (any Entita2Transaction)?
        ) async throws {
            // noop
        }

        func delete(
            by _: Bytes,
            within _: (any Entita2Transaction)?
        ) async throws {
            // noop
        }
    }

    final class TestEntity: E2Entity, Equatable {
        struct SubEntity: E2Entity, Equatable {
            typealias Identifier = Int

            static var storage: any Entita2Storage = Entita2Tests.storage
            static var fullEntityName: Bool = false
            static var format: E2.Format = .JSON
            static var IDKey: KeyPath<SubEntity, Identifier> = \.customID
            static var sampleEntity: Self {
                Self(customID: 1337, myValue: "sikes")
            }

            var customID: Identifier
            var myValue: String
        }

        enum CodingKeys: String, CodingKey {
            case ID
            case string
            case ints
            case mapOfBooleans
            case float
            case bool
            case subEntity
        }

        typealias Identifier = E2.UUID

        static var storage: any Entita2Storage = Entita2Tests.storage
        static var format: E2.Format = .JSON
        static var IDKey: KeyPath<TestEntity, Identifier> = \.ID
        static var sampleEntity: TestEntity {
            TestEntity(
                ID: E2.UUID("347b4a97-c267-423f-a847-880246fc6972")!,
                string: "foo",
                ints: [322, 1337],
                mapOfBooleans: ["lul": true, "kek": false],
                float: 322.1337,
                bool: true,
                subEntity: SubEntity.sampleEntity
            )
        }

        static func == (lhs: Entita2Tests.TestEntity, rhs: Entita2Tests.TestEntity) -> Bool {
            true
                && lhs.ID == rhs.ID
                && lhs.string == rhs.string
                && lhs.ints == rhs.ints
                && lhs.mapOfBooleans == rhs.mapOfBooleans
                && lhs.float == rhs.float
                && lhs.bool == rhs.bool
                && lhs.subEntity == rhs.subEntity
        }

        var didCallAfterLoad0: Bool = false
        var didCallAfterLoad: Bool = false
        var didCallBeforeSave0: Bool = false
        var didCallBeforeSave: Bool = false
        var didCallAfterSave0: Bool = false
        var didCallAfterSave: Bool = false
        var didCallBeforeInsert0: Bool = false
        var didCallBeforeInsert: Bool = false
        var didCallAfterInsert: Bool = false
        var didCallAfterInsert0: Bool = false
        var didCallBeforeDelete0: Bool = false
        var didCallBeforeDelete: Bool = false
        var didCallAfterDelete0: Bool = false
        var didCallAfterDelete: Bool = false

        public func afterLoad0(
            within _: (any Entita2Transaction)?
        ) async throws {
            didCallAfterLoad0 = true
        }

        public func afterLoad(within _: (any Entita2Transaction)?) async throws {
            didCallAfterLoad = true
        }

        func beforeSave0(within _: (any Entita2Transaction)?) async throws {
            didCallBeforeSave0 = true
        }

        func beforeSave(within _: (any Entita2Transaction)?) async throws {
            didCallBeforeSave = true
        }

        func afterSave0(within _: (any Entita2Transaction)?) async throws {
            didCallAfterSave0 = true
        }

        func afterSave(within _: (any Entita2Transaction)?) async throws {
            didCallAfterSave = true
        }

        func beforeInsert0(within _: (any Entita2Transaction)?) async throws {
            didCallBeforeInsert0 = true
        }

        func beforeInsert(within _: (any Entita2Transaction)?) async throws {
            didCallBeforeInsert = true
        }

        func afterInsert(within _: (any Entita2Transaction)?) async throws {
            didCallAfterInsert = true
        }

        func afterInsert0(within _: (any Entita2Transaction)?) async throws {
            didCallAfterInsert0 = true
        }

        func beforeDelete0(within _: (any Entita2Transaction)?) async throws {
            didCallBeforeDelete0 = true
        }

        func beforeDelete(within _: (any Entita2Transaction)?) async throws {
            didCallBeforeDelete = true
        }

        func afterDelete0(within _: (any Entita2Transaction)?) async throws {
            didCallAfterDelete0 = true
        }

        func afterDelete(within _: (any Entita2Transaction)?) async throws {
            didCallAfterDelete = true
        }

        var ID: Identifier
        var string: String
        var ints: [Int]
        var mapOfBooleans: [String: Bool]
        var float: Float
        var bool: Bool
        var subEntity: SubEntity

        init(
            ID: Identifier,
            string: String,
            ints: [Int],
            mapOfBooleans: [String: Bool],
            float: Float,
            bool: Bool,
            subEntity: SubEntity
        ) {
            self.ID = ID
            self.string = string
            self.ints = ints
            self.mapOfBooleans = mapOfBooleans
            self.float = float
            self.bool = bool
            self.subEntity = subEntity
        }
    }

    struct InvalidPackEntity: E2Entity {
        typealias Identifier = Int

        static var storage: any Entita2Storage = Entita2Tests.storage
        static var fullEntityName: Bool = false
        static var format: E2.Format = .JSON
        static var IDKey: KeyPath<InvalidPackEntity, Identifier> = \.ID

        var ID: Identifier

        func pack(to _: E2.Format = Self.format) throws -> Bytes {
            throw EncodingError.invalidValue(
                "test",
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "error"
                )
            )
        }
    }

    func testFormats() throws {
        let sampleEntity = TestEntity.sampleEntity

        for format in E2.Format.allCases {
            XCTAssertEqual(
                try TestEntity(from: sampleEntity.pack(to: format), format: format),
                sampleEntity
            )
        }
    }

    func testGetID() {
        let sampleEntity = TestEntity.sampleEntity
        let sampleSubEntity = sampleEntity.subEntity
        XCTAssertEqual(sampleEntity.getID(), sampleEntity.ID)
        XCTAssertEqual(sampleSubEntity.getID(), sampleSubEntity.customID)
    }

    func testIDBytes() {
        let sampleEntity = TestEntity.sampleEntity

        let sampleIDBytes = getBytes(sampleEntity.ID)
        let sampleCustomIDBytes = getBytes(sampleEntity.subEntity.customID)
        XCTAssertEqual(sampleEntity.ID._bytes, sampleIDBytes)
        XCTAssertEqual(sampleEntity.subEntity.customID._bytes, sampleCustomIDBytes)

        let prefix = getBytes("TestEntity:")
        XCTAssertEqual(TestEntity.IDBytesAsKey(bytes: [1, 2, 3]), prefix + [1, 2, 3])
        XCTAssertEqual(TestEntity.IDAsKey(ID: sampleEntity.ID), prefix + sampleIDBytes)
        XCTAssertEqual(sampleEntity.getIDAsKey(), prefix + sampleIDBytes)
    }

    func testUUIDID() {
        let sampleEntity = TestEntity.sampleEntity
        XCTAssertEqual(sampleEntity.ID.string, sampleEntity.ID.value.uuidString)

        XCTAssertEqual(E2.UUID("invalid"), nil)
        XCTAssertEqual(E2.UUID("53D29EF7-377C-4D14-864B-EB3A85769359"), E2.UUID("53D29EF7-377C-4D14-864B-EB3A85769359"))
    }

    func testEntityName() {
        XCTAssertEqual(TestEntity.entityName, "TestEntity")
        XCTAssertEqual(TestEntity.SubEntity.entityName, "SubEntity")
        TestEntity.SubEntity.fullEntityName = true
        XCTAssertEqual(TestEntity.SubEntity.entityName, "Entita2Tests.TestEntity.SubEntity")
        TestEntity.SubEntity.fullEntityName = false
    }

    func testGetPackedSelf() throws {
        _ = try TestEntity.sampleEntity.getPackedSelf()

        do {
            _ = try InvalidPackEntity(ID: 1).getPackedSelf()
            XCTFail("Should've thrown")
        } catch {}
    }

    func testLoad() async throws {
        let sampleEntity = TestEntity.sampleEntity

        let loaded = try await TestEntity.loadByRaw(IDBytes: sampleEntity.getIDAsKey())

        XCTAssertEqual(loaded, sampleEntity)

        XCTAssertTrue(loaded!.didCallAfterLoad)
        XCTAssertTrue(loaded!.didCallAfterLoad0)

        let actual1 = try await TestEntity.loadBy(IDBytes: sampleEntity.ID._bytes)
        XCTAssertEqual(actual1, sampleEntity)

        let actual2 = try await TestEntity.load(by: sampleEntity.ID)
        XCTAssertEqual(actual2, sampleEntity)

        let actual3 = try await TestEntity.loadByRaw(IDBytes: [1, 2, 3])
        XCTAssertEqual(actual3, nil)

        do {
            _ = try await TestEntity.loadByRaw(IDBytes: [0])
            XCTFail("Should've thrown")
        } catch {}

        TestEntity.format = .MsgPack
        do {
            _ = try await TestEntity.loadByRaw(IDBytes: [0])
            XCTFail("Should've thrown")
        } catch {}

        TestEntity.format = .JSON
        let loadedSubEntity = try await TestEntity.SubEntity.loadByRaw(IDBytes: sampleEntity.subEntity.getIDAsKey())
        XCTAssertEqual(loadedSubEntity, sampleEntity.subEntity)
    }

    func testSave() async throws {
        let sampleEntity = TestEntity.sampleEntity
        let sampleSubEntity = TestEntity.sampleEntity.subEntity

        try await sampleEntity.save(commit: true)
        try await sampleSubEntity.save(commit: true)
        try await sampleEntity.save(by: sampleEntity.ID, commit: true)

        XCTAssertTrue(sampleEntity.didCallBeforeSave0)
        XCTAssertTrue(sampleEntity.didCallBeforeSave)
        XCTAssertTrue(sampleEntity.didCallAfterSave)
        XCTAssertTrue(sampleEntity.didCallAfterSave0)
    }

    func testInsert() async throws {
        let sampleEntity = TestEntity.sampleEntity
        let sampleSubEntity = TestEntity.sampleEntity.subEntity

        try await sampleEntity.insert(commit: true)
        try await sampleSubEntity.insert()

        let transaction = try Self.storage.begin()
        try await sampleEntity.insert(within: transaction, commit: true)

        XCTAssertTrue(sampleEntity.didCallBeforeInsert0)
        XCTAssertTrue(sampleEntity.didCallBeforeInsert)
        XCTAssertTrue(sampleEntity.didCallAfterInsert)
        XCTAssertTrue(sampleEntity.didCallAfterInsert0)
    }

    func testDelete() async throws {
        let sampleEntity = TestEntity.sampleEntity
        let sampleSubEntity = TestEntity.sampleEntity.subEntity

        try await sampleEntity.delete(commit: true)
        try await sampleSubEntity.delete(commit: false)

        XCTAssertTrue(sampleEntity.didCallBeforeDelete0)
        XCTAssertTrue(sampleEntity.didCallBeforeDelete)
        XCTAssertTrue(sampleEntity.didCallAfterDelete)
        XCTAssertTrue(sampleEntity.didCallAfterDelete0)
    }
}
