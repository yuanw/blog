// Generated by purs bundle 0.13.8
var PS = {};
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Apply"] = $PS["Control.Apply"] || {};
  var exports = $PS["Control.Apply"];                    
  var Apply = function (Functor0, apply) {
      this.Functor0 = Functor0;
      this.apply = apply;
  };                      
  var apply = function (dict) {
      return dict.apply;
  };
  exports["Apply"] = Apply;
  exports["apply"] = apply;
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
  $PS["Control.Applicative"] = $PS["Control.Applicative"] || {};
  var exports = $PS["Control.Applicative"];
  var Control_Apply = $PS["Control.Apply"];
  var Data_Unit = $PS["Data.Unit"];                
  var Applicative = function (Apply0, pure) {
      this.Apply0 = Apply0;
      this.pure = pure;
  };
  var pure = function (dict) {
      return dict.pure;
  };
  var unless = function (dictApplicative) {
      return function (v) {
          return function (v1) {
              if (!v) {
                  return v1;
              };
              if (v) {
                  return pure(dictApplicative)(Data_Unit.unit);
              };
              throw new Error("Failed pattern match at Control.Applicative (line 62, column 1 - line 62, column 65): " + [ v.constructor.name, v1.constructor.name ]);
          };
      };
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
  exports["unless"] = unless;
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
  $PS["Control.Monad"] = $PS["Control.Monad"] || {};
  var exports = $PS["Control.Monad"];
  var Control_Applicative = $PS["Control.Applicative"];
  var Control_Bind = $PS["Control.Bind"];                
  var Monad = function (Applicative0, Bind1) {
      this.Applicative0 = Applicative0;
      this.Bind1 = Bind1;
  }; 
  var liftM1 = function (dictMonad) {
      return function (f) {
          return function (a) {
              return Control_Bind.bind(dictMonad.Bind1())(a)(function (a$prime) {
                  return Control_Applicative.pure(dictMonad.Applicative0())(f(a$prime));
              });
          };
      };
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
  exports["liftM1"] = liftM1;
  exports["ap"] = ap;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Monad.Trans.Class"] = $PS["Control.Monad.Trans.Class"] || {};
  var exports = $PS["Control.Monad.Trans.Class"];
  var MonadTrans = function (lift) {
      this.lift = lift;
  };
  var lift = function (dict) {
      return dict.lift;
  };
  exports["lift"] = lift;
  exports["MonadTrans"] = MonadTrans;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Functor"] = $PS["Data.Functor"] || {};
  var exports = $PS["Data.Functor"];
  var Data_Function = $PS["Data.Function"];
  var Data_Unit = $PS["Data.Unit"];                
  var Functor = function (map) {
      this.map = map;
  };
  var map = function (dict) {
      return dict.map;
  };
  var $$void = function (dictFunctor) {
      return map(dictFunctor)(Data_Function["const"](Data_Unit.unit));
  };
  exports["Functor"] = Functor;
  exports["map"] = map;
  exports["void"] = $$void;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Maybe"] = $PS["Data.Maybe"] || {};
  var exports = $PS["Data.Maybe"];
  var Data_Functor = $PS["Data.Functor"];          
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
  var functorMaybe = new Data_Functor.Functor(function (v) {
      return function (v1) {
          if (v1 instanceof Just) {
              return new Just(v(v1.value0));
          };
          return Nothing.value;
      };
  });
  exports["Nothing"] = Nothing;
  exports["Just"] = Just;
  exports["functorMaybe"] = functorMaybe;
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
  exports["functorEffect"] = functorEffect;
  exports["applicativeEffect"] = applicativeEffect;
  exports["bindEffect"] = bindEffect;
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
  exports["MonadEffect"] = MonadEffect;
  exports["monadEffectEffect"] = monadEffectEffect;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Control.Monad.Maybe.Trans"] = $PS["Control.Monad.Maybe.Trans"] || {};
  var exports = $PS["Control.Monad.Maybe.Trans"];
  var Control_Applicative = $PS["Control.Applicative"];
  var Control_Apply = $PS["Control.Apply"];
  var Control_Bind = $PS["Control.Bind"];
  var Control_Monad = $PS["Control.Monad"];
  var Control_Monad_Trans_Class = $PS["Control.Monad.Trans.Class"];
  var Data_Functor = $PS["Data.Functor"];
  var Data_Maybe = $PS["Data.Maybe"];
  var Effect_Class = $PS["Effect.Class"];                
  var MaybeT = function (x) {
      return x;
  };
  var runMaybeT = function (v) {
      return v;
  };         
  var monadTransMaybeT = new Control_Monad_Trans_Class.MonadTrans(function (dictMonad) {
      var $71 = Control_Monad.liftM1(dictMonad)(Data_Maybe.Just.create);
      return function ($72) {
          return MaybeT($71($72));
      };
  });
  var functorMaybeT = function (dictFunctor) {
      return new Data_Functor.Functor(function (f) {
          return function (v) {
              return Data_Functor.map(dictFunctor)(Data_Functor.map(Data_Maybe.functorMaybe)(f))(v);
          };
      });
  };
  var monadMaybeT = function (dictMonad) {
      return new Control_Monad.Monad(function () {
          return applicativeMaybeT(dictMonad);
      }, function () {
          return bindMaybeT(dictMonad);
      });
  };
  var bindMaybeT = function (dictMonad) {
      return new Control_Bind.Bind(function () {
          return applyMaybeT(dictMonad);
      }, function (v) {
          return function (f) {
              return Control_Bind.bind(dictMonad.Bind1())(v)(function (v1) {
                  if (v1 instanceof Data_Maybe.Nothing) {
                      return Control_Applicative.pure(dictMonad.Applicative0())(Data_Maybe.Nothing.value);
                  };
                  if (v1 instanceof Data_Maybe.Just) {
                      var v2 = f(v1.value0);
                      return v2;
                  };
                  throw new Error("Failed pattern match at Control.Monad.Maybe.Trans (line 54, column 11 - line 56, column 42): " + [ v1.constructor.name ]);
              });
          };
      });
  };
  var applyMaybeT = function (dictMonad) {
      return new Control_Apply.Apply(function () {
          return functorMaybeT(((dictMonad.Bind1()).Apply0()).Functor0());
      }, Control_Monad.ap(monadMaybeT(dictMonad)));
  };
  var applicativeMaybeT = function (dictMonad) {
      return new Control_Applicative.Applicative(function () {
          return applyMaybeT(dictMonad);
      }, (function () {
          var $73 = Control_Applicative.pure(dictMonad.Applicative0());
          return function ($74) {
              return MaybeT($73(Data_Maybe.Just.create($74)));
          };
      })());
  };
  var monadEffectMaybe = function (dictMonadEffect) {
      return new Effect_Class.MonadEffect(function () {
          return monadMaybeT(dictMonadEffect.Monad0());
      }, (function () {
          var $75 = Control_Monad_Trans_Class.lift(monadTransMaybeT)(dictMonadEffect.Monad0());
          var $76 = Effect_Class.liftEffect(dictMonadEffect);
          return function ($77) {
              return $75($76($77));
          };
      })());
  };
  exports["MaybeT"] = MaybeT;
  exports["runMaybeT"] = runMaybeT;
  exports["bindMaybeT"] = bindMaybeT;
  exports["monadEffectMaybe"] = monadEffectMaybe;
})(PS);
(function(exports) {
  "use strict";          

  exports.nullable = function (a, r, f) {
    return a == null ? r : f(a);
  };
})(PS["Data.Nullable"] = PS["Data.Nullable"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Data.Nullable"] = $PS["Data.Nullable"] || {};
  var exports = $PS["Data.Nullable"];
  var $foreign = $PS["Data.Nullable"];
  var Data_Maybe = $PS["Data.Maybe"];                                   
  var toMaybe = function (n) {
      return $foreign.nullable(n, Data_Maybe.Nothing.value, Data_Maybe.Just.create);
  };
  exports["toMaybe"] = toMaybe;
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
(function(exports) {
  "use strict";

  exports.new = function (val) {
    return function () {
      return { value: val };
    };
  };

  exports.read = function (ref) {
    return function () {
      return ref.value;
    };
  };

  exports.write = function (val) {
    return function (ref) {
      return function () {
        ref.value = val;
        return {};
      };
    };
  };
})(PS["Effect.Ref"] = PS["Effect.Ref"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Effect.Ref"] = $PS["Effect.Ref"] || {};
  var exports = $PS["Effect.Ref"];
  var $foreign = $PS["Effect.Ref"];
  exports["new"] = $foreign["new"];
  exports["read"] = $foreign.read;
  exports["write"] = $foreign.write;
})(PS);
(function(exports) {
  "use strict";

  exports.remove = function(list) {
    return function(token) {
      return function() {
        return list.remove(token);
      };
    };
  };
})(PS["Web.DOM.DOMTokenList"] = PS["Web.DOM.DOMTokenList"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Web.DOM.DOMTokenList"] = $PS["Web.DOM.DOMTokenList"] || {};
  var exports = $PS["Web.DOM.DOMTokenList"];
  var $foreign = $PS["Web.DOM.DOMTokenList"];
  exports["remove"] = $foreign.remove;
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
  $PS["Web.DOM.Document"] = $PS["Web.DOM.Document"] || {};
  var exports = $PS["Web.DOM.Document"];
  var Unsafe_Coerce = $PS["Unsafe.Coerce"];                      
  var toParentNode = Unsafe_Coerce.unsafeCoerce;
  var toEventTarget = Unsafe_Coerce.unsafeCoerce;
  exports["toParentNode"] = toParentNode;
  exports["toEventTarget"] = toEventTarget;
})(PS);
(function(exports) {
  "use strict";

  exports.classList = function (element) {
    return function () {
      return element.classList;
    };
  };
})(PS["Web.DOM.Element"] = PS["Web.DOM.Element"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Web.DOM.Element"] = $PS["Web.DOM.Element"] || {};
  var exports = $PS["Web.DOM.Element"];
  var $foreign = $PS["Web.DOM.Element"];
  exports["classList"] = $foreign.classList;
})(PS);
(function(exports) {
  "use strict";                                               

  exports._querySelector = function (selector) {
    return function (node) {
      return function () {
        return node.querySelector(selector);
      };
    };
  };
})(PS["Web.DOM.ParentNode"] = PS["Web.DOM.ParentNode"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Web.DOM.ParentNode"] = $PS["Web.DOM.ParentNode"] || {};
  var exports = $PS["Web.DOM.ParentNode"];
  var $foreign = $PS["Web.DOM.ParentNode"];
  var Data_Functor = $PS["Data.Functor"];
  var Data_Nullable = $PS["Data.Nullable"];
  var Effect = $PS["Effect"];
  var querySelector = function (qs) {
      var $3 = Data_Functor.map(Effect.functorEffect)(Data_Nullable.toMaybe);
      var $4 = $foreign["_querySelector"](qs);
      return function ($5) {
          return $3($4($5));
      };
  };
  exports["querySelector"] = querySelector;
})(PS);
(function(exports) {
  "use strict";

  exports.eventListener = function (fn) {
    return function () {
      return function (event) {
        return fn(event)();
      };
    };
  };

  exports.addEventListener = function (type) {
    return function (listener) {
      return function (useCapture) {
        return function (target) {
          return function () {
            return target.addEventListener(type, listener, useCapture);
          };
        };
      };
    };
  };
})(PS["Web.Event.EventTarget"] = PS["Web.Event.EventTarget"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Web.Event.EventTarget"] = $PS["Web.Event.EventTarget"] || {};
  var exports = $PS["Web.Event.EventTarget"];
  var $foreign = $PS["Web.Event.EventTarget"];
  exports["eventListener"] = $foreign.eventListener;
  exports["addEventListener"] = $foreign.addEventListener;
})(PS);
(function(exports) {
  /* global window */
  "use strict";

  exports.window = function () {
    return window;
  };
})(PS["Web.HTML"] = PS["Web.HTML"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Web.HTML"] = $PS["Web.HTML"] || {};
  var exports = $PS["Web.HTML"];
  var $foreign = $PS["Web.HTML"];
  exports["window"] = $foreign.window;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Web.HTML.Event.EventTypes"] = $PS["Web.HTML.Event.EventTypes"] || {};
  var exports = $PS["Web.HTML.Event.EventTypes"];
  var readystatechange = "readystatechange";
  exports["readystatechange"] = readystatechange;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Web.HTML.HTMLDocument"] = $PS["Web.HTML.HTMLDocument"] || {};
  var exports = $PS["Web.HTML.HTMLDocument"];
  var Unsafe_Coerce = $PS["Unsafe.Coerce"];      
  var toDocument = Unsafe_Coerce.unsafeCoerce;
  exports["toDocument"] = toDocument;
})(PS);
(function(exports) {
  "use strict";

  exports.document = function (window) {
    return function () {
      return window.document;
    };
  };
})(PS["Web.HTML.Window"] = PS["Web.HTML.Window"] || {});
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Web.HTML.Window"] = $PS["Web.HTML.Window"] || {};
  var exports = $PS["Web.HTML.Window"];
  var $foreign = $PS["Web.HTML.Window"];
  exports["document"] = $foreign.document;
})(PS);
(function($PS) {
  // Generated by purs version 0.13.8
  "use strict";
  $PS["Frontend"] = $PS["Frontend"] || {};
  var exports = $PS["Frontend"];
  var Control_Applicative = $PS["Control.Applicative"];
  var Control_Bind = $PS["Control.Bind"];
  var Control_Monad_Maybe_Trans = $PS["Control.Monad.Maybe.Trans"];
  var Data_Functor = $PS["Data.Functor"];
  var Effect = $PS["Effect"];
  var Effect_Class = $PS["Effect.Class"];
  var Effect_Class_Console = $PS["Effect.Class.Console"];
  var Effect_Ref = $PS["Effect.Ref"];
  var Web_DOM_DOMTokenList = $PS["Web.DOM.DOMTokenList"];
  var Web_DOM_Document = $PS["Web.DOM.Document"];
  var Web_DOM_Element = $PS["Web.DOM.Element"];
  var Web_DOM_ParentNode = $PS["Web.DOM.ParentNode"];
  var Web_Event_EventTarget = $PS["Web.Event.EventTarget"];
  var Web_HTML = $PS["Web.HTML"];
  var Web_HTML_Event_EventTypes = $PS["Web.HTML.Event.EventTypes"];
  var Web_HTML_HTMLDocument = $PS["Web.HTML.HTMLDocument"];
  var Web_HTML_Window = $PS["Web.HTML.Window"];                
  var updateClss = function (doc) {
      var docPN = Web_DOM_Document.toParentNode(doc);
      return Data_Functor["void"](Effect.functorEffect)(Control_Monad_Maybe_Trans.runMaybeT(Control_Bind.bind(Control_Monad_Maybe_Trans.bindMaybeT(Effect.monadEffect))(Control_Monad_Maybe_Trans.MaybeT(Web_DOM_ParentNode.querySelector("#toc")(docPN)))(function (toc) {
          return Effect_Class.liftEffect(Control_Monad_Maybe_Trans.monadEffectMaybe(Effect_Class.monadEffectEffect))(function __do() {
              Effect_Class_Console.log(Effect_Class.monadEffectEffect)("hi")();
              var cList = Web_DOM_Element.classList(toc)();
              return Web_DOM_DOMTokenList.remove(cList)("hidden")();
          });
      })));
  };
  var onE = function (etype) {
      return function (targ) {
          return function (h) {
              return function __do() {
                  var listener = Web_Event_EventTarget.eventListener(h)();
                  return Web_Event_EventTarget.addEventListener(etype)(listener)(false)(targ)();
              };
          };
      };
  };
  var doOnce = function (a) {
      return function __do() {
          var doneRef = Effect_Ref["new"](false)();
          return function __do() {
              var done = Effect_Ref.read(doneRef)();
              return Control_Applicative.unless(Effect.applicativeEffect)(done)(function __do() {
                  a();
                  return Effect_Ref.write(true)(doneRef)();
              })();
          };
      };
  };
  var main = (function () {
      var ready = function (doc) {
          return function (a) {
              return function __do() {
                  var a$prime = doOnce(a)();
                  return onE(Web_HTML_Event_EventTypes.readystatechange)(Web_DOM_Document.toEventTarget(doc))(function (v) {
                      return a$prime;
                  })();
              };
          };
      };
      return function __do() {
          var doc = Control_Bind.bindFlipped(Effect.bindEffect)((function () {
              var $1 = Data_Functor.map(Effect.functorEffect)(Web_HTML_HTMLDocument.toDocument);
              return function ($2) {
                  return $1(Web_HTML_Window.document($2));
              };
          })())(Web_HTML.window)();
          return ready(doc)(function __do() {
              updateClss(doc)();
              return Effect_Class_Console.log(Effect_Class.monadEffectEffect)("Hello from PureScript!")();
          })();
      };
  })();
  exports["main"] = main;
  exports["updateClss"] = updateClss;
  exports["doOnce"] = doOnce;
  exports["onE"] = onE;
})(PS);
PS["Frontend"].main();