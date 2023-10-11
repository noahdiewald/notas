module Page.Config.Form exposing
    ( Model
    , Msg(..)
    , init
    , view
    )

import Form exposing (Form)
import Form.View
import Html exposing (..)
import Data.Config
    exposing
        ( Config
        , Direction(..)
        , RemoteDB
        , defaultDB
        , directionToString
        , stringToDirection
        )
import Url


type alias Model =
    Form.View.Model InputConfig


type Msg
    = FormChanged Model
    | Submit Config


type alias InputDatabase =
    { url : String
    , username : String
    , password : String
    , live : Bool
    , retry : Bool
    , direction : Direction
    }


type alias InputConfig =
    { databases : List InputDatabase }


init : Config -> Model
init c =
    Form.View.idle <| fromConfig c


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Remote Databases" ]
        , Form.View.asHtml
            { onChange = FormChanged
            , action = "Save"
            , loading = "Loading..."
            , validation = Form.View.ValidateOnBlur
            }
            form
            model
        ]


form : Form InputConfig Msg
form =
    Form.succeed (\values -> Submit (Config values))
        |> Form.append
            (Form.list
                { default = fromDatabase defaultDB
                , value = .databases
                , update = \value values -> { values | databases = value }
                , attributes =
                    { label = "Databases"
                    , add = Just "Add Remote Database"
                    , delete = Just "Remove"
                    }
                }
                databaseForm
            )


databaseForm : Int -> Form InputDatabase RemoteDB
databaseForm _ =
    Form.succeed RemoteDB
        |> Form.append urlField
        |> Form.append (Form.optional usernameField)
        |> Form.append (Form.optional passwordField)
        |> Form.append liveField
        |> Form.append retryField
        |> Form.append directionField


urlField : Form InputDatabase String
urlField =
    Form.textField
        { parser = urlParser
        , value = .url
        , update = \value values -> { values | url = value }
        , error = always Nothing
        , attributes =
            { label = "Database URL"
            , placeholder = "https://example.com/db"
            }
        }


usernameField : Form InputDatabase String
usernameField =
    Form.textField
        { parser = Ok
        , value = .username
        , update = \value values -> { values | username = value }
        , error = always Nothing
        , attributes =
            { label = "Database Username"
            , placeholder = "bob"
            }
        }


passwordField : Form InputDatabase String
passwordField =
    Form.textField
        { parser = Ok
        , value = .password
        , update = \value values -> { values | password = value }
        , error = always Nothing
        , attributes =
            { label = "Database Password"
            , placeholder = "1234"
            }
        }


liveField : Form InputDatabase Bool
liveField =
    Form.checkboxField
        { parser = Ok
        , value = .live
        , update = \value values -> { values | live = value }
        , error = always Nothing
        , attributes =
            { label = "Live (Continuous) Replication" }
        }


retryField : Form InputDatabase Bool
retryField =
    Form.checkboxField
        { parser = Ok
        , value = .retry
        , update = \value values -> { values | retry = value }
        , error = always Nothing
        , attributes =
            { label = "Retry Replication on Failure" }
        }


directionField : Form InputDatabase Direction
directionField =
    Form.selectField
        { parser =
            \value ->
                case stringToDirection value of
                    None ->
                        Err "Specify a valid direction"

                    out ->
                        Ok out
        , value = \values -> directionToString values.direction
        , update =
            \value values ->
                { values | direction = stringToDirection value }
        , error = always Nothing
        , attributes =
            { label = "Direction of Replication"
            , placeholder = "choose one"
            , options =
                [ ( "to", "Send to remote" )
                , ( "from", "Receive from remote" )
                , ( "sync", "Sync with remote" )
                ]
            }
        }


urlParser : String -> Result String String
urlParser s =
    case Url.fromString s of
        Nothing ->
            Err "Invalid URL"

        Just _ ->
            Ok s


toConfig : InputConfig -> Config
toConfig ic =
    { databases = List.map toDatabase ic.databases }


toDatabase : InputDatabase -> RemoteDB
toDatabase idb =
    { url = idb.url
    , username = stringToMaybe idb.username
    , password = stringToMaybe idb.password
    , live = idb.live
    , retry = idb.retry
    , direction = idb.direction
    }


fromConfig : Config -> InputConfig
fromConfig c =
    { databases = List.map fromDatabase c.databases }


fromDatabase : RemoteDB -> InputDatabase
fromDatabase db =
    { url = db.url
    , username = maybeToString db.username
    , password = maybeToString db.password
    , live = db.live
    , retry = db.retry
    , direction = db.direction
    }


stringToMaybe : String -> Maybe String
stringToMaybe s =
    case s of
        "" ->
            Nothing

        _ ->
            Just s


maybeToString : Maybe String -> String
maybeToString s =
    Maybe.withDefault "" s
