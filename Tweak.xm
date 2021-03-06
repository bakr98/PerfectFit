#import <UIKit/UIKit.h>
#import "Headers/AppList.h"
#import "Headers/ALApplicationTableDataSource.h"
#import "Headers/ALValueCell.h"

static NSDictionary *settings;

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
- (bool)_supportsApplicationType:(int)type;
- (bool)classicAppScaled;
@end

@interface SBApplicationInfo : NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBAppResizeGestureWorkspaceTransaction : NSObject
- (NSString *)bundleIdentifier;
@end

%hook SBApplication

- (bool)supportsApplicationType:(int)type 
{
    NSString *key = [@"enabled-" stringByAppendingString:self.bundleIdentifier ?: @""];
    if ([[settings objectForKey:key] boolValue]) {
        return YES;
    }
    return %orig;
}

- (long long)_classicModeFromSplashBoard
{
    NSString *key = [@"compatibility-" stringByAppendingString:self.bundleIdentifier ?: @""];
    if ([[settings objectForKey:key] boolValue]) {
        return 2;
    }
    return %orig;
}

- (bool)_supportsApplicationType:(int)type // this was renamed for some reason on iOS 10, had to copypasta the method but it should be okay for older versions
{
    NSString *key = [@"enabled-" stringByAppendingString:self.bundleIdentifier ?: @""];
    if ([[settings objectForKey:key] boolValue]) {
        return YES;
    }
    return %orig;
}

- (bool)classicAppScaled // maybe check if app is scaled
{
    return %orig;
}


/* - (bool)classicAppPhoneAppRunningOnPad 
{
    NSString *key = [@"enabled-" stringByAppendingString:self.bundleIdentifier ?: @""];
    if ([[settings objectForKey:key] boolValue]) {
        return NO;
    }
    return %orig;
}
*/

- (bool)isClassic 
{
    NSString *key = [@"enabled-" stringByAppendingString:self.bundleIdentifier ?: @""];
    if ([[settings objectForKey:key] boolValue]) {
        return NO;
    }
    return %orig;
}

%end



/* %hook SBAppResizeGestureWorkspaceTransaction

- (bool)_canTransitionIntoFullResizeWithLayoutState:(int)arg1 
{
    NSString *key = [@"enabled-" stringByAppendingString:self.bundleIdentifier ?: @""];
    if ([[settings objectForKey:key] boolValue]) {
        return YES;
    }
    return %orig;
}

%end
*/

%hook SBApplicationInfo 

/*- (bool)_supportsApplicationType:(int)type 
{
    NSString *key = [@"enabled-" stringByAppendingString:self.bundleIdentifier ?: @""];
    if ([[settings objectForKey:key] boolValue]) {
        return YES;
    }
    return %orig;
}
*/
%end

static void LoadSettings(void)
{
    [settings release];
    settings = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tonykraft.perfectfit.plist"];
}


%ctor
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    LoadSettings();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) LoadSettings, CFSTR("com.tonykraft.perfectfit.prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    %init;
    [pool drain];
}