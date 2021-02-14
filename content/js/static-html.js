// Generated by purs bundle 0.13.8
var PS = {};
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Semigroupoid"] = $PS["Control.Semigroupoid"] || {};
  var exports = $PS["Control.Semigroupoid"];
  var Semigroupoid = function (compose) {
      this.compose = compose;
  };
  var semigroupoidFn = new Semigroupoid(function (f) {
      return function (g) {
          return function (x) {
              return f(g(x));
          };
      };
  });
  exports["semigroupoidFn"] = semigroupoidFn;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Category"] = $PS["Control.Category"] || {};
  var exports = $PS["Control.Category"];
  var Control_Semigroupoid = $PS["Control.Semigroupoid"];                
  var Category = function (Semigroupoid0, identity) {
      this.Semigroupoid0 = Semigroupoid0;
      this.identity = identity;
  };
  var identity = function (dict) {
      return dict.identity;
  };
  var categoryFn = new Category(function () {
      return Control_Semigroupoid.semigroupoidFn;
  }, function (x) {
      return x;
  });
  exports["identity"] = identity;
  exports["categoryFn"] = categoryFn;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Function"] = $PS["Data.Function"] || {};
  var exports = $PS["Data.Function"];
  var flip = function (f) {
      return function (b) {
          return function (a) {
              return f(a)(b);
          };
      };
  };
  var $$const = function (a) {
      return function (v) {
          return a;
      };
  };
  exports["flip"] = flip;
  exports["const"] = $$const;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Functor"] = $PS["Data.Functor"] || {};
  var exports = $PS["Data.Functor"];
  var Data_Function = $PS["Data.Function"];        
  var Functor = function (map) {
      this.map = map;
  };
  var map = function (dict) {
      return dict.map;
  };
  var voidLeft = function (dictFunctor) {
      return function (f) {
          return function (x) {
              return map(dictFunctor)(Data_Function["const"](x))(f);
          };
      };
  };
  exports["Functor"] = Functor;
  exports["map"] = map;
  exports["voidLeft"] = voidLeft;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Apply"] = $PS["Control.Apply"] || {};
  var exports = $PS["Control.Apply"];
  var Control_Category = $PS["Control.Category"];
  var Data_Function = $PS["Data.Function"];
  var Data_Functor = $PS["Data.Functor"];                
  var Apply = function (Functor0, apply) {
      this.Functor0 = Functor0;
      this.apply = apply;
  };                      
  var apply = function (dict) {
      return dict.apply;
  };
  var applySecond = function (dictApply) {
      return function (a) {
          return function (b) {
              return apply(dictApply)(Data_Functor.map(dictApply.Functor0())(Data_Function["const"](Control_Category.identity(Control_Category.categoryFn)))(a))(b);
          };
      };
  };
  exports["Apply"] = Apply;
  exports["apply"] = apply;
  exports["applySecond"] = applySecond;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Applicative"] = $PS["Control.Applicative"] || {};
  var exports = $PS["Control.Applicative"];
  var Control_Apply = $PS["Control.Apply"];        
  var Applicative = function (Apply0, pure) {
      this.Apply0 = Apply0;
      this.pure = pure;
  };
  var pure = function (dict) {
      return dict.pure;
  };
  var liftA1 = function (dictApplicative) {
      return function (f) {
          return function (a) {
              return Control_Apply.apply(dictApplicative.Apply0())(pure(dictApplicative)(f))(a);
          };
      };
  };
  exports["Applicative"] = Applicative;
  exports["pure"] = pure;
  exports["liftA1"] = liftA1;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Bind"] = $PS["Control.Bind"] || {};
  var exports = $PS["Control.Bind"];
  var Data_Function = $PS["Data.Function"];
  var Bind = function (Apply0, bind) {
      this.Apply0 = Apply0;
      this.bind = bind;
  };                     
  var bind = function (dict) {
      return dict.bind;
  };
  var bindFlipped = function (dictBind) {
      return Data_Function.flip(bind(dictBind));
  };
  exports["Bind"] = Bind;
  exports["bind"] = bind;
  exports["bindFlipped"] = bindFlipped;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Monad"] = $PS["Control.Monad"] || {};
  var exports = $PS["Control.Monad"];
  var Control_Applicative = $PS["Control.Applicative"];
  var Control_Bind = $PS["Control.Bind"];                
  var Monad = function (Applicative0, Bind1) {
      this.Applicative0 = Applicative0;
      this.Bind1 = Bind1;
  };
  var ap = function (dictMonad) {
      return function (f) {
          return function (a) {
              return Control_Bind.bind(dictMonad.Bind1())(f)(function (f$prime) {
                  return Control_Bind.bind(dictMonad.Bind1())(a)(function (a$prime) {
                      return Control_Applicative.pure(dictMonad.Applicative0())(f$prime(a$prime));
                  });
              });
          };
      };
  };
  exports["Monad"] = Monad;
  exports["ap"] = ap;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.List.Types"] = $PS["Data.List.Types"] || {};
  var exports = $PS["Data.List.Types"];                          
  var Nil = (function () {
      function Nil() {

      };
      Nil.value = new Nil();
      return Nil;
  })();
  var Cons = (function () {
      function Cons(value0, value1) {
          this.value0 = value0;
          this.value1 = value1;
      };
      Cons.create = function (value0) {
          return function (value1) {
              return new Cons(value0, value1);
          };
      };
      return Cons;
  })();
  exports["Nil"] = Nil;
  exports["Cons"] = Cons;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.CatQueue"] = $PS["Data.CatQueue"] || {};
  var exports = $PS["Data.CatQueue"];
  var Data_List_Types = $PS["Data.List.Types"];                  
  var CatQueue = (function () {
      function CatQueue(value0, value1) {
          this.value0 = value0;
          this.value1 = value1;
      };
      CatQueue.create = function (value0) {
          return function (value1) {
              return new CatQueue(value0, value1);
          };
      };
      return CatQueue;
  })();
  var snoc = function (v) {
      return function (a) {
          return new CatQueue(v.value0, new Data_List_Types.Cons(a, v.value1));
      };
  };                                                                                                
  var empty = new CatQueue(Data_List_Types.Nil.value, Data_List_Types.Nil.value);
  exports["empty"] = empty;
  exports["snoc"] = snoc;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.CatList"] = $PS["Data.CatList"] || {};
  var exports = $PS["Data.CatList"];
  var Data_CatQueue = $PS["Data.CatQueue"];                      
  var CatNil = (function () {
      function CatNil() {

      };
      CatNil.value = new CatNil();
      return CatNil;
  })();
  var CatCons = (function () {
      function CatCons(value0, value1) {
          this.value0 = value0;
          this.value1 = value1;
      };
      CatCons.create = function (value0) {
          return function (value1) {
              return new CatCons(value0, value1);
          };
      };
      return CatCons;
  })();
  var link = function (v) {
      return function (v1) {
          if (v instanceof CatNil) {
              return v1;
          };
          if (v1 instanceof CatNil) {
              return v;
          };
          if (v instanceof CatCons) {
              return new CatCons(v.value0, Data_CatQueue.snoc(v.value1)(v1));
          };
          throw new Error("Failed pattern match at Data.CatList (line 109, column 1 - line 109, column 54): " + [ v.constructor.name, v1.constructor.name ]);
      };
  };
  var empty = CatNil.value;
  var append = link;
  var snoc = function (cat) {
      return function (a) {
          return append(cat)(new CatCons(a, Data_CatQueue.empty));
      };
  };
  exports["empty"] = empty;
  exports["snoc"] = snoc;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Monad.Free"] = $PS["Control.Monad.Free"] || {};
  var exports = $PS["Control.Monad.Free"];
  var Control_Applicative = $PS["Control.Applicative"];
  var Control_Apply = $PS["Control.Apply"];
  var Control_Bind = $PS["Control.Bind"];
  var Control_Monad = $PS["Control.Monad"];
  var Data_CatList = $PS["Data.CatList"];
  var Data_Functor = $PS["Data.Functor"];
  var Free = (function () {
      function Free(value0, value1) {
          this.value0 = value0;
          this.value1 = value1;
      };
      Free.create = function (value0) {
          return function (value1) {
              return new Free(value0, value1);
          };
      };
      return Free;
  })();
  var Return = (function () {
      function Return(value0) {
          this.value0 = value0;
      };
      Return.create = function (value0) {
          return new Return(value0);
      };
      return Return;
  })();
  var Bind = (function () {
      function Bind(value0, value1) {
          this.value0 = value0;
          this.value1 = value1;
      };
      Bind.create = function (value0) {
          return function (value1) {
              return new Bind(value0, value1);
          };
      };
      return Bind;
  })();
  var fromView = function (f) {
      return new Free(f, Data_CatList.empty);
  };
  var freeMonad = new Control_Monad.Monad(function () {
      return freeApplicative;
  }, function () {
      return freeBind;
  });
  var freeFunctor = new Data_Functor.Functor(function (k) {
      return function (f) {
          return Control_Bind.bindFlipped(freeBind)((function () {
              var $120 = Control_Applicative.pure(freeApplicative);
              return function ($121) {
                  return $120(k($121));
              };
          })())(f);
      };
  });
  var freeBind = new Control_Bind.Bind(function () {
      return freeApply;
  }, function (v) {
      return function (k) {
          return new Free(v.value0, Data_CatList.snoc(v.value1)(k));
      };
  });
  var freeApply = new Control_Apply.Apply(function () {
      return freeFunctor;
  }, Control_Monad.ap(freeMonad));
  var freeApplicative = new Control_Applicative.Applicative(function () {
      return freeApply;
  }, function ($122) {
      return fromView(Return.create($122));
  });
  exports["freeFunctor"] = freeFunctor;
  exports["freeApplicative"] = freeApplicative;
})(PS);
(function(exports) {
  "use strict";

  // module Unsafe.Coerce

  exports.unsafeCoerce = function (x) {
    return x;
  };
})(PS["Unsafe.Coerce"] = PS["Unsafe.Coerce"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Unsafe.Coerce"] = $PS["Unsafe.Coerce"] || {};
  var exports = $PS["Unsafe.Coerce"];
  var $foreign = $PS["Unsafe.Coerce"];
  exports["unsafeCoerce"] = $foreign.unsafeCoerce;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Exists"] = $PS["Data.Exists"] || {};
  var exports = $PS["Data.Exists"];
  var Unsafe_Coerce = $PS["Unsafe.Coerce"];                
  var runExists = Unsafe_Coerce.unsafeCoerce;
  exports["runExists"] = runExists;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Coyoneda"] = $PS["Data.Coyoneda"] || {};
  var exports = $PS["Data.Coyoneda"];
  var Data_Exists = $PS["Data.Exists"];
  var unCoyoneda = function (f) {
      return function (v) {
          return Data_Exists.runExists(function (v1) {
              return f(v1.value0)(v1.value1);
          })(v);
      };
  };
  exports["unCoyoneda"] = unCoyoneda;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Maybe"] = $PS["Data.Maybe"] || {};
  var exports = $PS["Data.Maybe"];                 
  var Nothing = (function () {
      function Nothing() {

      };
      Nothing.value = new Nothing();
      return Nothing;
  })();
  var Just = (function () {
      function Just(value0) {
          this.value0 = value0;
      };
      Just.create = function (value0) {
          return new Just(value0);
      };
      return Just;
  })();
  var maybe = function (v) {
      return function (v1) {
          return function (v2) {
              if (v2 instanceof Nothing) {
                  return v;
              };
              if (v2 instanceof Just) {
                  return v1(v2.value0);
              };
              throw new Error("Failed pattern match at Data.Maybe (line 217, column 1 - line 217, column 51): " + [ v.constructor.name, v1.constructor.name, v2.constructor.name ]);
          };
      };
  };
  exports["Nothing"] = Nothing;
  exports["Just"] = Just;
  exports["maybe"] = maybe;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Monoid"] = $PS["Data.Monoid"] || {};
  var exports = $PS["Data.Monoid"];
  var mempty = function (dict) {
      return dict.mempty;
  };
  exports["mempty"] = mempty;
})(PS);
(function(exports) {
  "use strict";

  exports.unit = {};
})(PS["Data.Unit"] = PS["Data.Unit"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Unit"] = $PS["Data.Unit"] || {};
  var exports = $PS["Data.Unit"];
  var $foreign = $PS["Data.Unit"];
  exports["unit"] = $foreign.unit;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Foldable"] = $PS["Data.Foldable"] || {};
  var exports = $PS["Data.Foldable"];
  var Control_Applicative = $PS["Control.Applicative"];
  var Control_Apply = $PS["Control.Apply"];
  var Data_Maybe = $PS["Data.Maybe"];
  var Data_Monoid = $PS["Data.Monoid"];
  var Data_Unit = $PS["Data.Unit"];                
  var Foldable = function (foldMap, foldl, foldr) {
      this.foldMap = foldMap;
      this.foldl = foldl;
      this.foldr = foldr;
  };
  var foldr = function (dict) {
      return dict.foldr;
  };
  var traverse_ = function (dictApplicative) {
      return function (dictFoldable) {
          return function (f) {
              return foldr(dictFoldable)((function () {
                  var $197 = Control_Apply.applySecond(dictApplicative.Apply0());
                  return function ($198) {
                      return $197(f($198));
                  };
              })())(Control_Applicative.pure(dictApplicative)(Data_Unit.unit));
          };
      };
  }; 
  var foldableMaybe = new Foldable(function (dictMonoid) {
      return function (f) {
          return function (v) {
              if (v instanceof Data_Maybe.Nothing) {
                  return Data_Monoid.mempty(dictMonoid);
              };
              if (v instanceof Data_Maybe.Just) {
                  return f(v.value0);
              };
              throw new Error("Failed pattern match at Data.Foldable (line 129, column 1 - line 135, column 27): " + [ f.constructor.name, v.constructor.name ]);
          };
      };
  }, function (v) {
      return function (z) {
          return function (v1) {
              if (v1 instanceof Data_Maybe.Nothing) {
                  return z;
              };
              if (v1 instanceof Data_Maybe.Just) {
                  return v(z)(v1.value0);
              };
              throw new Error("Failed pattern match at Data.Foldable (line 129, column 1 - line 135, column 27): " + [ v.constructor.name, z.constructor.name, v1.constructor.name ]);
          };
      };
  }, function (v) {
      return function (z) {
          return function (v1) {
              if (v1 instanceof Data_Maybe.Nothing) {
                  return z;
              };
              if (v1 instanceof Data_Maybe.Just) {
                  return v(v1.value0)(z);
              };
              throw new Error("Failed pattern match at Data.Foldable (line 129, column 1 - line 135, column 27): " + [ v.constructor.name, z.constructor.name, v1.constructor.name ]);
          };
      };
  });
  exports["traverse_"] = traverse_;
  exports["foldableMaybe"] = foldableMaybe;
})(PS);
(function(exports) {
  "use strict";

  exports.pureE = function (a) {
    return function () {
      return a;
    };
  };

  exports.bindE = function (a) {
    return function (f) {
      return function () {
        return f(a())();
      };
    };
  };
})(PS["Effect"] = PS["Effect"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Effect"] = $PS["Effect"] || {};
  var exports = $PS["Effect"];
  var $foreign = $PS["Effect"];
  var Control_Applicative = $PS["Control.Applicative"];
  var Control_Apply = $PS["Control.Apply"];
  var Control_Bind = $PS["Control.Bind"];
  var Control_Monad = $PS["Control.Monad"];
  var Data_Functor = $PS["Data.Functor"];                    
  var monadEffect = new Control_Monad.Monad(function () {
      return applicativeEffect;
  }, function () {
      return bindEffect;
  });
  var bindEffect = new Control_Bind.Bind(function () {
      return applyEffect;
  }, $foreign.bindE);
  var applyEffect = new Control_Apply.Apply(function () {
      return functorEffect;
  }, Control_Monad.ap(monadEffect));
  var applicativeEffect = new Control_Applicative.Applicative(function () {
      return applyEffect;
  }, $foreign.pureE);
  var functorEffect = new Data_Functor.Functor(Control_Applicative.liftA1(applicativeEffect));
  exports["monadEffect"] = monadEffect;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Effect.Class"] = $PS["Effect.Class"] || {};
  var exports = $PS["Effect.Class"];
  var Control_Category = $PS["Control.Category"];
  var Effect = $PS["Effect"];                
  var MonadEffect = function (Monad0, liftEffect) {
      this.Monad0 = Monad0;
      this.liftEffect = liftEffect;
  };
  var monadEffectEffect = new MonadEffect(function () {
      return Effect.monadEffect;
  }, Control_Category.identity(Control_Category.categoryFn));
  var liftEffect = function (dict) {
      return dict.liftEffect;
  };
  exports["liftEffect"] = liftEffect;
  exports["monadEffectEffect"] = monadEffectEffect;
})(PS);
(function(exports) {
  "use strict";

  exports.log = function (s) {
    return function () {
      console.log(s);
      return {};
    };
  };
})(PS["Effect.Console"] = PS["Effect.Console"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Effect.Console"] = $PS["Effect.Console"] || {};
  var exports = $PS["Effect.Console"];
  var $foreign = $PS["Effect.Console"];
  exports["log"] = $foreign.log;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Effect.Class.Console"] = $PS["Effect.Class.Console"] || {};
  var exports = $PS["Effect.Class.Console"];
  var Effect_Class = $PS["Effect.Class"];
  var Effect_Console = $PS["Effect.Console"];
  var log = function (dictMonadEffect) {
      var $30 = Effect_Class.liftEffect(dictMonadEffect);
      return function ($31) {
          return $30(Effect_Console.log($31));
      };
  };
  exports["log"] = log;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Halogen.Query.HalogenM"] = $PS["Halogen.Query.HalogenM"] || {};
  var exports = $PS["Halogen.Query.HalogenM"];
  var Control_Monad_Free = $PS["Control.Monad.Free"];
  var functorHalogenM = Control_Monad_Free.freeFunctor;     
  var applicativeHalogenM = Control_Monad_Free.freeApplicative;
  exports["functorHalogenM"] = functorHalogenM;
  exports["applicativeHalogenM"] = applicativeHalogenM;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Halogen.Query.HalogenQ"] = $PS["Halogen.Query.HalogenQ"] || {};
  var exports = $PS["Halogen.Query.HalogenQ"];           
  var Initialize = (function () {
      function Initialize(value0) {
          this.value0 = value0;
      };
      Initialize.create = function (value0) {
          return new Initialize(value0);
      };
      return Initialize;
  })();
  var Finalize = (function () {
      function Finalize(value0) {
          this.value0 = value0;
      };
      Finalize.create = function (value0) {
          return new Finalize(value0);
      };
      return Finalize;
  })();
  var Receive = (function () {
      function Receive(value0, value1) {
          this.value0 = value0;
          this.value1 = value1;
      };
      Receive.create = function (value0) {
          return function (value1) {
              return new Receive(value0, value1);
          };
      };
      return Receive;
  })();
  var Action = (function () {
      function Action(value0, value1) {
          this.value0 = value0;
          this.value1 = value1;
      };
      Action.create = function (value0) {
          return function (value1) {
              return new Action(value0, value1);
          };
      };
      return Action;
  })();
  var Query = (function () {
      function Query(value0, value1) {
          this.value0 = value0;
          this.value1 = value1;
      };
      Query.create = function (value0) {
          return function (value1) {
              return new Query(value0, value1);
          };
      };
      return Query;
  })();
  exports["Initialize"] = Initialize;
  exports["Finalize"] = Finalize;
  exports["Receive"] = Receive;
  exports["Action"] = Action;
  exports["Query"] = Query;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Halogen.Component"] = $PS["Halogen.Component"] || {};
  var exports = $PS["Halogen.Component"];
  var Control_Applicative = $PS["Control.Applicative"];
  var Data_Coyoneda = $PS["Data.Coyoneda"];
  var Data_Foldable = $PS["Data.Foldable"];
  var Data_Function = $PS["Data.Function"];
  var Data_Functor = $PS["Data.Functor"];
  var Data_Maybe = $PS["Data.Maybe"];
  var Data_Unit = $PS["Data.Unit"];
  var Halogen_Query_HalogenM = $PS["Halogen.Query.HalogenM"];
  var Halogen_Query_HalogenQ = $PS["Halogen.Query.HalogenQ"];
  var Unsafe_Coerce = $PS["Unsafe.Coerce"];    
  var mkEval = function (args) {
      return function (v) {
          if (v instanceof Halogen_Query_HalogenQ.Initialize) {
              return Data_Functor.voidLeft(Halogen_Query_HalogenM.functorHalogenM)(Data_Foldable.traverse_(Halogen_Query_HalogenM.applicativeHalogenM)(Data_Foldable.foldableMaybe)(args.handleAction)(args.initialize))(v.value0);
          };
          if (v instanceof Halogen_Query_HalogenQ.Finalize) {
              return Data_Functor.voidLeft(Halogen_Query_HalogenM.functorHalogenM)(Data_Foldable.traverse_(Halogen_Query_HalogenM.applicativeHalogenM)(Data_Foldable.foldableMaybe)(args.handleAction)(args.finalize))(v.value0);
          };
          if (v instanceof Halogen_Query_HalogenQ.Receive) {
              return Data_Functor.voidLeft(Halogen_Query_HalogenM.functorHalogenM)(Data_Foldable.traverse_(Halogen_Query_HalogenM.applicativeHalogenM)(Data_Foldable.foldableMaybe)(args.handleAction)(args.receive(v.value0)))(v.value1);
          };
          if (v instanceof Halogen_Query_HalogenQ.Action) {
              return Data_Functor.voidLeft(Halogen_Query_HalogenM.functorHalogenM)(args.handleAction(v.value0))(v.value1);
          };
          if (v instanceof Halogen_Query_HalogenQ.Query) {
              return Data_Coyoneda.unCoyoneda(function (g) {
                  var $28 = Data_Functor.map(Halogen_Query_HalogenM.functorHalogenM)(Data_Maybe.maybe(v.value1(Data_Unit.unit))(g));
                  return function ($29) {
                      return $28(args.handleQuery($29));
                  };
              })(v.value0);
          };
          throw new Error("Failed pattern match at Halogen.Component (line 187, column 15 - line 197, column 70): " + [ v.constructor.name ]);
      };
  };                                               
  var mkComponent = Unsafe_Coerce.unsafeCoerce;
  var defaultEval = {
      handleAction: Data_Function["const"](Control_Applicative.pure(Halogen_Query_HalogenM.applicativeHalogenM)(Data_Unit.unit)),
      handleQuery: Data_Function["const"](Control_Applicative.pure(Halogen_Query_HalogenM.applicativeHalogenM)(Data_Maybe.Nothing.value)),
      receive: Data_Function["const"](Data_Maybe.Nothing.value),
      initialize: Data_Maybe.Nothing.value,
      finalize: Data_Maybe.Nothing.value
  };
  exports["mkComponent"] = mkComponent;
  exports["mkEval"] = mkEval;
  exports["defaultEval"] = defaultEval;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Halogen.VDom.Types"] = $PS["Halogen.VDom.Types"] || {};
  var exports = $PS["Halogen.VDom.Types"];
  var Text = (function () {
      function Text(value0) {
          this.value0 = value0;
      };
      Text.create = function (value0) {
          return new Text(value0);
      };
      return Text;
  })();
  var Elem = (function () {
      function Elem(value0, value1, value2, value3) {
          this.value0 = value0;
          this.value1 = value1;
          this.value2 = value2;
          this.value3 = value3;
      };
      Elem.create = function (value0) {
          return function (value1) {
              return function (value2) {
                  return function (value3) {
                      return new Elem(value0, value1, value2, value3);
                  };
              };
          };
      };
      return Elem;
  })();
  exports["Text"] = Text;
  exports["Elem"] = Elem;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Halogen.HTML.Core"] = $PS["Halogen.HTML.Core"] || {};
  var exports = $PS["Halogen.HTML.Core"];
  var Halogen_VDom_Types = $PS["Halogen.VDom.Types"];
  var HTML = function (x) {
      return x;
  };
  var text = function ($31) {
      return HTML(Halogen_VDom_Types.Text.create($31));
  };                                
  var element = function (ns) {
      return function (name) {
          return function (props) {
              return function (children) {
                  return new Halogen_VDom_Types.Elem(ns, name, props, children);
              };
          };
      };
  };
  exports["text"] = text;
  exports["element"] = element;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Halogen.HTML.Elements"] = $PS["Halogen.HTML.Elements"] || {};
  var exports = $PS["Halogen.HTML.Elements"];
  var Data_Maybe = $PS["Data.Maybe"];
  var Halogen_HTML_Core = $PS["Halogen.HTML.Core"];
  var element = Halogen_HTML_Core.element(Data_Maybe.Nothing.value);
  var span = element("span");
  var span_ = span([  ]);
  var div = element("div");
  var div_ = div([  ]);
  var button = element("button");
  var button_ = button([  ]);
  exports["button_"] = button_;
  exports["div_"] = div_;
  exports["span_"] = span_;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["StaticHTML.StaticHTML"] = $PS["StaticHTML.StaticHTML"] || {};
  var exports = $PS["StaticHTML.StaticHTML"];
  var Data_Function = $PS["Data.Function"];
  var Data_Unit = $PS["Data.Unit"];
  var Effect_Class = $PS["Effect.Class"];
  var Effect_Class_Console = $PS["Effect.Class.Console"];
  var Halogen_Component = $PS["Halogen.Component"];
  var Halogen_HTML_Core = $PS["Halogen.HTML.Core"];
  var Halogen_HTML_Elements = $PS["Halogen.HTML.Elements"];                
  var staticHtml = Halogen_HTML_Elements.div_([ Halogen_HTML_Elements.div_([ Halogen_HTML_Elements.span_([ Halogen_HTML_Core.text("This is text in a span!") ]) ]), Halogen_HTML_Elements.button_([ Halogen_HTML_Core.text("You can click me, but I don't do anything.") ]) ]);
  var staticComponent = function (renderHtml) {
      return Halogen_Component.mkComponent({
          initialState: Data_Function["const"](Data_Unit.unit),
          render: function (v) {
              return renderHtml;
          },
          "eval": Halogen_Component.mkEval(Halogen_Component.defaultEval)
      });
  };
  var main = function __do() {
      Effect_Class_Console.log(Effect_Class.monadEffectEffect)("\ud83c\udf5d")();
      return Effect_Class_Console.log(Effect_Class.monadEffectEffect)("You should add some code.")();
  };
  exports["staticHtml"] = staticHtml;
  exports["main"] = main;
  exports["staticComponent"] = staticComponent;
})(PS);
PS["StaticHTML.StaticHTML"].main();