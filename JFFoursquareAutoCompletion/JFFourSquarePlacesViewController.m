//
//  JFFourSquarePlacesViewController.m
//  JFFoursquareAutoCompletion
//
//  Created by siddarth chaturvedi on 19/12/13.
//  Copyright (c) 2013 JustUnfollow. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "JFFourSquarePlacesViewController.h"
#import "JFFoursuareAutocompletePlace.h"
#import "JFFoursquarePlacesAutocompleteQuery.h"

@interface JFFourSquarePlacesViewController ()

@property (weak, nonatomic) IBOutlet MKMapView                             *mapView;
@property (weak, nonatomic) IBOutlet UITableView                           *tableView;
@property (weak, nonatomic) IBOutlet UITextField                           *inputTextField;
@property (weak, nonatomic) IBOutlet UIButton                              *closeButton;
@property (weak, nonatomic) IBOutlet UIButton                              *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView                           *inputTextFieldImageView;

@property (strong, nonatomic) NSMutableArray                               *searchResultPlaces;
@property (strong, nonatomic) JFFoursquarePlacesAutocompleteQuery          *searchQuery;
@property (strong, nonatomic) MKPointAnnotation                            *selectedAnnotation;
@property (strong, nonatomic) JFFoursuareAutocompletePlace                 *selectedPlace;

@end

@implementation JFFourSquarePlacesViewController

@synthesize searchQuery = _searchQuery;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Creating a query object with approparite default values.
        _searchQuery = [[JFFoursquarePlacesAutocompleteQuery alloc] init];
        self.inputTextField.delegate = self;
        
        //Default values of lat ,long delats.
        //That will defines the zoom level of the map.
        self.latitudeDelta = 0.2;
        self.lonitudeDelta = 0.2;
    }
    return self;
}

//Method for setting the basic UI.
- (void)setUI {
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.alpha = 0.9;
    imageView.image = [[UIImage imageNamed:@"white_graph_box_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 15.0f, 5.0f, 5.0f)];
    [self.tableView setBackgroundView:imageView];
    
    self.inputTextFieldImageView.image = [[UIImage imageNamed:@"bg_location_text_field.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [self.inputTextField setFont:[UIFont fontWithName:@"Meta-Normal" size:20]];
    self.inputTextField.textColor = [self colorFromHexString:@"#555555"];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setUI];
    
    //Gesture recognizer for making a selection on the Map.
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(foundTap:)];
    lpgr.minimumPressDuration = 1.0;  //user must press for 1 seconds
    [self.mapView addGestureRecognizer:lpgr];
	
    // Adding a "textFieldDidChange" notification method to the text field control.
    [self.inputTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResultPlaces count];
}

- (JFFoursuareAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return [self.searchResultPlaces objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"JFFoursuareAutocompletePlaceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.textLabel setFont:[UIFont fontWithName:@"Meta-Normal" size:14]];
    cell.textLabel.textColor = [self colorFromHexString:@"#363636"];
    JFFoursuareAutocompletePlace *autoCompleteplace = (JFFoursuareAutocompletePlace*)[self placeAtIndexPath:indexPath];
    cell.textLabel.text = [autoCompleteplace placeDiscription];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Getting the place and adding annottaion on map for that.
    JFFoursuareAutocompletePlace *place = [self placeAtIndexPath:indexPath];
    CLLocationCoordinate2D locationCordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude);
    self.selectedPlace = place;
    
    //Hide the tableview and set the text of textfield.
    self.tableView.hidden = YES;
    self.inputTextField.text = place.name;
    [self.inputTextField resignFirstResponder];
    
    //Adding annotation to autocomplete place on the map.
    [self addPlacemarkAnnotationToMap:locationCordinate addressString:place.name];
    [self recenterMapToPlacemark:locationCordinate];
}

#pragma mark - UITextField deleagtes
- (void)handleSearchForSearchString:(NSString *)searchString {
    
    self.searchQuery.queryString = searchString;
    //Calling the Autocompletion API.
    [self.searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            //If Error show Alert. Uncomment it.
            JFPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        } else {
            if(places.count > 0) {
                //If Autocomplete places are there show results in tableview.
                self.tableView.hidden = NO;
                self.searchResultPlaces = [places copy];
                [self.tableView reloadData];
            }
        }
    }];
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self handleSearchForSearchString:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Alert
void JFPresentAlertViewWithErrorAndTitle(NSError *error, NSString *title) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - MKMapview Handling

//Method that will defining the zoom level of the map.
-(void)recenterMapToPlacemark:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = self.latitudeDelta;
    span.longitudeDelta = self.lonitudeDelta;
    region.span = span;
    region.center = coordinate;
    
    [self.mapView setRegion:region];
}

//Method that will add an annotation to map on particular cordinate values.
- (void)addPlacemarkAnnotationToMap:(CLLocationCoordinate2D)coordinate addressString:(NSString *)address {
    [self.mapView removeAnnotation:self.selectedAnnotation];
    self.selectedAnnotation = [[MKPointAnnotation alloc] init];
    self.selectedAnnotation.coordinate = coordinate;
    self.selectedAnnotation.title = [self.selectedPlace placeDiscription];
    [self.mapView addAnnotation:self.selectedAnnotation];
}

- (void) addAnnotationToMap:(CLLocationCoordinate2D)coordinate title:(NSString*)title{
    
    [self.mapView removeAnnotation:self.selectedAnnotation];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coordinate;
    point.title = title;
    self.selectedAnnotation = point;
    [self.mapView addAnnotation:point];
    
    //Create a JFFoursuareAutocompletePlace on each annotation on map.
    self.selectedPlace = [[JFFoursuareAutocompletePlace alloc] init];
    self.selectedPlace.latitude = self.selectedAnnotation.coordinate.latitude;
    self.selectedPlace.longitude = self.selectedAnnotation.coordinate.longitude;
    self.selectedPlace.name = title;
}

//Method that will add annotation to map on a particular location if user long tap on that particular place on the map.
-(void)foundTap:(UITapGestureRecognizer *)recognizer {
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:self.mapView];
        CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        [self addAnnotationToMap:tapPoint title:nil];
    }
}

#pragma mark - Dismiss methods
- (IBAction)close:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    
    //Delegation.
    if([self.delegate respondsToSelector:@selector(JFFourSquarePlacesViewControllerDismissed:)]) {
        [self.delegate JFFourSquarePlacesViewControllerDismissed:self.selectedPlace];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MKMapview delegate.
- (void)mapView:(MKMapView *)mapView
didAddAnnotationViews:(NSArray *)annotationViews {
    [self performSelector:@selector(selectAnnotation)
               withObject:nil afterDelay:0.5];
}

-(void)selectAnnotation {
    [self.mapView selectAnnotation:self.selectedAnnotation animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapViewIn viewForAnnotation:(id <MKAnnotation>)annotation {
    if (mapViewIn != self.mapView || [annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *annotationIdentifier = @"JFFoursquarePlacesAutocompleteAnnotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    return annotationView;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Utility Methods
// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
