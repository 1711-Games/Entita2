# Entita2

Entita2 is a simple Swift-NIO-powered ORM for working with NoSQL DBs. This particular package contains basic abstractions
(without any particular DB connections). Currently the only concrete DB implementation is
[Entita2FDB](https://github.com/1711-Games/Entita2FDB) which works with
FoundationDB (a highly distributed transactional NoSQL DB by Apple).

## Entity definition

```swift
import struct Foundation.Date
import Entita2

let storage: SomeStorage = someStorageReference

final class User: E2Entity {
    public typealias Identifier = E2.UUID

    public static var format: E2.Format = .JSON
    public static var IDKey: KeyPath<User, E2.UUID> = \.ID
    public static var storage: some Entita2Storage = storage

    public let ID: E2.UUID

    public var username: String
    public var password: String
    public var email: String
    public var dateSignup: Date
    public var dateLogin: Date?

    public init(
        username: String,
        password: String,
        email: String,
        dateSignup: Date = Date(),
        dateLogin: Date? = nil
    ) {
        self.ID = .init()
        self.username = username
        self.password = password
        self.email = email
        self.dateSignup = dateSignup
        self.dateLogin = dateLogin
    }
}
```

NB: Every `Entita2`-prefixed definition has a `E2`-prefixed typealias: `Entita2` >> `E2`, `Entita2Entity` >> `E2Entity` etc.

This snippet defines an entity `User` with an UUID identifier (identifiers can be anything, including `Int`, of course) and a few more 
properties. Under the hood Entita2 utilizes `Codable` protocol, so every property must conform to it. The entity is packed using JSON
format (other option is MessagePack). ID property can be named anything, and therefore a KeyPath should be provided to this property.

## CRUD

Loading a record from DB:
```swift
let maybeUserFuture: EventLoopFuture<User?> = User.load(
    by: E2.UUID("9C0FDD1C-FE56-4598-A037-177362DBD3D2")!,
    on: eventLoop
)
```

Creating a new record:
```swift
let newUser = User(
    username: "17:11 Teo",
    password: "706c656173652073656e642068656c70".hashedOfCourse,
    email: "teo@1711.games",
    dateSignup: Date()
)
let insertFuture: EventLoopFuture<Void> = newUser.insert(
    storage: storageInstance,
    on: eventLoop
)
```

Updating existing record
```swift
user.dateLogin = Date()

let saveFuture: EventLoopFuture<Void> = user.save(on: eventLoop)
```

 Deleting a record:
 ```swift
 let deleteFuture: EventLoopFuture<Void> = user.delete(on: eventLoop)
 ```

## Pre/after operation hooks

If you want to perform some actions before or after any CRUD operation, you may define a method
of a following signature in your entity:

```swift
func afterLoad(
    within transaction: AnyTransaction?,
    on eventLoop: EventLoop
) -> EventLoopFuture<Void>
```

There are seven methods of such kind (including `afterLoad`, but not `beforeLoad`, because it's nonsense):

```swift
beforeInsert
afterInsert

beforeSave
afterSave

beforeDelete
afterDelete
```

You may define any of theese methods, but you should not execute them manualy.

Additionally, there are siblings of these methods with `0` suffix (`beforeInsert0` etc), which are for Entita2 extensions like
[Entita2FDB](https://github.com/1711-Games/Entita2FDB), you should not define (nor execute) them in your entities.

Order of execution of these methods is as follows:

```swift
beforeInsert0
beforeInsert
save0 // actual IO operation
afterInsert0
afterInsert
```

Almost all CRUD methods also have `0`-suffix siblings: `insert0`, `save0`, `delete0` which schedule IO operations
and communicate with storage. Those methods should not be defined or executed directly, unless you work on
a new DB implementation, and there is no other way.

## Storage

If you want to use Entita2 with your custom storage, your storage class have to adopt `Entita2Storage` protocol.
It requires four methods:

```swift
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
```

`AnyTransaction` is a protocol for a transaction, it has to have just one method:

```swift
func commit() -> EventLoopFuture<Void>
```

If your DB is not transactional, create a dummy `commit` method to just return `EventLoopFuture<Void>`.

## Transactions

If your DB is transactional, you might want to utilize transactions. First you create a transaction with `storage.begin()`,
then you pass it to every CRUD method (otherwise transaction will be started automatically for any CRUD operation). The rest is up to DB.

## FAQ

### Entita2? Where is Entita1 then?

There is indeed a package called [Entita](https://github.com/1711-Games/LGNC-Swift/tree/master/Sources/Entita)
(without a number) with similar functionality which is heavily used in LGNC engine.
However, it's quite low-level and is probably not of much use for broad public. 

### Why is `Storage` injected into static class instead of passing to individual dynamic CRUD methods?

We have considered this [Fluent-inspired] approach, but upon thorough production testing we decided that it is too cumbersome.
We understand that community prefers more safe approach with dependency container being passed
(like `request` in Vapor) to each request, but we weren't aiming for a specific framework while developing this ORM
(actually we _were_ at some point, but we've committed some serious efforts to make it framework-agnostic).
