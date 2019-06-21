module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy, lazy2)

main : Program () Model Msg
main =
  Browser.element
        { init          = \_ -> init
        , view          = view
        -- , view          = cssView
        , update        = update
        , subscriptions = \_ -> Sub.none
        }

css : String
css =
  """
div.question {
  display:       flex;
  width:         100%;
  margin-top:    5px;
  margin-bottom: 5px;
}

div.question label {
  width: 250px;
}

button.active {
  background: peachpuff;
}

button:disabled{
  background: none !important;
}

.answer {
  margin-top: 20px;
  padding:    10px;
  background: #eaeaea;
}
"""

-- HACK: Insert css so we can see a bit what we're doing.
cssView m = div [] [ node "style" [] [ text css ]
                   , view m
                   ]


type alias Model =
  { environment    : Environment
  , language       : Language
  , packageManager : PackageManager
  , framework      : Framework
  , version        : Version
  , os             : OS
  , gpu            : GPU
  }

type Environment
  = MyComputer
  | HostedNotebook


type Language
  = Python27
  | Python35
  | Python36Plus


type Framework
  = TensorFlow
  | PyTorch


type Version
  = Stable
  | Newest


type OS
  = Linux
  | Windows
  | Mac
  | NA


type GPU
  = NoGPU   -- Different from `Nothing`
  | Cuda9
  | Cuda10

type PackageManager
  = Conda


defaultModel : Model
defaultModel =
    { environment    = HostedNotebook
    , language       = Python36Plus
    , packageManager = Conda 
    , framework      = TensorFlow
    , version        = Stable
    , os             = Linux
    , gpu            = NoGPU
    }


init : ( Model, Cmd Msg )
init =
  ( defaultModel
  , Cmd.none
  )


type Msg
    = NoOp
    | SetEnvironment    Environment
    | SetLanguage       Language
    | SetFramework      Framework
    | SetVersion        Version
    | SetOS             OS
    | SetGPU            GPU
    | SetPackageManager PackageManager


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetEnvironment e ->
            ( { model | environment = e }, Cmd.none )

        SetLanguage l ->
            ( { model | language = l }, Cmd.none )

        SetFramework f ->
            ( { model | framework = f }, Cmd.none )

        SetVersion v ->
            ( { model | version = v }, Cmd.none )

        SetOS o ->
            let gpu = if o == Mac then NoGPU else model.gpu
            in ( { model | os = o, gpu = gpu }, Cmd.none )

        SetGPU g ->
            ( { model | gpu = g }, Cmd.none )

        SetPackageManager p ->
            ( { model | packageManager = p }, Cmd.none )


q model question opts =
  div [ class "question" ] 
    [ label [] [ text question ]
    , div   [ class "options" ] ( opts model )
    ]


view : Model -> Html Msg
view model =
    div
        [ id "widget" ]
        [ section [ class "questions" ] 
          [ q model "I want to start deep learning on ..." environmentOptions
          , q model "I'll be using ..."                    languageOptions
          , q model "and installing the libraries ..."     packageManagerOptions
          , q model "For framework I'd like to use ..."    frameworkOptions
          , q model "With version ..."                     versionOptions
          , q model "And I'm using ... "                   osOptions
          , q model "With ..."                             gpuOptions
          ]
        , section [ class "answer" ]
          [ answer model ]
        ]


-- TODO: PyTorch, Windows, Py27 Unsupported
answer : Model -> Html Msg
answer m = 
  case ( m.environment,  m.os, (m.language, m.framework) )
        of
         ( HostedNotebook, _, _) -> colab m
         --
         ( MyComputer, Windows, (Python27, PyTorch)) -> unsupported
         ( MyComputer, _      , _                  ) -> conda m


unsupported
  = div [ class "unsupported" ]
      [ h5 [] [ text "Unsupported" ]
      , p  [] [ text "Unfortunately, this configuration is unsupported!" ]
      ]

-- Three sections:
--
-- # Installation
--
-- # Example program
--
-- # Read more

