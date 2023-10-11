module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (Html, div, h1, map, pre, text)
import Page.Config
import Data.Config exposing (decoder, Config)
import Page.Home
import Page.Layout
import Route exposing (Route(..))
import Url


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Route
    , errorModel : String
    , homeModel : Page.Home.Model
    , configModel : Page.Config.Model
    }


type Msg
    = LinkClicked UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Page.Home.Msg
    | ConfigMsg Page.Config.Msg


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            case decoder flags of
                Ok config ->
                    { key = key
                    , url = url
                    , route = Route.parseUrl url
                    , configModel = Page.Config.init config
                    , errorModel = ""
                    , homeModel = Page.Home.init config
                    }

                Err e ->
                    { key = key
                    , url = url
                    , route = Route.NotFound
                    , configModel = Page.Config.init { databases = [] }
                    , errorModel = e
                    , homeModel = Page.Home.init { databases = [] }
                    }
    in
    initCurrentPage model


initCurrentPage : Model -> ( Model, Cmd Msg )
initCurrentPage model =
    case model.route of
        Route.HomePage ->
            let
                ( pageModel, pageCmds ) =
                    Page.Home.reInit model.homeModel
            in
            ( { model | homeModel = pageModel }
            , Cmd.map HomeMsg pageCmds
            )

        Route.ConfigPage ->
            let
                ( pageModel, pageCmds ) =
                    Page.Config.reInit model.configModel
            in
            ( { model | configModel = pageModel }
            , Cmd.map ConfigMsg pageCmds
            )

        Route.NotFound ->
            ( model, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "Wao Tededo Notas del Campo"
    , body = layoutView model
    }


layoutView : Model -> List (Html Msg)
layoutView model =
    Page.Layout.view (currentView model)


currentView : Model -> Html Msg
currentView model =
    case model.route of
        NotFound ->
            notFoundView model

        HomePage ->
            Page.Home.view model.homeModel |> Html.map HomeMsg

        ConfigPage ->
            Page.Config.view model.configModel |> Html.map ConfigMsg


notFoundView : Model -> Html msg
notFoundView model =
    div []
        [ h1 [] [ text "Oops! The page you requested was not found!" ]
        , pre [] [ text model.errorModel ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSpecific =
            case model.route of
                HomePage ->
                    Sub.map
                        HomeMsg
                        (Page.Home.subscriptions model.homeModel)

                ConfigPage ->
                    Sub.map
                        ConfigMsg
                        (Page.Config.subscriptions model.configModel)

                _ ->
                    Sub.none
    in
    Sub.batch [ pageSpecific ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.route ) of
        ( ConfigMsg pageMsg, ConfigPage ) ->
            let
                ( updatePageModel, updateCmd ) =
                    Page.Config.update pageMsg model.configModel
            in
            ( { model | configModel = updatePageModel }
            , Cmd.map ConfigMsg updateCmd
            )

        -- TODO refactor types to avoid the need for this
        ( ConfigMsg _, _ ) ->
            { model | route = NotFound } |> initCurrentPage

        ( HomeMsg pageMsg, HomePage ) ->
            let
                ( updatePageModel, updateCmd ) =
                    Page.Home.update pageMsg model.homeModel
            in
            ( { model | homeModel = updatePageModel }
            , Cmd.map HomeMsg updateCmd
            )

        -- TODO refactor types to avoid the need for this
        ( HomeMsg _, _ ) ->
            { model | route = NotFound } |> initCurrentPage

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            { model | route = newRoute } |> initCurrentPage
