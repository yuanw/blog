---
title: Project reactor - Mono zip with void 
date: May 07, 2022
modified: May 07, 2022
description: How to workaround mono zip void
tags: java, reactor 
---
# `Mono<Void>`

In reactor, sometime we want to give certain operation return type like ~Mono<Void>~, like we don't need any information from the operation, as long as the operation succeed. In this sense, we are using `Void` as Unit type 

# awkward case of Unit type in java

a unit type is a type that allows only one value.

https://en.wikipedia.org/wiki/Unit_type

> In Java, the unit type is `Void` and its only value is `null`.

https://docs.oracle.com/javase/8/docs/api/java/lang/Void.html


> The Void class is an uninstantiable placeholder class to hold a reference to the Class object representing the Java keyword void.

So `Void` supposes to be uninstantiable, but in practices, people use it as unit type along with `null`

# implication in project reactor

In project reactor, there is `Mono.zip` 

> Aggregate given monos into a new Mono that will be fulfilled when all of the given Monos have produced an item, aggregating their values according to the provided combinator function. An error or empty completion of any source will cause other sources to be cancelled and the resulting Mono to immediately error or complete, respectively. 

this method doesn't work well with `Mono<Void>`

```java
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

public class UnitTest {

  @DisplayName("prove Mono void is not zip able, otherwise pipeline should have one element")
  @Test
  void voidIsNotzipable() {
    StepVerifier.create(
            Mono.zip(
                    Mono.<Void>fromCallable(
                        () -> {
                          return null;
                        }),
                    Mono.just(2))
                .map(tuples -> 2))
        .verifyComplete();

    StepVerifier.create(Mono.zip(Mono.just(2).then(), Mono.just(2)).map(tuples -> 2))
        .verifyComplete();
  }
}
```

# a simple workaround

we define our own unit type 

```java
import java.io.Serializable;

/** There is only one value of type Unit, () Void with null doesn't play well with Mono.zip */
public class Unit implements Serializable {
  private Unit() {}

  public static final Unit INSTANCE = new Unit();
}
```

```java
    StepVerifier.create(
            Mono.zip(Mono.just(Unit.INSTANCE), Mono.just(Unit.INSTANCE)).map(tuples -> 2))
        .assertNext(val -> Assertions.assertThat(val).isEqualTo(2))
        .verifyComplete();
```
