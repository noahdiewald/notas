module Data.Config exposing
    ( Config
    , Direction(..)
    , RemoteDB
    , decoder
    , defaultDB
    , directionToString
    , encoder
    , stringToDirection
    )

import Json.Decode as D
import Json.Encode as E
import Json.Encode.Extra as Ex


type alias Config =
    { databases : List RemoteDB }


type alias RemoteDB =
    { url : String
    , username : Maybe String
    , password : Maybe String
    , live : Bool
    , retry : Bool
    , direction : Direction
    }


type Direction
    = To
    | From
    | Sync
    | None


defaultDB : RemoteDB
defaultDB =
    { url = ""
    , username = Nothing
    , password = Nothing
    , live = False
    , retry = False
    , direction = To
    }


encoder : Config -> String
encoder c =
    E.encode 0 (configE c)


configE : Config -> E.Value
configE c =
    E.object
        [ ( "databases", E.list remotedbE c.databases ) ]


remotedbE : RemoteDB -> E.Value
remotedbE r =
    E.object
        [ ( "url", E.string r.url )
        , ( "username", Ex.maybe E.string r.username )
        , ( "password", Ex.maybe E.string r.password )
        , ( "live", E.bool r.live )
        , ( "retry", E.bool r.retry )
        , ( "direction", E.string (directionToString r.direction) )
        ]


decoder : String -> Result String Config
decoder s =
    case D.decodeString configD s of
        Err e ->
            Err (D.errorToString e)

        Ok config ->
            Ok config


configD : D.Decoder Config
configD =
    D.map Config (D.field "databases" (D.list remotedbD))


remotedbD : D.Decoder RemoteDB
remotedbD =
    D.map6 RemoteDB
        (D.field "url" D.string)
        (D.field "username" (D.nullable D.string))
        (D.field "password" (D.nullable D.string))
        (D.field "live" D.bool)
        (D.field "retry" D.bool)
        (D.field "direction" directionD)


directionD : D.Decoder Direction
directionD =
    D.map stringToDirection D.string


stringToDirection : String -> Direction
stringToDirection s =
    case s of
        "to" ->
            To

        "from" ->
            From

        "sync" ->
            Sync

        _ ->
            None


directionToString : Direction -> String
directionToString d =
    case d of
        To ->
            "to"

        From ->
            "from"

        Sync ->
            "sync"

        _ ->
            "none"
