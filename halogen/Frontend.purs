module Frontend where

import Prelude

import Control.Monad.Maybe.Trans         (MaybeT(..), runMaybeT)
import Effect                            (Effect)
import Effect.Class                      (liftEffect)
import Effect.Class.Console              (log)
import Effect.Ref                        as Ref
import Web.DOM.DOMTokenList              as DOMTokenList
import Web.Event.Event                   (Event, EventType)
import Web.Event.EventTarget             (EventTarget, addEventListener, eventListener)
import Web.HTML.Event.EventTypes         (readystatechange)
import Web.HTML.HTMLDocument             as HTMLDocument
import Web.HTML                          as Web
import Web.HTML.Window                   as Window
import Web.DOM.Document                  as Document
import Web.DOM.Element                   as Element
import Web.DOM.ParentNode                as ParentNode

main :: Effect Unit
main = do
  doc  <- map HTMLDocument.toDocument <<< Window.document =<< Web.window
  ready doc do
    log "hello from purescript"
    updateClss doc
  where
    ready doc a = do
      a' <- doOnce a
      onE readystatechange
          (Document.toEventTarget doc)
          (\_ -> a')


updateClss :: Document.Document -> Effect Unit
updateClss doc = void <<< runMaybeT $ do
  toc <- MaybeT $ ParentNode.querySelector
      (ParentNode.QuerySelector "#toc") docPN
  liftEffect do
      cList    <- Element.classList toc
      log "found toc"
      -- DOMTokenList.remove cList "hidden"
      -- log "remove hidden class"
  where
    docPN = Document.toParentNode doc

doOnce
    :: Effect Unit
    -> Effect (Effect Unit)
doOnce a = do
    doneRef <- Ref.new false
    pure do
      done <- Ref.read doneRef
      unless done do
        a
        Ref.write true doneRef

onE :: EventType
    -> EventTarget
    -> (Event -> Effect Unit)
    -> Effect Unit
onE etype targ h = do
  listener <- eventListener h
  addEventListener etype listener false targ
