{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Api.User
    ( UserAPI
    , UserGetAPI
    , UserPostAPI
    , UsersGetAPI
    , getUserLink
    , getUsersLink
    , postUserLink
    , userServer
    ) where

import           Data.Int                    (Int64)
import           Database.Persist.Postgresql (Entity (..), Key, SqlPersistT,
                                              fromSqlKey, insertUnique,
                                              selectFirst, selectList, (==.))
import           Servant

import           Api.Envelope                (Envelope, fromServantError,
                                              success)
import           Config                      (App (..))
import           Database.Models
import           Database.Party              (runDb)
import           Middleware.Session          (SessionState (..), startSession)
import           Utils                       (badRequest, noSessionError,
                                              notFound)

type UsersGetAPI = "users"
    :> Get '[JSON] (Envelope [Entity User])
type UserGetAPI  = "user"
    :> Capture "id" UserId
    :> Get '[JSON] (Envelope (Entity User))
type UserPostAPI = "user"
    :> Vault :> ReqBody '[JSON] NewUser
    :> PostCreated '[JSON] (Headers '[Header "Location" String] (Envelope Int64))

getUsersLink :: (IsElem UsersGetAPI UserAPI, HasLink UsersGetAPI) => MkLink UsersGetAPI
getUsersLink = safeLink (Proxy :: Proxy UserAPI) (Proxy :: Proxy UsersGetAPI)

getUserLink :: (IsElem UserGetAPI UserAPI, HasLink UserGetAPI) => MkLink UserGetAPI
getUserLink = safeLink (Proxy :: Proxy UserAPI) (Proxy :: Proxy UserGetAPI)

postUserLink :: (IsElem UserPostAPI UserAPI, HasLink UserPostAPI) => MkLink UserPostAPI
postUserLink = safeLink (Proxy :: Proxy UserAPI) (Proxy :: Proxy UserPostAPI)

type UserAPI =
        UsersGetAPI :<|> UserGetAPI :<|> UserPostAPI

allUsers :: App (Envelope [Entity User])
allUsers = do
    users <- runDb (selectList [] [])
    return $ success users

singleUser :: UserId -> App (Envelope (Entity User))
singleUser key = do
    maybeUser <- runDb (selectFirst [UserId ==. key] [])
    case maybeUser of
         Nothing ->
            throwError $ fromServantError $ notFound ("User with Id " ++ show (fromSqlKey key) ++ " does not exist")
         Just person ->
            return $ success person

createUser :: Vault -> NewUser -> App (Headers '[Header "Location" String] (Envelope Int64))
createUser vault p = do
    user <- toUser p
    let insertUser = insertUnique user :: SqlPersistT IO (Maybe (Key User))
    maybeNewUserKey <- runDb insertUser
    case maybeNewUserKey of
        Nothing -> throwError $ fromServantError $ badRequest "User was not created, ensure username is unique"
        Just newUserKey -> do
            let key = fromSqlKey newUserKey
            sessionState <- startSession vault key
            case sessionState of
                SessionStarted _ -> do
                    let resource = success key
                        response = addHeader (show $ getUserLink newUserKey) resource
                    return response
                _                -> throwError $ fromServantError noSessionError

userServer :: ServerT UserAPI App
userServer = allUsers :<|> singleUser :<|> createUser
