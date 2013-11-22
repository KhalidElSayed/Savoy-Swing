//
//  BannerEvent.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "BannerEvent.h"

@implementation BannerEvent

@synthesize title;
@synthesize info;
@synthesize sub_title;
@synthesize location;
@synthesize link;
@synthesize image;
@synthesize day;
@synthesize neighborhood;
@synthesize categories;

-(id)initWithID: (int) banner_id {
    self = [super init];
    if (self) {
        switch (banner_id) {
            case 0:
                
                title = @"Savoy Mondays";
                day = @"Monday";
                info = @"[info]";
                sub_title = @"Savoy Swing Club's own Weekly Swing Dance";
                location = @"Great Hall";
                neighborhood = @"Greenlake";
                categories = @"Lindy Hop, Lessons";
                link = @"http://www.savoyswing.org/mondays/";
                image = @"http://www.savoyswing.org/wp-content/uploads/2013/06/banner_sav_mon_.jpg";
                break;
            case 1:
                title = @"Eastside Stomp";
                day = @"Tuesday";
                info = @"[info]";
                sub_title = @"Kirkland's Premier Swing Central";
                location = @"";
                neighborhood = @"Kirkland";
                categories = @"Lindy Hop, Lessons";
                link = @"http://www.eastsidestomp.com";
                image = @"https://www.savoyswing.org/wp-content/uploads/2013/06/marquee-4.png";
                break;
            case 2:
                title = @"Burn Blue";
                day = @"Tuesday";
                info = @"[info]";
                sub_title = @"";
                location = @"";
                neighborhood = @"Capitol Hill";
                categories = @"Blues";
                link = @"";
                image = @"";
                break;
            case 3:
                title = @"Swing!";
                day = @"Wednesday";
                info = @"[info]";
                sub_title = @"";
                location = @"=";
                neighborhood = @"Capitol Hill";
                categories = @"Lindy Hop, Lessons, 21+";
                link = @"http://www.centuryballroom.com";
                image = @"https://www.savoyswing.org/wp-content/uploads/2013/06/logo2.png";
                break;
            case 4:
                title = @"HepCat Swing Dance";
                day = @"Thursday";
                info = @"[info]";
                sub_title = @"The longest running All Ages Dance in Seattle!";
                location = @"";
                neighborhood = @"Capitol Hill";
                categories = @"Lindy Hop, Lessons";
                link = @"http://www.seattleswing.com";
                image = @"https://www.savoyswing.org/wp-content/uploads/2013/06/russian.jpg";
                break;
            case 5:
                title = @"Back Ally Blues";
                day = @"Thursday";
                info = @"[info]";
                sub_title = @"";
                location = @"";
                neighborhood = @"University Way";
                categories = @"Blues";
                link = @"";
                image = @"";
                break;
            case 6:
                title = @"Eastside Stomp";
                day = @"Friday";
                info = @"[info]";
                sub_title = @"Kirkland's Premier Swing Central";
                location = @"";
                neighborhood = @"Kirkland";
                categories = @"Lindy Hop, Lessons";
                link = @"http://www.eastsidestomp.com";
                image = @"https://www.savoyswing.org/wp-content/uploads/2013/06/marquee-4.png";
                break;
            case 7:
                title = @"Blues Underground";
                day = @"Friday";
                info = @"[info]";
                sub_title = @"Every 1st, 3rd and 4th Friday!";
                location = @"";
                neighborhood = @"Capitol Hill";
                categories = @"Blues, Lessons";
                link = @"http://www.bluesunderground.com";
                image = @"https://www.savoyswing.org/wp-content/uploads/2013/06/blues_underground.jpg";
                break;
            case 8:
                title = @"Swing!";
                day = @"Saturday";
                info = @"[info]";
                sub_title = @"";
                location = @"Century Ballroom";
                neighborhood = @"Capitol Hill";
                categories = @"Lindy Hop, Lessons";
                link = @"http://www.centuryballroom.com";
                image = @"https://www.savoyswing.org/wp-content/uploads/2013/06/logo2.png";
                break;
            case 9:
                title = @"Left Foot Boogie";
                day = @"Saturday";
                info = @"[info]";
                sub_title = @"";
                location = @"";
                categories = @"Lindy Hop, Lessons";
                neighborhood = @"Bothell";
                link = @"http://www.leftfootboogie.com/LeftFootBoogie.com/Home.html";
                image = @"";
                break;
            case 10:
                title = @"Swing!";
                day = @"Sunday";
                info = @"[info]";
                sub_title = @"";
                location = @"Century Ballroom";
                neighborhood = @"Capitol Hill";
                categories = @"Lindy Hop, Lessons";
                link = @"http://www.centuryballroom.com";
                image = @"https://www.savoyswing.org/wp-content/uploads/2013/06/logo2.png";
                break;
            default:
                break;
        }
    }
    return self;
}

@end
