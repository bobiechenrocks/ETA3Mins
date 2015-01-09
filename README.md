# ETA3Mins
An iOS application using Twilio API to send SMS when approaching target locations.

## Motivation
Every time I go to pick up my wife at her office, I have to literally click some button on my phone to really dial her number or send her a short message. This is definitely not encouraged. So I started this project.

## How it works
1. Setup destination and ETA
 - Specify your destination on a map view.
 - Use the slider to specify estimated time of arrival to the destination you specified.
2. Setup phone number and SMS message to be sent.
3. All set? click "Start" and begin the tracking.
4. An SMS message will be sent to the phone number when you hit the destination region.

## Tracking the "Region"
 - Once the tracking starts, there will be a "region" with {center (latitude and longitude), radius (meters)} being added into the monitoring list of the CLLocationManager.
 - The CLLocationManager will constantly update user location until it hits/enters the monitored region.
 - Once the region is hit, a server API (http://bobie-twilio.appspot.com/etaTwiMinutes) will be triggered with the phone number and SMS message as the HTTP POST payload. This server API will use my Twilio account (bchen@twilio.com) to send an SMS message to the number specified.

## Require Location Service and Background Permission
 - In order to track user location, the user will be prompted with an alert dialog for permission to enable location service.
 - In case to keep the application tracking even the app is not in foreground, the app will be operating in the background.

## Save & Load
 This should be pretty straightforward on the UI/UX as you can see.
