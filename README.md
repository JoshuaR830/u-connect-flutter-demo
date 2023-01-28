# UNiDAYS Tech
Demo of the UNiDAYS Connect solution for mobile using flutter.

This uses the flutter_appauth package to call the authorize endpoint using PKCE and then the token endpoint to get a valid OAuth token.
Having retrieved this the token can be used to retrieve user info and also institution info.

For demo purposes this information is displayed on a profile page after a user taps Login with UNiDAYS.


## Getting Started

Run `flutter pub get`

Complete the .env file with the client info and endpoints for your OAuth client as specified by .env.example

Connect a device and press f5 to run

You need to ensure that you have registered the return url provided with UNiDAYS.

# Trouble shooting
- Must ensure scopes are a subset of the registered ones
- Must ensure scopes include `openid`
- If institution info fails ensure scopes contains `institution`
- If url fails, try adding a trailing `/`