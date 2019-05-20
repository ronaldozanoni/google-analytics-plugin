//UniversalAnalyticsPlugin.m
//Created by Daniel Wilson 2013-09-19

#import "UniversalAnalyticsPlugin.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAIEcommerceFields.h"

#define DEFAUlT_TRACKER_NAME @"default"

@implementation UniversalAnalyticsPlugin

- (void) pluginInitialize
{
    _debugMode = false;
    _customDimensions = nil;
    _trackers = nil;
}

- (void) startTrackerWithId: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString* accountId = [command.arguments objectAtIndex:0];
        NSNumber* dispatchPeriod = [command.arguments objectAtIndex:1];
        NSString* trackerName = [command.arguments objectAtIndex:2];

        if (!_trackers) {
          _trackers = [[NSMutableDictionary alloc] init];
        }

        if ([dispatchPeriod isKindOfClass:[NSNumber class]])
            [GAI sharedInstance].dispatchInterval = [dispatchPeriod doubleValue];
        else
            [GAI sharedInstance].dispatchInterval = 30;

        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:trackerName trackingId:accountId];

        _trackers[trackerName] = tracker;

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (id<GAITracker>) getTrackerFromCommand: (CDVInvokedUrlCommand*) command
                   index: (int *) index
{
  NSString* trackerName = [command.arguments objectAtIndex:index];

  if (!trackerName) {
    trackerName = DEFAUlT_TRACKER_NAME;
  }

  return _trackers[trackerName];
}

- (void) setAllowIDFACollection: (CDVInvokedUrlCommand*) command
{
    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:1];

    if (!tracker) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    tracker.allowIDFACollection = [[command argumentAtIndex:0 withDefault:@(NO)] boolValue];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) addCustomDimensionsToTracker: (id<GAITracker>)tracker
{
    if (_customDimensions) {
      for (NSString *key in _customDimensions.allKeys) {
        NSString *value = [_customDimensions objectForKey:key];

        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myKey = [f numberFromString:key];

        /* NSLog(@"Setting tracker dimension slot %@: <%@>", key, value); */
        [tracker set:[GAIFields customDimensionForIndex:myKey.unsignedIntegerValue]
        value:value];
      }
    }
}

- (void) addCustomDimensionsToProduct: (GAIEcommerceProduct*) product
{
    if (_customDimensions) {
      for (NSString *key in _customDimensions.allKeys) {
        NSString *value = [_customDimensions objectForKey:key];

        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myKey = [f numberFromString:key];

        /* NSLog(@"Setting tracker dimension slot %@: <%@>", key, value); */
        [product setCustomDimension:[GAIFields customDimensionForIndex:myKey.unsignedIntegerValue]
        value:value];
      }
    }
}

- (void) getVar: (CDVInvokedUrlCommand*) command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        id<GAITracker> tracker = [self getTrackerFromCommand:command index:1];

        if (!tracker) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }

        NSString* parameterName = [command.arguments objectAtIndex:0];
        NSString* result = [tracker get:parameterName];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) setVar: (CDVInvokedUrlCommand*) command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        id<GAITracker> tracker = [self getTrackerFromCommand:command index:2];

        if (!tracker) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }

        NSString* parameterName = [command.arguments objectAtIndex:0];
        NSString* parameter = [command.arguments objectAtIndex:1];
        [tracker set:parameterName value:parameter];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) dispatch: (CDVInvokedUrlCommand*) command
{
  [[GAI sharedInstance] dispatch];
}

