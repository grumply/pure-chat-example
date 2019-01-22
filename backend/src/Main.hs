module Main where

import Pure
import Pure.Server
import Pure.WebSocket as WS

import Shared

import Control.Concurrent
import Control.Monad

data State = State (Username,Chatter,Time)

main :: IO ()
main = inject body (server ()) >> sleep
  where
    sleep = forever (threadDelay (6 * 10 ^ 10))

server = Component $ \self -> def
    { construct = return $ State ("server","Hello, World!",0)
    , render = \_ st -> Server "127.0.0.1" 8081 (\ws -> conn self ws st)
    }

conn ref ws = Component $ \self -> def
    { construct = return ()
    , receive = \(State msg) _ -> notify Shared.clientAPI ws new msg
    , executing = enact ws (impl ref) >> activate ws
    }

impl ref = Impl serverAPI msgs reqs
  where
    msgs = handleSay ref <:> WS.none
    reqs = WS.none

handleSay :: Ref () State -> MessageHandler Say
handleSay ref = awaiting $ do
  (user,message) <- acquire
  now <- liftIO time
  liftIO $ modify_ ref $ \_ _ -> State (user,message,now)
