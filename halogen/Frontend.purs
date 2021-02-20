module Frontend where

import Prelude

-- Imports for lesson
import Halogen.HTML as HH

-- Imports for scaffolding
import Control.Monad.Error.Class (throwError)
import Data.Const (Const)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Exception (error)
import Halogen as H
import Halogen.Aff (awaitLoad, selectElement, runHalogenAff)
import Halogen.VDom.Driver (runUI)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML (HTMLElement)

main :: Effect Unit
main =
  -- We're going to run the same function below 3 times using
  -- the 3 values provided here.
  runStateOnlyDynamicRenderer 1 2 3 simpleIntState

-- | Shows how to use Halogen VDOM DSL to render dynamic HTML
-- | (no event handling) based on the state value received.
simpleIntState :: Int -> StaticHTML
simpleIntState state =
  HH.div_ [ HH.text $ "The state was: " <> show state ]

-- Scaffolded code below --

-- | HTML written in Purescript via Halogen's HTML DSL
-- | that is always rendered the same and does not include any event handling.
type StaticHTML = H.ComponentHTML Unit () Aff

-- | A function that uses the `state` type's value to render HTML
-- | with no event-handling.
type StateOnlyDynamicRenderer state = (state -> StaticHTML)

-- | Uses the `state` type's value to render dynamic HTML
-- | using 3 different state values.
runStateOnlyDynamicRenderer :: forall state.
                               state
                            -> state
                            -> state
                            -> StateOnlyDynamicRenderer state
                            -> Effect Unit
runStateOnlyDynamicRenderer firstState secondState thirdState rendererFunction =
  runHalogenAff do
    awaitLoad

    div1 <- selectElement' "could not find 'div#first'" $ QuerySelector "#first"
    div2 <- selectElement' "could not find 'div#second'" $ QuerySelector "#second"
    div3 <- selectElement' "could not find 'div#third'" $ QuerySelector "#third"

    void $ runUI (stateOnlyStaticComponent firstState  rendererFunction) unit div1
    void $ runUI (stateOnlyStaticComponent secondState rendererFunction) unit div2
    void $ runUI (stateOnlyStaticComponent thirdState  rendererFunction) unit div3

-- | Wraps Halogen types cleanly, so that one gets very clear compiler errors
stateOnlyStaticComponent :: forall state.
                            state
                         -> StateOnlyDynamicRenderer state
                         -> H.Component HH.HTML (Const Void) Unit Void Aff
stateOnlyStaticComponent state dynamicRenderer =
  H.mkComponent
    { initialState: const state
    , render: dynamicRenderer
    , eval: H.mkEval H.defaultEval
    }

selectElement' :: String -> QuerySelector -> Aff HTMLElement
selectElement' errorMessage query = do
  maybeElem <- selectElement query
  maybe (throwError (error errorMessage)) pure maybeElem
