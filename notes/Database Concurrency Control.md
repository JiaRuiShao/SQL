## Database Concurrency Control

Multi-User databases need to control the order in which data are read and updated by multiple users. Concurrency Control provides a mechanism to ensure that the work of multiple users do not interfere and potentially corrupt the data in the database.

### Concurrency Control and Locking

- We need a way to guarantee that our concurrent transactions can be serialized. Locking is one such means.
- Locking is done to data items in order to reserve them for future operations.
- A lock is a logical flag set by a transaction to alert other transactions the data item is in use.

    Normalization helps us to deduct the time pf waiting the others releasing the locks. (only need to lock a small chunk after split the data, which is normalization)

#### I. Characteristics of Locks

Locks may be applied to data items in two ways:

- __Implicit Locks__ are applied by the DBMS
- __Explicit Locks__ are applied by application programs.

Locks may be applied to:

- a single data item (value)
- an entire row of a table
- a page (memory segment) (many rows worth)
- an entire table
- an entire database

This is referred to as the __Lock granularity__

__Types of Locks__:

- An **Exclusive Lock** prevents any other transaction from reading or modifying the locked item.
- A **Shared Lock** allows another transaction to read an item but prevents another transaction from writing the item.

Shared locks are sometimes called "read locks" and exclusive locks are sometimes called "write locks".

#### II. Two Phase Locking

The most commonly implemented locking mechanism is called __Two Phased Locking__ or __2PL__. 2PL is a concurrency control mechanism that __ensure serializability__.

__2PL has two phases__: Growing and shrinking.

- A transaction acquires locks on data items it will need to complete the transaction. This is called the __growing phase__.
- Once one lock is released, all no other lock may be acquired. This is called the __shrinking phase__.

![Growing and shrinking phase](https://t1.daumcdn.net/thumb/R1280x0/?fname=http://t1.daumcdn.net/brunch/service/user/1dLN/image/0x2bTDZgycjfIy4ONcg0DZ5t_Hs.gif)

[Example_1](http://holowczak.com/database-concurrency-control/)

Note that at time 5, Transaction B is Denied a lock. So Transaction B will “spin” in place until that lock on P200 is released.

[Example_2](http://holowczak.com/database-concurrency-control/2/)

Notice:

The order of releasing the locks doesn't matter, only the amount of released locks matters.

#### III. Deadlock

Locking can cause problems sometimes.

eg:

[Example_3](http://holowczak.com/database-concurrency-control/3/)

One transaction has locked some of the resources and is waiting for locks so it can complete. A second transaction has locked those needed items but is awaiting the release of locks the first transaction is holding so it can continue.

__Two main ways to deal with deadlock__:

- Prevent it in the first place by giving each transaction exclusive rights to acquire all locks needed before proceeding.
- Allow the deadlock to occur, then break it by aborting one of the transactions.