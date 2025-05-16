---
title: How to send batch SQL update with spring r2dbc
date: 2024-06-20
lastUpdated: 2024-06-20
tags:
  - TIL
  - java
  - r2dbc
---

# How to do a single statement SQL update using r2dbc ?
Probably, the most common way is the following
```java
import org.springframework.r2dbc.core.DatabaseClient;
ConnectionFactory factory = …

 DatabaseClient client = DatabaseClient.create(factory);
 Mono<Map<String, Object>> actor = client.sql("INSERT INTO t_actor (first_name, last_name ) VALUES (:fName, :lName")
 .bind("fName", "First")
 .bind("lNane", "last")
 .fetch().first();
```

With java multi-line support, and `bind` method has common sql-injection protection. This is a reasonable interface to work with.

# Batch Update

Bind the same parm multiple times  `org.springframework.r2dbc.core.DatabaseClient.sql` wouldn't yield a batch update.

Luckily, `DatabaseClient` has [`inConnectionMany`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/r2dbc/core/ConnectionAccessor.html#inConnectionMany(java.util.function.Function)) method.

Combining with [Statement](https://r2dbc.io/spec/1.0.0.RELEASE/api/io/r2dbc/spi/Statement.html), one can do batch in the following fashion.

```java
import org.springframework.r2dbc.core.DatabaseClient;
import io.r2dbc.spi.Statement;
import reactor.core.publisher.Flux;

...
DatabaseClient databaseClient;
....
databaseClient.inConnectionMany(connection -> {
   Statement statement = connection.createStatement("INSERT INTO t_actor (first_name, last_name ) VALUES (?fName, ?lName"));
    statement.bind("fName", ...)
        .bind("lName", ...);
    // statement.add need to called for non-head non-tail element
    statement.add();
    statement.bind("fName", ...)
        .bind("lName", ...);
    return Flux.from(statments.execute());
});
```

`Statement.add` needs to invoked correctly.
> Save the current binding and create a new one to indicate the statement should be executed again with new bindings provided through subsequent calls to bind and bindNull.

Otherwise, `java.lang.IllegalStateException: Not all parameter values are provided yet.` might occur.
## Why not use [Batch](https://r2dbc.io/spec/1.0.0.RELEASE/api/io/r2dbc/spi/Batch.html)

[Batch](https://r2dbc.io/spec/1.0.0.RELEASE/api/io/r2dbc/spi/Batch.html) doesn't support bind. It only can work with string. Unless the batch update only involve constant, which sounds unlikely, sql-injection should be a concern, using Statement should be a safer approach.


# Compose batches

`Flux.thenMany` could be use to compose two `Flux.from(Statement.execute)`

# Transaction

One can add transaction management around the batch update in the follow fashion.

```java
import lombok.NonNull;
import lombok.Builder;
import lombok.Value;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.transaction.ReactiveTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.reactive.TransactionalOperator;
import org.springframework.transaction.support.DefaultTransactionDefinition;

@Value
@Builder
class Test  {
    @NonNull DatabaseClient databaseClient;
    @NonNull ReactiveTransactionManager tm;
    @Builder.Default int isolationLevel = TransactionDefinition.ISOLATION_REPEATABLE_READ;
    @Builder.Default int propagationBehavior = TransactionDefinition.PROPAGATION_REQUIRED;
  

 TransactionDefinition getTxnDfn() {
    var txnDfn = new DefaultTransactionDefinition();
    txnDfn.setIsolationLevel(config.isolationLevel);
    txnDfn.setPropagationBehavior(config.propagationBehavior);
    return txnDfn;
  }
  
  Flux<Result> update() {
    return TransactionalOperator.create(tm, getTxnDfn())
        .execute(
            status -> {
              return batchOp();
            });
  }
 
 }
```
