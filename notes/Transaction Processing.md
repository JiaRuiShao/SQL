## Transaction Processing

__MultiUser Databases__

Multi-user database – more than one user processes the database at the same time

__Several general issues arise__:

- How can we prevent users from interfering with each other’s work?
- How can we safely process transactions on the database without corrupting or losing data?
- If there is a problem (e.g., power failure or system crash), how can we recover without losing all of our data?


__Transaction Processing__

Multi-User databases need to control the order in which data are read and updated by multiple users. Transaction Processing presents the basic ideas of transactions, some problems encountered when running multiple transactions  at the same time, and the notion of a transaction schedule assembled by the DBMS.

Transactions can either reach a commit point, where all actions are permanently saved in the database or they can abort in which case none of the actions are saved.


__ACID Properties of Transactions__

**A**tomic – A transaction is an indivisible unit of work that either commits or aborts.
**C**onsistency Preserving – A transaction will take the database from one consistent state to another consistent state.
**I**solated – The work a transaction does should not be known to other transactions until it commits.
**D**urable – One a transaction commits, its work can not be lost even to a future failure.

__Transactions__: Set of read and write operations taht either commits or aborts.

TA: Read X, Read Y, Write Z
TB: Read V, Write W

TC: Read J, Read K, Write L
TD: Read L, write M
TE: Read N, Write L

// The order matters

__Four General classes of problems with Transaction Processing__

1. The Lost Update Problem
2. The Dirty Read Problem (also called uncommitted dependency)
3. The Incorrect Analysis Problem
4. The Non-Repeatable Read Problem

#### 1. The Lost Update Problem

