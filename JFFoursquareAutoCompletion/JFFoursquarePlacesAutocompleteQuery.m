//  JFFoursquarePlacesAutocompleteQuery.m
//  JFFoursquareAutoCompletion
//
//  Created by siddarth chaturvedi on 18/12/13.
//  Copyright (c) 2013 JustUnfollow. All rights reserved.
//

#import "JFFoursquarePlacesAutocompleteQuery.h"
#import "JFFoursuareAutocompletePlace.h"

@interface JFFoursquarePlacesAutocompleteQuery ()

@property (nonatomic, strong) NSURLConnection                                *foursquareConnection;
@property (nonatomic, strong) NSMutableData                                   *responseData;
@property (nonatomic, strong) JFFoursquarePlacesAutocompleteCompletionHandler completionHandler;

@end

@implementation JFFoursquarePlacesAutocompleteQuery

@synthesize limit = _limit;
@synthesize radius = _radius;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize queryString = _queryString;
@synthesize nearString = _nearString;
@synthesize altitude = _altitude;
@synthesize altitudeAccuracy = _altitudeAccuracy;
@synthesize lat_Long_Accuracy = _lat_Long_Accuracy;
@synthesize intent = _intent;
@synthesize clientId = _clientId;
@synthesize clientSecret  = _clientSecret;
@synthesize foursquareConnection = _foursquareConnection;
@synthesize responseData = _responseData;

/**
 * Gives back the JFFoursquarePlacesAutocompleteQuery  object.
 *
 * @return JFFoursquarePlacesAutocompleteQuery instance.
 */
+ (JFFoursquarePlacesAutocompleteQuery *)query {
    return [[self alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        // Setup default property values.
        self.clientId = CLIENT_ID;
        self.clientSecret = CLIENT_SECRET;
        self.intent = GLOBAL;
        self.apiVersion = API_VERSON;
    }
    return self;
}

/**
 * Gives the dicription of query.
 *
 * @return NSString - Represents the qury URL.
 */
- (NSString *)description {
    return [NSString stringWithFormat:@"Query URL: %@", [self foursquareURLString]];
}

/**
 * Method that will form the appropriate foursquare API URL.
 *
 * @return NSString - Represents the qury URL.
 */
- (NSString *)foursquareURLString {
    NSMutableString *url = [NSMutableString stringWithFormat:@"https://api.foursquare.com/v2/venues/suggestCompletion?client_id=%@&client_secret=%@&v=%@&query=%@",
                            self.clientId,
                            self.clientSecret,
                            [NSNumber numberWithInt:self.apiVersion],
                            self.queryString
                            ];
    
    //Paramter that defines whether results will be limited to a particular locality or global.
    if (self.intent) {
        [url appendFormat:@"&intent=%@",self.intent];
    }
    
    //If you able to get lat and lang of the user location then append it to the query to get more specific results.
    if (self.latitude && self.longitude) {
        [url appendFormat:@"&ll=%f,%f", self.latitude, self.longitude];
    }
    
    //Paramter that defines accuracy of latitude and longitude, in meters.
    if (self.lat_Long_Accuracy) {
        [url appendFormat:@"&llAcc=%f", self.lat_Long_Accuracy];
    }
    
    //If you able to get lat and lang of the user location then append it to the query to get more specific results.
    if (self.nearString) {
        [url appendFormat:@"&near=%@", self.nearString];
    }
    
    //Paramter that constrints on user search result counts.
    if (self.limit) {
        [url appendFormat:@"&limit=%ld", (long)self.limit];
    }
    
    //Paramter that constraints results to within many meters of the specified location.
    if (self.radius) {
        [url appendFormat:@"&radius=%ld", (long)self.radius];
    }
    
    //Paramter that defines altitude of the user's location, in meters.
    if (self.altitude) {
        [url appendFormat:@"&alt=%f", self.altitude];
    }
    
    //Paramter that defines accuracy of the user's altitude, in meters.
    if (self.altitudeAccuracy) {
        [url appendFormat:@"&altAcc=%f", self.altitudeAccuracy];
    }
    
    //Well there are hell lot of parameters are avilable for user qurey but here i am mentioning only required ones. You can add it any optional paramerters that you wants your suggeastion completion query.
    //For more details plaese refer https://developer.foursquare.com/docs/venues/suggestcompletion
    
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
}


/**
 * Method for reseting the the url connection and response to nil.
 *
 */
- (void)cleanup {
    self.foursquareConnection = nil;
    self.responseData = nil;
}

/**
 * Method for cancelling the existing url request.
 *
 */
- (void)cancelOutstandingRequests {
    [self.foursquareConnection cancel];
    [self cleanup];
}

/*!
 Pulls down places that match the query. If -fetchPlaces is called twice, the first request will be cancelled and the request will be re-issued using the current property values.
 */
- (void)fetchPlaces:(JFFoursquarePlacesAutocompleteCompletionHandler )completionHandler {
    
    //Caneclling the all existing queries to make a fresh query.
    [self cancelOutstandingRequests];
    self.completionHandler = completionHandler;
    
    //if query string length is less than 3 chracters then avoid the query.
    if(self.queryString.length < 3) {
        //Return nil results. we are not cosidering this as an error.
        self.completionHandler(nil, nil);
        return;
    }
    
    //Making the query.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self foursquareURLString]]];
    self.foursquareConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.responseData = [[NSMutableData alloc] init];
}

#pragma mark -
#pragma mark NSURLConnection Delegate

//Failure handling
- (void)failWithError:(NSError *)error {
    if (self.completionHandler != nil) {
        self.completionHandler(nil, error);
    }
    [self cleanup];
}

//Sucess handling
- (void)succeedWithPlaces:(NSArray *)places {
    NSMutableArray *parsedPlaces = [NSMutableArray array];
    for (id place in places) {
        if([place isKindOfClass:[NSDictionary class]]) {
            [parsedPlaces addObject:[JFFoursuareAutocompletePlace placeFromDictionary:place]];
        }
    }
    if (self.completionHandler != nil) {
        self.completionHandler(parsedPlaces, nil);
    }
    [self cleanup];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.foursquareConnection) {
        [self.responseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connnection didReceiveData:(NSData *)data {
    if (connnection == self.foursquareConnection) {
        [self.responseData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.foursquareConnection) {
        [self failWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection == self.foursquareConnection) {
        
        //Parsing the JSON data.
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
        if (error) {
            [self failWithError:error];
            return;
        }

        //looking for expectec JSON response.
        NSMutableArray *parsedPlaces = [NSMutableArray array];
        if ([response objectForKey:@"response"]) {
            
            NSDictionary *responseDict = [response objectForKey:@"response"];
            NSArray *venues = [responseDict objectForKey:@"minivenues"];
            if(venues) {
                //Getting the palces.
                [self succeedWithPlaces: venues];
            }
            if (self.completionHandler != nil) {
                //Calling the completionHnadler.
                self.completionHandler(parsedPlaces, nil);
            }
            return;
        }
        
        //In case of error pass the errotr object with detailed info eg. code and error description.
        NSDictionary *info = [response objectForKey:@"meta"];
        long code = [[info objectForKey:@"code"] longValue];
        NSString *errorDetails = [info objectForKey:@"errorDetail"];
        [self failWithError:[NSError errorWithDomain:errorDetails code:code userInfo:info]];
   }
}

@end
