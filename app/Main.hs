module Main where

import           Calamity
import           Calamity.Cache.InMemory
import           Calamity.Commands
import           Calamity.Commands.Context (useFullContext)
import           Calamity.Metrics.Noop
import           Control.Monad
import           Data.Default
import           Data.Maybe
import           Data.Text                 (Text)
import qualified Data.Text                 as T
import qualified Di
import           DiPolysemy
import           Optics
import qualified Polysemy                  as P

main :: IO ()
main = Di.new $ \di ->
  void
  . P.runFinal
  . P.embedToFinal @IO
  . runDiToIO di
  . runCacheInMemory
  . runMetricsNoop
  . useFullContext
  . useConstantPrefix "!"
  . runBotIO (BotToken "<your token here>") defaultIntents
  $ do
    info @Text "Setting up commands and handlers..."
    react @'MessageCreateEvt $ \(msg, _usr, _member) -> do
      when ("Haskell" `T.isInfixOf` (msg ^. #content)) $
        void . invoke $ CreateReaction msg msg (UnicodeEmoji "😄")

    react @'MessageUpdateEvt $ \(_oldMsg, newMsg, _user, _member) -> do
      void . tell @Text newMsg $ "Hey! I saw that!"

    addCommands $ do
      helpCommand
      command @'[Int, Maybe GuildChannel] "slowmode" $ \ctx seconds mchan -> do
        let cid = maybe (ctx ^. #channel % to getID) getID mchan :: Snowflake Channel
        void . invoke $ ModifyChannel cid $ def
          & #rateLimitPerUser ?~ seconds
        void . invoke $
          CreateReaction (ctx ^. #channel) (ctx ^. #message) (UnicodeEmoji "✅")
