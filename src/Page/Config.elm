port module Page.Config exposing
    ( Model
    , Msg(..)
    , init
    , reInit
    , subscriptions
    , update
    , view
    )

import Html exposing (Html)
import Data.Config
    exposing
        ( Config
        , Direction
        , RemoteDB
        , decoder
        , encoder
        )
import Page.Config.Form as Form
    exposing
        ( Model
        , Msg(..)
        , init
        , view
        )


port saveConfig : String -> Cmd msg


type Msg
    = FormMsg Form.Msg


type alias Model =
    { config : Config
    , form : Form.Model
    }


init : Config -> Model
init c =
    { config = c
    , form = Form.init c
    }


reInit : Model -> ( Model, Cmd Msg )
reInit model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Form.view model.form |> Html.map FormMsg


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg (FormChanged form) ->
            ( { model | form = form }, Cmd.none )

        FormMsg (Submit config) ->
            ( { model
                | config = config
                , form = Form.init config
              }
            , saveConfig (encoder config)
            )
