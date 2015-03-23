This is a test project for STRV.

Notes and things to consider:

- I am updating the data whenever the app gets active or when the selected location changes. This could obviously be changed to use NSTimer or to refresh it only if the last update was for instance more than 15 minutes ago, but I think it is quite alright as it is.

- "Today" tab displays some data that might not reflect the icons (e.g. the celsius icon displaying pressure, rain icon displaying humidity), but again, this could be easily changed.

- Optional unwrapping (in some cases) and error handling could be done better (like displaying an alert to the user), but I wanted to keep the code clean and simple, so I am only logging it into the console. There could also be some info when the location services are disabled for this app.

- Graphics don't contain iPhone 3.5 inch screenshots, so I didn't count with that. Therefore the today screen is not displaying all info properly.

- There is a duplicate table cell (forecast and location), but since they are displaying two different objects, I left it like this. There should never be the current location icon when displaying forecast. Again, this could be easily changed by creating a custom XIB file which those two view controllers would share.