- (void) debugMode: (CDVInvokedUrlCommand*) command
{
  _debugMode = true;
  [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
}

- (void) setUserId: (CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = nil;
  NSString* userId = [command.arguments objectAtIndex:0];
  id<GAITracker> tracker = [self getTrackerFromCommand:command index:1];

  if (!tracker) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return;
  }

  [tracker set:@"&uid" value: userId];

  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) setAnonymizeIp: (CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = nil;
  NSString* anonymize = [command.arguments objectAtIndex:0];
  id<GAITracker> tracker = [self getTrackerFromCommand:command index:1];

  if (!tracker) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return;
  }

  [tracker set:kGAIAnonymizeIp value:anonymize];

  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) setOptOut: (CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = nil;
  bool optout = [[command.arguments objectAtIndex:0] boolValue];
  id<GAITracker> tracker = [self getTrackerFromCommand:command index:1];

  if (!tracker) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return;
  }

  [[GAI sharedInstance] setOptOut:optout];

  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) setAppVersion: (CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = nil;
  NSString* version = [command.arguments objectAtIndex:0];
  id<GAITracker> tracker = [self getTrackerFromCommand:command index:1];

  if (!tracker) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return;
  }

  [tracker set:@"&av" value: version];

  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) enableUncaughtExceptionReporting: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:1];

    if (!tracker) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    bool enabled = [[command.arguments objectAtIndex:0] boolValue];
    [[GAI sharedInstance] setTrackUncaughtExceptions:enabled];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) addCustomDimension: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSNumber* key = [command.arguments objectAtIndex:0];
    NSString* value = [command.arguments objectAtIndex:1];

    if ( ! _customDimensions) {
      _customDimensions = [[NSMutableDictionary alloc] init];
    }

    _customDimensions[key.stringValue] = value;

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) trackMetric: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:2];

    if (!tracker) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      return;
    }

    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSNumber *key = nil;
        NSString *value = nil;

        if ([command.arguments count] > 0)
            key = [command.arguments objectAtIndex:0];

        if ([command.arguments count] > 1)
            value = [command.arguments objectAtIndex:1];

        [tracker set:[GAIFields customMetricForIndex:[key intValue]] value:value];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) trackEvent: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:5];

    if (!tracker) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      return;
    }

    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString *category = nil;
        NSString *action = nil;
        NSString *label = nil;
        NSNumber *value = nil;

        if ([command.arguments count] > 0)
            category = [command.arguments objectAtIndex:0];

        if ([command.arguments count] > 1)
            action = [command.arguments objectAtIndex:1];

        if ([command.arguments count] > 2)
            label = [command.arguments objectAtIndex:2];

        if ([command.arguments count] > 3)
            value = [command.arguments objectAtIndex:3];

        bool newSession = [[command argumentAtIndex:4 withDefault:@(NO)] boolValue];

        [self addCustomDimensionsToTracker:tracker];

        GAIDictionaryBuilder *builder = [GAIDictionaryBuilder
                        createEventWithCategory: category //required
                        action: action //required
                        label: label
                        value: value];
        if(newSession){
            [builder set:@"start" forKey:kGAISessionControl];
        }
        [tracker send:[builder build]];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }];

}

