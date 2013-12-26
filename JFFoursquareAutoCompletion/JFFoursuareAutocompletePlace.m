//
//  JFFoursuareAutocompletePlace.m
//  JFFoursquareAutoCompletion
//
//  Created by siddarth chaturvedi on 18/12/13.
//  Copyright (c) 2013 JustUnfollow. All rights reserved.
//

#import "JFFoursuareAutocompletePlace.h"

@implementation JFFoursuareAutocompletePlace

/*!
 @param placeDictionary a dictionary object with proper key values wich contains all relevent information regrading the place location.
 @return JFFoursuareAutocompletePlace a JFFoursuareAutocompletePlace object.
 */
+ (JFFoursuareAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary {
    
    JFFoursuareAutocompletePlace *place = [[self alloc] init];
    
    //Getting the name of the place.
    place.name =  [placeDictionary objectForKey:@"name"];
    
    //Extract the location details dictionary and assigning proper values to its properties.
    NSDictionary *locationDetails = [placeDictionary objectForKey:@"location"];
    place.address = [locationDetails objectForKey:@"address"];
    place.city = [locationDetails objectForKey:@"city"];
    place.state = [locationDetails objectForKey:@"state"];
    place.country = [locationDetails objectForKey:@"country"];
    place.postalCode = [locationDetails objectForKey:@"postalCode"];
    place.latitude = [[locationDetails objectForKey:@"lat"] doubleValue];
    place.longitude = [[locationDetails objectForKey:@"lng"] doubleValue];
    return place;
}

/*!
 * @return NSString a string which gives place discription conatins place,city and country name etc.
 */
- (NSString *)placeDiscription {
    NSMutableString *description = [[NSMutableString alloc] initWithString:self.name];
    if(self.state && ![self.state isEqualToString:@""]) {
        [description appendFormat:@", %@",self.state];
    }
    
    if(self.country && ![self.country isEqualToString:@""]) {
        [description appendFormat:@", %@",self.country];
    }
    return description;
}

@end
