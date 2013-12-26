//
//  JFFoursuareAutocompletePlace.h
//  JFFoursquareAutoCompletion
//
//  Created by siddarth chaturvedi on 18/12/13.
//  Copyright (c) 2013 JustUnfollow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFFoursuareAutocompletePlace : NSObject

/*!
 Contains the human-readable name of the place.
 */
@property (nonatomic, strong) NSString *name;

/*!
 Contains the human-readable adress of the place.
 */
@property (nonatomic, strong) NSString *address;

/*!
 Contains the human-readable name of city of the place.
 */
@property (nonatomic, strong) NSString *city;

/*!
 Contains the human-readable name of the state of the place.
 */
@property (nonatomic, strong) NSString *state;

/*!
 Contains the human-readable name of the country of the place.
 */
@property (nonatomic, strong) NSString *country;

/*!
 Contains the human-readable postalCode of the place.
 */
@property (nonatomic, strong) NSString *postalCode;

/*!
 Contains the latitude value of that place.
 */
@property (nonatomic, assign) double latitude;

/*!
 Contains the longitude value of that place.
 */
@property (nonatomic, assign) double longitude;

/*!
* @return NSString a string which gives place discription conatins place,city and country name etc.
 */
- (NSString *)placeDiscription;

/*!
 @param placeDictionary a dictionary object with proper key values wich contains all relevent information regrading the place location.
 @return JFFoursuareAutocompletePlace a JFFoursuareAutocompletePlace object.
 */
+ (JFFoursuareAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary;

@end