[Example](http://holowczak.com/database-transaction-processing/3/)

Time  Operation                  TA          TB          Value of P200
1     Begin Transaction TA     Begin                      10 
2     Begin Transaction TB                  Begin         10
3     TA Read inventory P200   Read(P200)                 10
4     TB Read inventory P200                Read(P200)    10
5     TA Decrement inventory   P200=P200-2                10
6     TB Decrement inventory                P200=P200-3   10
7     TA Write inventory       Write(P200)                 8 (dirty)
8     TB Write inventory                    Write(P200)    7 (dirty)
9     TA Commit                Commit                      7 (dirty)
10    TB Commit                             Commit         7 (clean)

This is called the Lost Update problem because we lost the update from TA – it was overwritten by T2.

#### 2. The Dirty Read Problem

Here is another example.

Time  Operation                TA           TB            Value of P200
1     Begin Transaction TA     Begin                      10 
2     TA Read inventory P200   Read(P200)                 10
3     TA Decrement inventory   P200=P200-2                10
4     TA Write inventory       Write(P200)                 8 (dirty)
5     Begin Transaction TB                  Begin          8
6     TB Read inventory P200                Read(P200)     8
7     TA Aborts/Rollback       Abort                      10 (clean)
8     TB Decrement inventory                P200=P200-3   10
9     TB Write inventory                    Write(P200)    5 (dirty)
10    TB Commit                             Commit         5 (clean)

The reason we get the wrong final result is because TA had not committed before TB was allowed to read a value TA had written. This is called the uncommitted dependency or Dirty read problem.

#### 3. The Incorrect Analysis Problem

Now consider a transaction trying to find a SUM of all units in inventory while another transaction is trying to update inventory (d) means dirty and (c) means clean.

Time Operation               Sum  TA           TB           P200 P300 P400  
1    Begin Transaction TA    0    Begin                     10   15   20
2    TA Read inventory P200  0    Read(P200)                10   15   20
3    TA Sum up inventory     10   Sum=Sum+P200              10   15   20
4    TA Read inventory P300  10   Read(P300)                10   15   20
5    TA Sum up inventory     25   Sum=Sum+P300              10   15   20
6    Begin Transaction TB    25                Begin        10   15   20
7    TB Read inventory P200  25                Read(P200)   10   15   20
8    TB Decrement inventory  25                P200=P200-3  10   15   20
9    TB Write inventory      25                Write(P200)  7(d) 15   20
10   TA Read inventory P400  25   Read(P400)                7(d) 15   20
11   TA Sum up inventory     45   Sum=Sum+P400              7(d) 15   20
12   TB Commit               45                Commit       7(c) 15   20
13   TA Commit               45   Commit                    7(c) 15   20

The final sum is not correct. This happened because TB was allowed to write a data item that TA was trying to use in its work. This is called the incorrect analysis problem.

#### 4. The Non-Repeatable Read Problem

Suppose we have a transaction that says if P300 is greater than P200 then decrement P300. At the same time another transaction is trying to update P300 ( The (c) means clean and (d) means dirty ).

Time  Operation                TA              TB            P200    P300
1     Begin Transaction TA     Begin                         10      15
2     TA Read inventory P200   Read(P200)=10                 10      15
3     TA Read inventory P300   Read(P300)=15                 10      15
4     TB Begin Transaction                     Begin         10      15
5     TB Read inventory P300                   Read(P300)    10      15
6     TB Decrement inventory                   P300=P300-10  10      15
7     TB Write inventory                       Write(P300)   10       5 (d)
8     TB Commit                                Commit        10       5 (c)
9     TA P300 > P200 so update                               10       5 (c)
10    TA Read inventory P300   Read(P300)=5                  10       5
11    TA Decrement inventory   P300=P300-5                   10       5
12    TA Write inventory       Write(P300)                   10       0 (d)
13    TA Commit                Commit                        10       0 (c)

The two read operations that TA performs at time 3 and time 10 get different results.
This is called the non-repeatable read problem (or fuzzy read problem).

### Serial Schedules and Serializability

If we insist only one transaction can execute at a time, in serial order, then performance will be quite poor.

Transaction throughput: The number of transactions we can perform in a given time period. Often reported as Transactions per second or TPS.

A group of two or more concurrent transactions are serializable if we can order their operations so that the final result is the same as if we had run them in serial order (one after another).

Concurrency Control is a method for controlling or scheduling the operations in such a way that concurrent transactions can be executed.

If we do concurrency control properly, then we can maximize transaction throughput while avoiding any problems.

__2 functions of Concurrency Control__

>> proceed
>> stop

Concurrency Control provides a mechanism to ensure that the work of multiple users do not interfere and potentially corrupt the data in the database.

__Characteristics of Locks__

Locks may be applied to:
1. a single data item (value)
2. an entire row of a table
3. a page (memory segment) (many rows worth)
4. an entire table
5. an entire database
This is referred to as the Lock granularity

__Types of Locks__:

- An Exclusive Lock prevents any other transaction from reading or modifying the locked item(XL).
- A Shared Lock allows another transaction to read an item but prevents another transaction from writing the item(SL).

__Two Phase Locking__:

The most commonly implemented locking mechanism is called Two Phased Locking or 2PL. 2PL is a concurrency control mechanism that ensure serializability.

__2PL has two phases: Growing and shrinking__.

1. A transaction acquires locks on data items it will need to complete the transaction. This is called the growing phase.
2. Once one lock is released, all no other lock may be acquired. This is called the shrinking phase.

Consider our prior example, this time using locks:

Time Operation               TA             TB            P200 
1    Begin Transaction TA    Begin                        10 
2    Begin Transaction TB                   Begin         10 
3    TA Excl. Lock P200      XL(P200)                     10 
4    TA Read inventory P200  Read(P200)                   10 
5    TB Excl. Lock P200                     Denied (wait) 10 
6    TA Decrement inventory   P200=P200-2   (wait)        10 
7    TA Write inventory       Write(P200)   (wait)         8 (dirty) 
8    TA Release Lock P200     Release(P200) (wait)         8 (dirty) 
9    TA Commit                Commit        (wait)         8 (clean) 
10   TB Excl. Lock P200                     XL(P200)       8 
11   TB Read inventory P200                 Read(P200)     8 
12   TB Decrement inventory                 P200=P200-3    8 
13   TB Write inventory                     Write(P200)    5 (dirty) 
14   TB Release Lock P200                   Release(P200)  5 (dirty) 
15   TB Commit                              Commit         5 (clean) 

Note that at time 5, Transaction B is Denied a lock. So Transaction B will “spin” in place until that lock on P200 is released.

Time Operation             TA             TB           TC            R_R  Amy  Bill Carl
1    Begin Transaction TA  Begin                                     .05   45   38    51
2    Begin Transaction TB                 Begin                      .05   45   38    51
3    Begin Transaction TC                              Begin         .05   45   38    51
4    TA Shared Lock R_R    SL(R_R)                                   .05   45   38    51
5    TA Read R_R           Read(R_R)                                 .05   45   38    51
6    TB Shared Lock R_R                   SL(R_R)                    .05   45   38    51
7    TC Excl. Lock R_R                                  (wait)       .05   45   38    51
8    TA Excl. Lock Amy     XL(Amy)                      (wait)       .05   45   38    51
9    TA Read Amy           Read(Amy)                    (wait)       .05   45   38    51
10   TB Read R_R                          Read(R_R)     (wait)       .05   45   38    51
11   TB Excl. Lock Bill                   XL(Bill)      (wait)       .05   45   38    51
12   TB Read Bill                         Read(Bill)    (wait)       .05   45   38    51
13   TB Write Bill                        Write(Bill)   (wait)       .05   45   39.9  51
14   TA Write Amy          Write(Amy)                   (wait)       .05   47.3 39.9  51
15   TA Release Lock Amy   Release(Amy)                 (wait)       .05   47.3 39.9  51
16   TB Release Lock R_R                  Release(R_R)  (wait)       .05   47.3 39.9  51
17   TB Release Lock Bill                 Release(Bill) (wait)       .05   47.3 39.9  51
18   TB Commit                            Commit        (wait)       .05   47.3 39.9  51
19   TA Release Lock R_R   Release(R_R)                 (wait)       .05   47.3 39.9  51
20   TC Excl. Lock Granted                              XL(R_R)      .05   47.3 39.9  51
21   TC Read R_R                                        Read(R_R)    .05   47.3 39.9  51
22   TC Write R_R                                       Write(R_R)   .03   47.3 39.9  51
23   TA Commit             Commit                                    .03   47.3 39.9  51
24   TC Excl. Lock Carl                                 XL(Carl)     .03   47.3 39.9  51
25   TC Read Carl                                       Read(Carl)   .03   47.3 39.9  51
26   TC Write Carl                                      Write(Carl)  .03   47.3 39.9  52.5
27   TC Release Lock Carl                               Release(Carl).03   47.3 39.9  52.5
28   TC Release Lock R_R                                Release(R_R) .03   47.3 39.9  52.5
29   TC Commit                                          Commit       .03   47.3 39.9  52.5

__Dead Lock__

Locking can cause problems, however.

Consider if two transactions each need to update two different data items (P200 and P300 in the example below).

Time Operation               TA             TB           P200   P300
1    Begin Transaction TA    Begin                        12     20
2    Begin Transaction TB                   Begin         12     20
3    TA Excl. Lock P200      XL(P200)                     12     20
4    TA Read P200            Read(P200)                   12     20
5    TB Excl. Lock P300                     XL(P300)      12     20
6    TB Read P300                           Read(P300)    12     20
7    TA Excl. Lock P300      (wait)                       12     20
8    TB Excl. Lock P200                     (wait)        12     20

This is called a __deadlock__. 

One transaction has locked some of the resources and is waiting for locks so it can complete. A second transaction has locked those needed items but is awaiting the release of locks the first transaction is holding so it can continue.

__Two main ways to deal with deadlock__:

1. Prevent it in the first place by giving each transaction exclusive rights to acquire all locks needed before proceeding.
2. Allow the deadlock to occur, then break it by aborting one of the transactions.

