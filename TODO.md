- [x] Implement custom server session frontend
- [x] Find/implement OAuth2 solution for Spotify authentication
- [x] Investigate [HTML datatype](https://github.com/haskell-servant/servant-lucid/blob/master/src/Servant/HTML/Lucid.hs)
- [x] Figure out if the weird session recreation because of existing authID in
packed session (serversession Core shit) is a problem **(It's not)**
- [x] Speed up Travis builds. Went from 1m15s in JS-land to 5m30s in Haskell-land. (Something isn't being cached between builds...)
- [ ] Add [QuickCheck](https://hackage.haskell.org/package/servant-quickcheck-0.0.2.2/docs/Servant-QuickCheck.html)
to the Spec tests (Which units?)
- [ ] Will [file-embed](https://hackage.haskell.org/package/file-embed) be useful?
- [ ] [Conditional requests](https://developer.spotify.com/web-api/user-guide/#conditional-requests) (Caching)

## Inline TODOs
- [ ] Use this [Headers middleware] for Cache-Control, HTTP-Authenticate on 401, etc. [src/Middleware/Headers.hs](src/Middleware/Headers.hs)
- [x] Refactor this removeFlashMiddleware monstrosity [src/Middleware/Flash.hs](src/Middleware/Flash.hs)
- [ ] Refactor this auth callback monstrosity [src/Api/Auth.hs](src/Api/Auth.hs)
- [x] Make this [Party API base URL] configurable via environment (move to Config?) [src/Utils.hs](src/Utils.hs)
- [ ] Add encompasing middleware that checks the Origin req header **TODO** [src/Middleware/Cors.hs](src/Middleware/Cors.hs)
- [ ] Figure out why this [corsRequireOrigin] doesn't work when deployed [src/Middleware/Cors.hs](src/Middleware/Cors.hs)

## Security

- [ ] Improve CSP support
- [ ] Add HTTPOnly or SecureOnly support to cookies
- [ ] Add CSRF token support?

## Parity with original JS prototype

- [x] Parity with [index (unauthenticated)](https://github.com/chances/chances-party/blob/94ce862cb8fc9ef94b3b8c73c404479c3d86e659/routes/index.js#L8)
- [x] Spotify OAuth2 integration
- [x] Parity with [auth routes](https://github.com/chances/chances-party/blob/94ce862cb8fc9ef94b3b8c73c404479c3d86e659/routes/auth.js)
- [x] Parity with [index (authenticated)](https://github.com/chances/chances-party/blob/94ce862cb8fc9ef94b3b8c73c404479c3d86e659/routes/index.js#L14)
  - [x] Get user data
  - [x] Get user's own playlists
  - [x] Render user data
  - [x] Render user playlists
  - [x] Log Out
- [x] Parity with [playlist endpoint](https://github.com/chances/chances-party/blob/94ce862cb8fc9ef94b3b8c73c404479c3d86e659/routes/index.js#L38)
- [ ] ~~Parity with [search endpoint](https://github.com/chances/chances-party/blob/94ce862cb8fc9ef94b3b8c73c404479c3d86e659/routes/index.js#L71)~~
  - [ ] ~~Add search to [servant-spotify](https://github.com/chances/servant-spotify#readme)~~
    - [ ] ~~For tracks~~
    - [ ] ~~For artists~~
    - [ ] ~~For albums~~
    - [ ] ~~Expose "See more results in Spotify" href~~

_Note: Removed search endpoint task in favor of access token delivery to clients for use with the Spotify Web API on the client side. (The Android client app authenticates with Spotify directly.)_

## New Functionality

- [ ] Add access token delivery endpoint
  - [ ] With refresh option
- [ ] Add timestamp utility functions (autonomously update them)
- [ ] WebSockets streaming data integration
- [ ] Add Guests model
  - JSON blob (Array of):
    - Name
    - Alias (Future use?)
      - Only modifiable by a checked in Guest (guest ID/index stored in session)
    - Check-In Status (_A guest is simply invited by default. A checked in guest is in attendance._)
- [ ] Add Playlist (TrackList) model
  - Fields:
    - JSON blob (Array of):
      - Spotify Track ID
      - Name
      - Artist
      - Contributor name
      - Contributor ID (index in Guest array)
    - Timestamps
- [ ] Add History model
  - Fields:
    - TrackList foreign key
    - Began playing timestamp
    - Timestamps
  - Show duration on frontend?
- [ ] Playback history (History) endpoint _(As TrackList)_
  - [ ] With WebSocket support
- [ ] Add Queue model
  - TrackList foreign key
  -
- [ ] Playback future (Queue) endpoint _(As TrackList)_
  - [ ] With WebSocket support
- [ ] Add a Party Model
  - Fields:
    - Host name (Location/address, scheduled time too? _Facebook inegration?_)
    - Room code (NULL when party has ended)
      - Random four letter combination
    - Ended flag
    - Current Track (Now Playing)
      - NULL or JSON blob:
        - Spotify Track ID
        - Name
        - Artist
        - Contributor name
        - Contributor ID (index in Guest array)
    - Queue foreign key
    - History foreign key
    - Guests foreign key
- [ ] Add Party endpoints
  - [ ] Create
  - [ ] End (Stop/Quit?)
  - [ ] Connect to Facebook event (_Future?_)
- [ ] Add search suggestions (while typing query)?

### Party Host Features

- [ ] Playback
  - [ ] Pick a playlist for a party
  - [ ] Play/pause the party's playlist
  - [ ] Skip the current track
  - [ ] Search to add to queue
  - [ ] State change notifications (WebSockets?)

### Party Guest Features

- [ ] Add Join Party endpoint
  - With Party foreign key
  - Should there be a party list? **No**
  - User facing "room" code for guests to enter (Like Jackbox. _456,976 combinations with 4 letters_)
  - Facebook integration (_Future_)
- [ ] Contribution
  - [ ] Add (suggest) a song
    - [ ] Limit to a maximum limit per timeframe (hour?)
  - [ ] Suggest that a song should be skipped
    - [ ] Require a minimum number of votes (5? fraction of party attendants?)
- [ ] Join a party (_unauthenticated_)
- [ ] Check-In to a Party (_authenticated_)
  - [ ] OAuth2 third-party login schemes
    - [ ] Facebook
    - [ ] Google
    - [ ] Twitter
    - [ ] GitHub
    - Others?

## Compliance with Spotify Developer Terms of Use

- [Spotify Developer Terms of Use](https://developer.spotify.com/developer-terms-of-use/)
- [Design Guidelines](https://developer.spotify.com/design/)

### Specific sections

- Section V: Users & Data
  - [ ] Obtain explicit consent for users' email address?
    - "5. You shall not email Spotify users unless you obtain their explicit consent or obtain their email address and permission through means other than Spotify."

  - [ ] Delete all Spotify Content upon logout/inactivity
    - "7. Spotify user data can be cached only for operating your SDA. If a Spotify user logs out of your SDA or becomes inactive, you will delete any Spotify Content related to that user stored on your servers. To be clear, you are not permitted to store Spotify Content related to a Spotify user or otherwise request user data if a Spotify user is not using your SDA."

  - [ ] Add 'Delete Account' functionality.
    - "8. You must provide all users with a working mechanism to disconnect their Spotify Account from your application at any time and provide clear instructions on how to do so. Further, when a user disconnects their Spotify account, you agree to delete and no longer request or process any of that Spotify user’s data."

  - [ ] Write an **EULA/Terms of Use** and a **Privacy Policy** for Party
    - "10. You must have an end user agreement and privacy policy. Any access, use, processing, and disclosure of Spotify user data shall comply with (i) these Developer Terms; (ii) your end user license agreement; (iii) your privacy policy; and (iv) applicable laws and regulations."
    - See subsection 12 about requirements for EULA/Terms of Use
    - See subsection 13 about requirements for Privacy Policy

## Resource Links

### Authentication

- ~~[servant-auth](https://github.com/plow-technologies/servant-auth)~~
- ~~[authenticate-oauth](https://www.stackage.org/package/authenticate-oauth)~~

_Implemented manually in [servant-spotify](https://github.com/chances/servant-spotify#readme)._
