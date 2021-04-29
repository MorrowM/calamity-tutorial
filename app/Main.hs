module Main where

import           Calamity
import           Calamity.Cache.InMemory
import           Calamity.Commands
import           Calamity.Metrics.Noop
import           Control.Lens
import           Control.Monad
import           Data.Default
import           Data.Generics.Labels    ()
import           Data.Maybe
import           Data.Text.Lazy          (Text)
import qualified Data.Text.Lazy          as T
import qualified Di
import           DiPolysemy
import qualified Polysemy                as P

main :: IO ()
main = Di.new $ \di ->
  void
  . P.runFinal
  . P.embedToFinal @IO
  . runDiToIO di
  . runCacheInMemory
  . runMetricsNoop
  . useConstantPrefix "!"
  . runBotIO (BotToken "<your token here>") defaultIntents
  $ do
    info @Text "Connected successfully."
    react @'MessageCreateEvt $ \msg -> do
      when ("Haskell" `T.isInfixOf` (msg ^. #content)) $
        void . invoke $ CreateReaction msg msg (UnicodeEmoji "😄")

    react @'MessageUpdateEvt $ \(_oldMsg, newMsg) -> do
      void . tell @Text newMsg $ "Hey! I saw that!"

    addCommands $ do
      helpCommand
      command @'[Int, Maybe GuildChannel] "slowmode" $ \ctx seconds mchan -> do
        let cid = maybe (ctx ^. #channel . to getID) getID mchan :: Snowflake Channel
        void . invoke $ ModifyChannel cid $ def
          & #rateLimitPerUser ?~ seconds
        void . invoke $
          CreateReaction (ctx ^. #channel) (ctx ^. #message) (UnicodeEmoji "✅")
