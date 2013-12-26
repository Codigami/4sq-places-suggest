//
//  JFFoursquarePlacesAutocompleteQuery.h
//  JFFoursquareAutoCompletion
//
//  Created by siddarth chaturvedi on 18/12/13.
//  Copyright (c) 2013 JustUnfollow. All rights reserved.
//

#import <Foundation/Foundation.h>

//App specific details
//Use your foursquare client id and client secret.
#define CLIENT_ID     @"XXXX"
#define CLIENT_SECRET @"XXXX"

//Foursquare query related paramters
#define GLOBAL        @"global"
#define API_VERSON    20131016

typedef void (^JFFoursquarePlacesAutocompleteCompletionHandler)(NSArray *places, NSError *error);

@interface JFFoursquarePlacesAutocompleteQuery : NSObject

/*!
Paramter that constrints on user search result counts.
 */
@property (nonatomic, assign) NSInteger limit;

/*!
 Paramter that constraints results to within many meters of the specified location.
 */
@property (nonatomic, assign) NSInteger radius;

/*!
 Paramter that is a search term to be applied against titles. Must be at least 3 characters long.
 */
@property (nonatomic, assign) NSString* queryString;

/*!
 Paramter that defines whether results will be limited to a particular locality or global.
 */
@property (nonatomic, assign) NSString* intent;

/*!
  Altitude of the user's location, in meters.
 */
@property (nonatomic, assign) double altitude;

/*!
 Accuracy of the user's altitude, in meters.
 */
@property (nonatomic, assign) double altitudeAccuracy;

/*!
 Accuracy of latitude and longitude, in meters.
 */
@property (nonatomic, assign) double lat_Long_Accuracy;

/*!
 A string naming a place in the world that is nearby to current loction of the user;
 */
@property (nonatomic, assign) NSString* nearString;

/*!
 Paramter that defines client Id.
 */
@property (nonatomic, assign) NSString* clientId;

/*!
 Paramter that defines client secret.
 */
@property (nonatomic, assign) NSString* clientSecret;

/*!
 Contains the latitude value of that place.
 */
@property (nonatomic, assign) double latitude;

/*!
 Contains the longitude value of that place.
 */
@property (nonatomic, assign) double longitude;

/*!
 Contains the longitude value of that place.
 */
@property (nonatomic, assign) int apiVersion;

/**
 * Gives back the JFFoursquarePlacesAutocompleteQuery  object.
 *
 * @return JFFoursquarePlacesAutocompleteQuery instance.
 */
+ (JFFoursquarePlacesAutocompleteQuery *)query ;

/*!
 Pulls down places that match the query. If -fetchPlaces is called twice, the first request will be cancelled and the request will be re-issued using the current property values.
 */
- (void)fetchPlaces:(JFFoursquarePlacesAutocompleteCompletionHandler)completionHandler;

@end
