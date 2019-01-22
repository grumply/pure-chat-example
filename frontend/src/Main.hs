{-# LANGUAGE OverloadedStrings #-}
module Main where

import Pure
import Pure.WebSocket as WS

import Shared

import Data.Maybe

data State = State [(Username,Chatter,Time)]

main :: IO ()
main = clientWS "127.0.0.1" 8081 >>= inject body . app

app :: WebSocket -> View
app = Component $ \self -> def
    { construct = return (State [])
    , executing = do
        ws <- ask self
        _ <- enact ws (Main.client self)
        return ()
    , render = \ws (State ms) ->
        Div <||>
          [ messages ms
          , input ws self
          ]
    }

messages ms =
  Ul <||>
    [ Li <||>
      [ text user
      , "@"
      , toPrettyTime time
      , ": "
      , text message
      ]
    | (user,message,time) <- ms
    ]

input ws app = runPureWithIO (mempty,mempty) $ \ref -> do
  (_,msg) <- getWith ref

  let
    setUsername un = modifyWith ref (\(_,c) -> (un,c))

    setChatter c = modifyWith ref (\(un,_) -> (un,c))

    submit = do
      (user,chatter) <- getWith ref
      let username = if user == mempty then "anon" else user
      putWith ref (user,mempty)
      notify serverAPI ws say (username,chatter)

  return $ chatter setUsername setChatter submit msg

chatter :: (Txt -> IO ()) -> (Txt -> IO ()) -> IO () -> Txt -> View
chatter setUsername setChatter submit msg =
  Div <||>
    [ Input  <| OnInput (withInput setUsername) . Placeholder "Name"
    , Input  <| OnInput (withInput setChatter)  . Placeholder "Message" . Value msg
    , Button <| OnClick (const submit) |>
      [ "Send" ]
    ]

client app = Impl clientAPI msgs reqs
  where
    msgs = handleNew app <:> WS.none
    reqs = WS.none

handleNew :: Ref WebSocket State -> MessageHandler New
handleNew app = awaiting $ do
  m <- acquire
  liftIO $ modify_ app $ \_ (State ms) -> State (m:ms)