- (void) trackException: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:2];

    if (!tracker) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      return;
    }

    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString *description = nil;
        NSNumber *fatal = nil;

        if ([command.arguments count] > 0)
            description = [command.arguments objectAtIndex:0];

        if ([command.arguments count] > 1)
            fatal = [command.arguments objectAtIndex:1];

        [self addCustomDimensionsToTracker:tracker];

        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription: description
                        withFatal: fatal] build]];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) trackView: (CDVInvokedUrlCommand*)command
{

    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:3];

    if (!tracker) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      return;
    }

    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString* screenName = [command.arguments objectAtIndex:0];

        [self addCustomDimensionsToTracker:tracker];

        NSString* deepLinkUrl = [command.arguments objectAtIndex:1];
        GAIDictionaryBuilder* openParams = [[GAIDictionaryBuilder alloc] init];

        if (deepLinkUrl && deepLinkUrl != (NSString *)[NSNull null]) {
            [[openParams setCampaignParametersFromUrl:deepLinkUrl] build];
        }

        bool newSession = [[command argumentAtIndex:2 withDefault:@(NO)] boolValue];
        if(newSession){
            [openParams set:@"start" forKey:kGAISessionControl];
        }

        NSDictionary *hitParamsDict = [openParams build];

        [tracker set:kGAIScreenName value:screenName];
        [tracker send:[[[GAIDictionaryBuilder createScreenView] setAll:hitParamsDict] build]];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) trackTiming: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:4];

    if (!tracker) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      return;
    }

    [self.commandDelegate runInBackground:^{
      CDVPluginResult* pluginResult = nil;

      NSString *category = nil;
      NSNumber *intervalInMilliseconds = nil;
      NSString *name = nil;
      NSString *label = nil;

      if ([command.arguments count] > 0)
          category = [command.arguments objectAtIndex:0];

      if ([command.arguments count] > 1)
          intervalInMilliseconds = [command.arguments objectAtIndex:1];

      if ([command.arguments count] > 2)
          name = [command.arguments objectAtIndex:2];

      if ([command.arguments count] > 3)
          label = [command.arguments objectAtIndex:3];

      [self addCustomDimensionsToTracker:tracker];

      [tracker send:[[GAIDictionaryBuilder
                      createTimingWithCategory: category //required
                      interval: intervalInMilliseconds //required
                      name: name
                      label: label] build]];

      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) addProductsToBuilder: (GAIDictionaryBuilder*) builder
                              products: (NSArray *) products
{
    for (NSDictionary *product in products) {
      GAIEcommerceProduct *GAIProduct = [[GAIEcommerceProduct alloc] init];

      [GAIProduct setId: [product objectForKey:@"id"]];
      [GAIProduct setName: [product objectForKey:@"name"]];
      [GAIProduct setCategory: [product objectForKey:@"category"]];
      [GAIProduct setBrand: [product objectForKey:@"brand"]];
      [GAIProduct setVariant: [product objectForKey:@"variant"]];
      [GAIProduct setQuantity: [product objectForKey:@"quantity"]];
      [GAIProduct setPrice: [product objectForKey:@"price"]];
      [GAIProduct setCouponCode: [product objectForKey:@"couponCode"]];

      [self addCustomDimensionsToProduct:GAIProduct];
      [builder addProduct:GAIProduct];
    }
}

- (void) trackStartCheckout: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:2];

    if (!tracker) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      return;
    }

    NSDictionary *checkoutModel = [command.arguments objectAtIndex:0];

    [self.commandDelegate runInBackground:^{
      CDVPluginResult* pluginResult = nil;

      NSString *screenName = nil;

      if ([command.arguments count] > 1)
          screenName = [command.arguments objectAtIndex:1];

      NSDictionary *actionField = [checkoutModel objectForKey:@"actionField"];
      NSArray *products = [checkoutModel objectForKey:@"products"];
      GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];

      [self addProductsToBuilder:builder products: products];

      GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
      [action setAction: kGAIPACheckout];

      if (actionField != nil) {
        NSNumber *step = [actionField objectForKey:@"step"];
        NSString *stepOption = [actionField objectForKey:@"option"];

        if (step != nil) {
          [action setCheckoutStep: step];
        }

        if (stepOption != nil) {
          [action setCheckoutOption: stepOption];
        }
      }

      [builder setProductAction:action];

      [tracker set:kGAIScreenName value: screenName];
      [tracker set:kGAICurrencyCode value: [checkoutModel objectForKey:@"currencyCode"]];
      [tracker send:[builder build]];

      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) addTransaction: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:2];

    if (!tracker) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      return;
    }

    NSDictionary *transaction = [command.arguments objectAtIndex:0];

    [self.commandDelegate runInBackground:^{
      CDVPluginResult* pluginResult = nil;

      NSString *screenName = nil;

      if ([command.arguments count] > 1)
          screenName = [command.arguments objectAtIndex:1];

      NSString *transactionId = [transaction objectForKey:@"id"];

      if (transactionId == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Expected non-empty ID."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      }

      NSArray *products = [transaction objectForKey:@"products"];
      GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];

      [self addProductsToBuilder:builder products: products];

      GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
      [action setAction: kGAIPAPurchase];
      [action setTransactionId: transactionId];
      [action setAffiliation: [transaction objectForKey:@"affiliation"]];
      [action setRevenue: [transaction objectForKey:@"revenue"]];
      [action setTax: [transaction objectForKey:@"tax"]];
      [action setShipping: [transaction objectForKey:@"shipping"]];
      [action setCouponCode: [transaction objectForKey:@"couponCode"]];

      [builder setProductAction:action];


      [tracker set:kGAIScreenName value: screenName];
      [tracker set:kGAICurrencyCode value: [transaction objectForKey:@"currencyCode"]];
      [tracker send:[builder build]];

      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// Enhanced Ecommerce

- (void) sendProductEvent: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    id<GAITracker> tracker = [self getTrackerFromCommand:command index:9];

    if (!tracker) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tracker not started"];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      return;
    }

    [self.commandDelegate runInBackground:^{

      CDVPluginResult* pluginResult = nil;
      NSString *productId = nil;
      NSString *productName = nil;
      NSString *category = nil;
      NSString *brand = nil;
      NSString *variant = nil;
      NSNumber *position = nil;
      NSString *currencyCode = nil;
      NSString *screenName = nil;
      NSString *productActionType = nil;

      if ([command.arguments count] > 0)
          productId = [command.arguments objectAtIndex:0];

      if ([command.arguments count] > 1)
          productName = [command.arguments objectAtIndex:1];

      if ([command.arguments count] > 2)
          category = [command.arguments objectAtIndex:2];

      if ([command.arguments count] > 3)
          brand = [command.arguments objectAtIndex:3];

      if ([command.arguments count] > 4)
          variant = [command.arguments objectAtIndex:4];

      if ([command.arguments count] > 5)
          position = [command.arguments objectAtIndex:5];

      if ([command.arguments count] > 6)
          currencyCode = [command.arguments objectAtIndex:6];

      if ([command.arguments count] > 7)
          screenName = [command.arguments objectAtIndex:7];

      if ([command.arguments count] > 8)
          productActionType = [command.arguments objectAtIndex:8];


      GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
      [product setId: productId];
      [product setName: productName];
      [product setCategory: category];
      [product setBrand: brand];
      [product setVariant: variant];
      [product setPosition: position];

      [self addCustomDimensionsToProduct:product];

      GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
      [action setAction: productActionType];

      GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
      [builder setProductAction:action];

      [builder addProduct:product];
      [tracker set:kGAIScreenName value: screenName];
      [tracker set:kGAICurrencyCode value: currencyCode];
      [tracker send:[builder build]];

      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
