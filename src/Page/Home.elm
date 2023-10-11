module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , reInit
    , subscriptions
    , update
    , view
    )

import Html exposing (Html, text)
import Data.Config
    exposing
        ( Config
        , Direction
        , RemoteDB
        , directionToString
        )


type alias Model =
    { replications : List Replication }


type alias Replication =
    { db : RemoteDB
    , status : Status
    }


type Status
    = Paused
    | Active
    | Error
    | Inactive


type Msg
    = Nada


init : Config -> Model
init c =
    let
        dbToRepl =
            \db -> Replication db Inactive
    in
    Model <| List.map dbToRepl c.databases


reInit : Model -> ( Model, Cmd Msg )
reInit model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    text "ok"


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )
