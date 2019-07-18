module Main exposing (..) -- this line is required for Parcel elm-hot HMR file change detection

import Browser
import Browser.Navigation
import Url exposing (Url)
import Html exposing (..)
import Json.Encode as Encode exposing (Value)
import Page exposing (Page, view)
import Page.NotFound as NotFound
import Page.Blank as Blank
import Page.Home as Home
import Page.Browse as Browse
import Page.Search as Search
import Page.Analyze as Analyze
import Page.App as App
import Page.Project as Project
import Page.Sample as Sample
import Page.Campaign as Campaign
import Page.SamplingEvent as SamplingEvent
import Page.Experiment as Experiment
import Page.Contact as Contact
import GAnalytics
import Session exposing (Session)
import Route exposing (Route)
import Config exposing (googleAnalyticsTrackingId)
--import Debug exposing (toString)



main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Search search ->
            Sub.map SearchMsg (Search.subscriptions search)

        Sample sample ->
            Sub.map SampleMsg (Sample.subscriptions sample)

        SamplingEvent samplingEvent ->
            Sub.map SamplingEventMsg (SamplingEvent.subscriptions samplingEvent)

        _ ->
            Sub.none



-- MODEL


type Model
    = Redirect Session
    | NotFound Session
    | Home Home.Model
    | Browse Browse.Model
    | Search Search.Model
    | Analyze Analyze.Model
    | App App.Model
    | Project Project.Model
    | Sample Sample.Model
    | Campaign Campaign.Model
    | SamplingEvent SamplingEvent.Model
    | Experiment Experiment.Model
    | Contact Contact.Model


init : Value -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo (Route.fromUrl url)
--        (Redirect Session.empty) --(Session.fromViewer navKey maybeViewer))
        (Redirect (Session "" Nothing Nothing "" navKey))



-- UPDATE


type Msg
    = HomeMsg Home.Msg
    | BrowseMsg Browse.Msg
    | SearchMsg Search.Msg
    | AnalyzeMsg Analyze.Msg
    | AppMsg App.Msg
    | ProjectMsg Project.Msg
    | SampleMsg Sample.Msg
    | CampaignMsg Campaign.Msg
    | SamplingEventMsg SamplingEvent.Msg
    | ExperimentMsg Experiment.Msg
    | ContactMsg Contact.Msg
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest


toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home home ->
            Home.toSession home

        Browse browse ->
            Browse.toSession browse

        Search search ->
            Search.toSession search

        Analyze analyze ->
            Analyze.toSession analyze

        App app ->
            App.toSession app

        Project project ->
            Project.toSession project

        Sample sample ->
            Sample.toSession sample

        Campaign campaign ->
            Campaign.toSession campaign

        SamplingEvent samplingEvent ->
            SamplingEvent.toSession samplingEvent

        Experiment experiment ->
            Experiment.toSession experiment

        Contact contact ->
            Contact.toSession contact


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just route ->
            let
                ( newModel, newCmd ) =
                    case route of
                        Route.Home ->
                            Home.init session
                                |> updateWith Home HomeMsg model

                        Route.Browse ->
                            Browse.init session
                                |> updateWith Browse BrowseMsg model

                        Route.Search ->
                            Search.init session
                                |> updateWith Search SearchMsg model

                        Route.Analyze ->
                            Analyze.init session
                                |> updateWith Analyze AnalyzeMsg model

                        Route.App ->
                            App.init session
                                |> updateWith App AppMsg model

                        (Route.Project id) ->
                            Project.init session id
                                |> updateWith Project ProjectMsg model

                        (Route.Sample id) ->
                            Sample.init session id
                                |> updateWith Sample SampleMsg model

                        (Route.Campaign id) ->
                            Campaign.init session id
                                |> updateWith Campaign CampaignMsg model

                        (Route.SamplingEvent id) ->
                            SamplingEvent.init session id
                                |> updateWith SamplingEvent SamplingEventMsg model

                        (Route.Experiment id) ->
                            Experiment.init session id
                                |> updateWith Experiment ExperimentMsg model

                        Route.Contact ->
                            Contact.init session
                                |> updateWith Contact ContactMsg model
            in
            ( newModel
            , Cmd.batch
                [ newCmd
                , GAnalytics.send (Route.routeToString route) googleAnalyticsTrackingId -- Google Analytics
                ]
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )

                        Just _ ->
                            ( model
                            , Browser.Navigation.load (Url.toString url) --Browser.Navigation.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                            )

                Browser.External href ->
                    ( model
                    , Browser.Navigation.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( BrowseMsg subMsg, Browse subModel ) ->
            Browse.update subMsg subModel
                |> updateWith Browse BrowseMsg model

        ( SearchMsg subMsg, Search subModel ) ->
            Search.update subMsg subModel
                |> updateWith Search SearchMsg model

        ( AnalyzeMsg subMsg, Analyze subModel ) ->
            Analyze.update subMsg subModel
                |> updateWith Analyze AnalyzeMsg model

        ( AppMsg subMsg, App subModel ) ->
            App.update subMsg subModel
                |> updateWith App AppMsg model

        ( ProjectMsg subMsg, Project subModel ) ->
            Project.update subMsg subModel
                |> updateWith Project ProjectMsg model

        ( SampleMsg subMsg, Sample subModel ) ->
            Sample.update subMsg subModel
                |> updateWith Sample SampleMsg model

        ( CampaignMsg subMsg, Campaign subModel ) ->
            Campaign.update subMsg subModel
                |> updateWith Campaign CampaignMsg model

        ( SamplingEventMsg subMsg, SamplingEvent subModel ) ->
            SamplingEvent.update subMsg subModel
                |> updateWith SamplingEvent SamplingEventMsg model

        ( ExperimentMsg subMsg, Experiment subModel ) ->
            Experiment.update subMsg subModel
                |> updateWith Experiment ExperimentMsg model

        ( ContactMsg subMsg, Contact subModel ) ->
            Contact.update subMsg subModel
                |> updateWith Contact ContactMsg model

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
--        viewer =
--            Session.viewer (toSession model)

        viewPage page toMsg content  =
            let
                { title, body } =
                    Page.view page content
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            Page.view Page.Other Blank.view

        NotFound _ ->
            Page.view Page.Other NotFound.view

        Home subModel ->
            viewPage Page.Home HomeMsg (Home.view subModel)

        Browse subModel ->
            Page.view Page.Browse (Browse.view subModel |> Html.map BrowseMsg)

        Search subModel ->
            Page.view Page.Search (Search.view subModel |> Html.map SearchMsg)

        Analyze subModel ->
            Page.view Page.Analyze (Analyze.view subModel |> Html.map AnalyzeMsg)

        App subModel ->
            Page.view Page.App (App.view subModel |> Html.map AppMsg)

        Project subModel ->
            Page.view Page.Project (Project.view subModel |> Html.map ProjectMsg)

        Sample subModel ->
            Page.view Page.Sample (Sample.view subModel |> Html.map SampleMsg)

        Campaign subModel ->
            Page.view Page.Campaign (Campaign.view subModel |> Html.map CampaignMsg)

        SamplingEvent subModel ->
            Page.view Page.SamplingEvent (SamplingEvent.view subModel |> Html.map SamplingEventMsg)

        Experiment subModel ->
            Page.view Page.Experiment (Experiment.view subModel |> Html.map ExperimentMsg)

        Contact subModel ->
            Page.view Page.Contact (Contact.view subModel |> Html.map ContactMsg)