conda : Model -> Html Msg
conda m =
  let
      envName   = if m.framework == TensorFlow then "tf" else "torch"

      pyVersion = case m.language of
                    Python27     -> "python=2.7"
                    Python35     -> "python=3.5"
                    Python36Plus -> "\"python>=3.6\""

      create   = "conda create -n " ++ envName ++ " " ++ pyVersion
      activatePrefix = if m.os == Windows then "" else "source "
      activate       = activatePrefix ++ "activate " ++ envName
      install        = "conda install "   ++ package

      -- TODO: Is TensorFlow Python Version Specific?!?!
      package = case (m.framework, m.gpu, (m.version, m.os)) of
                  (TensorFlow, NoGPU , (Stable, _)) -> "tensorflow"
                  (TensorFlow,     _ , (Stable, _)) -> "tensorflow-gpu"
                  (TensorFlow, NoGPU , (Newest, _)) -> "tensorflow==2.0.0-beta1"
                  (TensorFlow,     _ , (Newest, _)) -> "tensorflow-gpu==2.0.0-beta1"
                  (PyTorch,        _ , (_, Mac   )) -> "pytorch torchvision -c pytorch"
                  (PyTorch,        _ , (_, _     )) -> "pytorch-cpu torchvision-cpu -c pytorch"

      lines = [ create, activate, install ]
      more  = case m.framework of
                TensorFlow -> "https://www.tensorflow.org/install"
                PyTorch    -> "https://pytorch.org/get-started/locally/"
  in
    div []
      ([
        h5 [] [ text "Installation" ]
      , p  [] [ text <| "At a terminal, use the following to make a new conda "
                        ++ "environment, activate it and install the right libraries."
             ]
      , pre [] [ text <| String.join "\r\n" lines ]
      ]
      ++ exampleCode m
      ++ [ h5 [] [ text "Read more" ]
         , p [] [ text <| "Check out the documentation for this library: <"
                , a [ href more ] [ text more ]
                , text ">."
                ]
         ]
      )


ln m = case m.language of
        Python27 -> "Python 2"
        _        -> "Python 3"


-- | The string describign the CoLab environment set up.
colab : Model -> Html Msg
colab m = 
  let
    link = case (m.framework, m.version) of
            (TensorFlow, Stable) -> "https://colab.research.google.com/drive/1nl1fV14qsbVYJJdJ-7VwCMiQMr48fKuY"
            (TensorFlow, Newest) -> "https://colab.research.google.com/drive/1wWh1s-wwxUB5RkmJAz5WY6Nc4d-kYuw9"
            (PyTorch,    _     ) -> "https://colab.research.google.com/drive/1S8MulJ_mVoqbVmtflHDBIgw7O0P68R57"
  in
    div []
      -- Header
      ([
        h5 [] [ text "Installation" ]
      , p [] [ text "We recommend "
             , a [ href "https://colab.research.google.com/" ] [ text "Google Colab!" ]
             ]
      --
      -- Programming language
      , p [] [ text <| "From the menu, pick `Runtime` -> "
                       ++ "`Change Runtime Type` and pick `" 
                       ++ (ln m) ++ "` from the dropdown."
             ]
      --
      -- PyTorch or TensorFlow
      ]
      ++ exampleCode m
      ++ [ p [] [ a [ href link ]
                     [ text "Click here" ]
                 , text " to view this program in Colab now (you'll need to sign in to a Google account to run it.)"
                 ]
         ]
      --
      ++ [ h5 [] [ text "Read more" ]
         , p [] [ text "You can find more details about Google Colaboratory here: "
                , a [ href "https://colab.research.google.com/"] [ text "Google Colab" ]
                , text "."
                ]
         ]
      )

-- | Two HTML elements writing out a code sample to be executed in the various
-- environments.
exampleCode : Model -> List (Html Msg)
exampleCode m = 
  [ h5  [] [ text "Example Program" ]
  , p [] [ text "This code snippet demonstrates a simple mathematical computation in this framework." ]
  , exampleProgram m.environment m.framework m.language m.version
  ]


