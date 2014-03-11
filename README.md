Savoy-Swing
===========

iOS App for Savoy Swing Club

I am testing out different features of other git repositories into one app for Savoy Swing Club to distrubute information for this local nonprofit. I am using the following current projects and frameworks:
  - STTwitter
  - FacebookSDK
  - STableViewController
  - SWReavealViewController
  
I have stored the customer (Savoy Swing Club)'s information locally, and is not presented here for obvious reasons. As is required for SWReveal class, I am using storyboard for segue identifiers, but load all dynamic information through view controllers.

Features:
  - News Feed that acquires the following social media sites and envelopes it into one table for viewing:
    - twitter
    - facebook
    - wordpress (self hosted, and customized)
    
  - Banner Events:
    - Banner Image driven Event with date to display information in calendar
    - Use of Horizontal UITableView to display scrollable dates in a cell

Updates:
  - 11/24/13 Pull to refresh branch ready for debug
  - 12/15/13 Updated Banner Events Wordpress Plugin to conform to optimized data structure
