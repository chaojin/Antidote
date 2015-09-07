//
//  LifecyclePhaseLogin.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objcTox/OCTManager.h>

#import "LifecyclePhaseLogin.h"
#import "LoginViewController.h"
#import "LifecyclePhaseRunning.h"
#import "UserDefaultsManager.h"
#import "ProfileManager.h"
#import "AppDelegate.h"

@implementation LifecyclePhaseLogin
@synthesize delegate = _delegate;

#pragma mark -  Public

- (void)finishPhaseWithToxManager:(nonnull OCTManager *)manager
{
    LifecyclePhaseRunning *running = [[LifecyclePhaseRunning alloc] initWithToxManager:manager];

    [self.delegate phaseDidFinish:self withNextPhase:running];
}

#pragma mark -  LifecyclePhaseProtocol

- (void)start
{
    BOOL isLoggedIn = [AppContext sharedContext].userDefaults.uIsUserLoggedIn;
    NSString *lastActiveProfile = [AppContext sharedContext].userDefaults.uLastActiveProfile;

    if (! isLoggedIn || ! lastActiveProfile) {
        [self showLoginController];
        return;
    }

    ProfileManager *profileManager = [ProfileManager new];

    if (! [profileManager.allProfiles containsObject:lastActiveProfile]) {
        [self showLoginController];
        return;
    }

    OCTManagerConfiguration *configuration = [profileManager configurationForProfileWithName:lastActiveProfile];

    if (! configuration) {
        [self showLoginController];
        return;
    }

    OCTManager *manager = [[OCTManager alloc] initWithConfiguration:configuration error:nil];

    if (! manager) {
        [self showLoginController];
        return;
    }

    [self finishPhaseWithToxManager:manager];
}

- (nonnull NSString *)name
{
    return @"Login";
}

#pragma mark -  Private

- (void)showLoginController
{
    LoginViewController *loginVC = [LoginViewController new];
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:loginVC];
    navCon.navigationBarHidden = YES;

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = navCon;
}

@end