-- | The lines of a valid python program for the given environment, wrapped in a 'pre' tag.
exampleProgram : Environment -> Framework -> Language -> Version -> Html Msg
exampleProgram e f l v = 
  let
    lines = case (f, l, v) of
            (TensorFlow, _, Stable) ->
              -- TensorFlow Version < 1.14
              String.lines """# For TensorFlow version < 1.14
import tensorflow as tf
print("TensorFlow version: " + tf.__version__)

y = tf.constant(5)
x = tf.add(y, 2) ** 2

with tf.Session() as s:
  print( x.eval() )
"""


            (TensorFlow, _, Newest) ->
              -- TensorFlow Version 2
              let bangInstall = 
                    [ "# First, you'll need to install the latest TensorFlow"
                    , "! pip install -q tensorflow-gpu==2.0.0-beta1"
                    , ""
                    ]

                  prefix = if e == MyComputer then [] else bangInstall

              in prefix ++ String.lines """# For TensorFlow version > 2
import tensorflow as tf
print("TensorFlow version: " + tf.__version__)

@tf.function
def f(y=5):
  x = (y + 2) ** 2
  return x

print(f().numpy())
"""

            (PyTorch, _, _) ->
              String.lines """import torch

y = torch.tensor(5)
x = torch.add(y, 2) ** 2
print(x.numpy())
"""
 in
  pre [] [ text <| String.join "\r\n" lines ]


-- TODO:
--  Add example programs for each of the options

ma : Bool -> Attribute Msg
ma cond = class <| if cond then "active" else ""


packageManagerOptions m = 
  [ button [ ma (m.packageManager == Conda)
           , disabled (m.environment == HostedNotebook)
           , onClick (SetPackageManager <| Conda)  ]
           [ text "In a Conda environment"  ]

  -- , button [ ma (m.packageManager == SystemWide)
  --          , disabled (m.environment == HostedNotebook)
  --          , onClick (SetPackageManager <| SystemWide)  ]
  --          [ text "System-wide"   ]
  ]


gpuOptions m = 
  [ button [ ma (m.gpu == NoGPU)
           , disabled (m.environment == HostedNotebook || m.os == Mac)
           , onClick (SetGPU <| NoGPU) ] 
           [ text "No GPU"   ]

  , button [ ma (m.gpu == Cuda9)
           , disabled (m.environment == HostedNotebook || m.os == Mac)
           , onClick (SetGPU <| Cuda9) ]
           [ text "A GPU and Cuda v9"  ]

  , button [ ma (m.gpu == Cuda10)
           , disabled (m.environment == HostedNotebook || m.os == Mac)
           , onClick (SetGPU <| Cuda10) ]
           [ text "A Gpu and Cuda v10" ]
  ]


osOptions m = 
  [ button [ ma (m.os == Linux)
           , disabled (m.environment == HostedNotebook)
           , onClick (SetOS <| Linux) ]
           [ text "Linux"   ]

  , button [ ma (m.os == Windows)
           , disabled (m.environment == HostedNotebook)
           , onClick (SetOS <| Windows) ]
           [ text "Windows" ]

  , button [ ma (m.os == Mac)
           , disabled (m.environment == HostedNotebook)
           , onClick (SetOS <| Mac) ]
           [ text "Mac"     ]
  ]


frameworkOptions m = 
  [ button [ ma (m.framework == TensorFlow)
           , onClick (SetFramework <| TensorFlow) ] 
           [ text "TensorFlow" ]

  , button [ ma (m.framework == PyTorch)
           , onClick (SetFramework <| PyTorch) ]
           [ text "PyTorch"    ]
  ]


versionOptions m = 
  [ button [ ma (m.version == Stable)
           , disabled (m.framework == PyTorch)
           , onClick (SetVersion <| Stable)  ]
           [ text "Stable"   ]

  , button [ ma (m.version == Newest)
           , disabled (m.framework == PyTorch)
           , onClick (SetVersion <| Newest)  ]
           [ text "Newest"  ]
  ]


languageOptions m = 
  [ button [ ma (m.language == Python27)
           , onClick (SetLanguage <| Python27) ]
           [ text "Python 2.7"  ]

  , button [ ma (m.language == Python35)
           , onClick (SetLanguage <| Python35) ]
           [ text "Python 3.5"  ]

  , button [ ma (m.language == Python36Plus)
           , onClick (SetLanguage <| Python36Plus) ]
           [ text "Python 3.6+" ]
  ]


environmentOptions m = 
  [ button [ ma (m.environment == MyComputer)
           , onClick (SetEnvironment <| MyComputer) ]
           [ text "My computer" ]

  , button [ ma (m.environment == HostedNotebook)
           , onClick (SetEnvironment <| HostedNotebook) ]
           [ text "A hosted notebook" ]

  ]

