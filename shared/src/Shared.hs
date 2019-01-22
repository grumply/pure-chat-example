{-# LANGUAGE OverloadedStrings, TemplateHaskell #-}
module Shared where

import Pure
import Pure.WebSocket as WS

type Username = Txt
type Chatter = Txt

mkMessage "Say" [t|(Username,Chatter)|]

serverAPI = api msgs reqs
  where
    msgs = say <:> WS.none
    reqs = WS.none

mkMessage "New" [t|(Username,Chatter,Time)|]

clientAPI = api msgs reqs
  where
    msgs = new <:> WS.none
    reqs = WS.none
