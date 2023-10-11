module Page.Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg -> List ( Html msg )
view h =
    [ nav [ class "container-fluid" ]
          [ ul []
                [ li [] [ a [ href "/" ] [ text "Home" ] ]
                , li [] [ a [ href "/config" ] [ text "Config" ] ]
                ]
          ]
    , main_ [ class "container" ] [ section [] (h :: []) ]
    ]
