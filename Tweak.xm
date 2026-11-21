#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static NSString * const kLGPreferenceDomain = @"com.mruuid.liquidglass26";
static NSString * const kLGPreferenceNotification = @"com.mruuid.liquidglass26/reload";

static const void *kLGNavAppearanceAppliedKey = &kLGNavAppearanceAppliedKey;
static const void *kLGTabAppearanceAppliedKey = &kLGTabAppearanceAppliedKey;
static const void *kLGToolbarAppearanceAppliedKey = &kLGToolbarAppearanceAppliedKey;
static const void *kLGOriginalNavAppearanceKey = &kLGOriginalNavAppearanceKey;
static const void *kLGOriginalTabAppearanceKey = &kLGOriginalTabAppearanceKey;
static const void *kLGOriginalToolbarAppearanceKey = &kLGOriginalToolbarAppearanceKey;
static const void *kLGPrivateGlassViewKey = &kLGPrivateGlassViewKey;
static const void *kLGClockGlassViewKey = &kLGClockGlassViewKey;
static const void *kLGClockLabelKey = &kLGClockLabelKey;
static const void *kLGGlassGradientKey = &kLGGlassGradientKey;
static const void *kLGGlassProfileKey = &kLGGlassProfileKey;

static NSMutableDictionary<NSString *, NSValue *> *gLGOriginalLayoutImplementations;
static NSDictionary<NSString *, NSNumber *> *gLGPrivateSurfaceRadii;
static NSDictionary<NSString *, id> *gLGPreferences;

static void LGReloadPreferences(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kLGPreferenceDomain];
    [defaults registerDefaults:@{
        @"Enabled": @YES,
        @"SystemPanelsEnabled": @YES,
        @"DockAndFoldersEnabled": @YES,
        @"LockScreenClockEnabled": @YES,
        @"VolumeHUDEnabled": @YES,
        @"GlassIntensity": @72,
        @"iOS27RefinementsEnabled": @YES,
        @"PerformanceMode": @NO
    }];

    @synchronized ([NSUserDefaults class]) {
        gLGPreferences = [[defaults dictionaryRepresentation] copy] ?: @{};
    }
}

static id LGPreference(NSString *key, id fallback) {
    @synchronized ([NSUserDefaults class]) {
        id value = gLGPreferences[key];
        return value ?: fallback;
    }
}

static BOOL LGPreferenceEnabled(NSString *key, BOOL fallback) {
    return [LGPreference(key, @(fallback)) boolValue];
}

static CGFloat LGGlassIntensity(void) {
    CGFloat value = [LGPreference(@"GlassIntensity", @72) doubleValue] / 100.0;
    return MIN(1.0, MAX(0.0, value));
}

static BOOL LGReduceMotion(void) {
    return UIAccessibilityIsReduceMotionEnabled() ||
           NSProcessInfo.processInfo.isLowPowerModeEnabled ||
           LGPreferenceEnabled(@"PerformanceMode", NO);
}

static BOOL LGReduceTransparency(void) {
    return UIAccessibilityIsReduceTransparencyEnabled();
}

static UIBlurEffect *LGCreateGlassMaterial(void) {
    if (@available(iOS 13.0, *)) {
        if (LGReduceTransparency()) {
            return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
        }

        if (LGGlassIntensity() < 0.45 ||
            LGPreferenceEnabled(@"PerformanceMode", NO) ||
            NSProcessInfo.processInfo.isLowPowerModeEnabled) {
            return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
        }

        return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    }

    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
}

static UIColor *LGGlassTintColor(void) {
    CGFloat intensity = LGGlassIntensity();
    CGFloat alpha = 0.018 + (intensity * 0.075);
    if (LGReduceTransparency()) alpha = MAX(alpha, 0.16);
    return [UIColor colorWithWhite:1.0 alpha:alpha];
}

static UIColor *LGGlassBorderColor(void) {
    BOOL refined = LGPreferenceEnabled(@"iOS27RefinementsEnabled", YES);
    CGFloat alpha = refined ? 0.30 : 0.20;
    if (LGReduceTransparency()) alpha = 0.38;
    return [UIColor colorWithWhite:1.0 alpha:alpha];
}

static void LGAnimateGlassEntrance(UIVisualEffectView *glassView, BOOL isHUD) {
    if (LGReduceMotion()) {
        glassView.alpha = 1.0;
        glassView.transform = CGAffineTransformIdentity;
        return;
    }

    BOOL refined = LGPreferenceEnabled(@"iOS27RefinementsEnabled", YES);
    NSTimeInterval duration = isHUD ? (refined ? 0.30 : 0.22) : (refined ? 0.46 : 0.34);
    CGFloat damping = refined ? 0.76 : 0.88;

    glassView.alpha = 0.0;
    glassView.transform = CGAffineTransformMakeScale(0.965, 0.965);
    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:damping
          initialSpringVelocity:0.55
                        options:UIViewAnimationOptionBeginFromCurrentState |
                                UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        glassView.alpha = 1.0;
        glassView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

static void LGAddSpecularHighlight(UIVisualEffectView *glassView) {
    if (objc_getAssociatedObject(glassView, kLGGlassGradientKey)) return;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = glassView.contentView.bounds;
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint = CGPointMake(0.5, 1.0);
    gradient.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.19].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.035].CGColor,
        (id)[UIColor colorWithWhite:0.0 alpha:0.075].CGColor
    ];
    gradient.locations = @[@0.0, @0.52, @1.0];
    [glassView.contentView.layer addSublayer:gradient];

    objc_setAssociatedObject(
        glassView,
        kLGGlassGradientKey,
        gradient,
        OBJC_ASSOCIATION_RETAIN_NONATOMIC
    );
}

static void LGConfigureGlassView(UIVisualEffectView *glassView, CGFloat radius, BOOL isHUD) {
    NSInteger profile = (NSInteger)round(LGGlassIntensity() * 100.0) +
                        (LGReduceTransparency() ? 1000 : 0) +
                        (LGPreferenceEnabled(@"iOS27RefinementsEnabled", YES) ? 2000 : 0) +
                        (LGPreferenceEnabled(@"PerformanceMode", NO) ? 4000 : 0);

    if (![objc_getAssociatedObject(glassView, kLGGlassProfileKey) isEqual:@(profile)]) {
        glassView.effect = LGCreateGlassMaterial();
        glassView.contentView.backgroundColor = LGGlassTintColor();
        glassView.layer.borderWidth = LGReduceTransparency() ? 0.8 : 0.55;
        glassView.layer.borderColor = LGGlassBorderColor().CGColor;
        glassView.layer.cornerRadius = radius;
        glassView.layer.cornerCurve = kCACornerCurveContinuous;
        glassView.layer.masksToBounds = YES;
        objc_setAssociatedObject(
            glassView,
            kLGGlassProfileKey,
            @(profile),
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }

    if (LGPreferenceEnabled(@"PerformanceMode", NO) || LGReduceTransparency()) {
        CAGradientLayer *oldGradient = objc_getAssociatedObject(glassView, kLGGlassGradientKey);
        [oldGradient removeFromSuperlayer];
        objc_setAssociatedObject(glassView, kLGGlassGradientKey, nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        LGAddSpecularHighlight(glassView);
        CAGradientLayer *gradient = objc_getAssociatedObject(glassView, kLGGlassGradientKey);
        gradient.frame = glassView.contentView.bounds;
    }
    if (isHUD && LGPreferenceEnabled(@"iOS27RefinementsEnabled", YES)) {
        glassView.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
        glassView.layer.shadowOpacity = 0.12;
        glassView.layer.shadowRadius = 12.0;
        glassView.layer.shadowOffset = CGSizeMake(0.0, 5.0);
    }
}

static NSInteger LGAppearanceProfile(void) {
    return (NSInteger)round(LGGlassIntensity() * 100.0) +
           (LGReduceTransparency() ? 1000 : 0) +
           (LGPreferenceEnabled(@"iOS27RefinementsEnabled", YES) ? 2000 : 0) +
           (LGPreferenceEnabled(@"PerformanceMode", NO) ? 4000 : 0);
}

static void LGApplyNavigationBarAppearance(UINavigationBar *bar) {
    if (!bar) return;

    UINavigationBarAppearance *original =
        objc_getAssociatedObject(bar, kLGOriginalNavAppearanceKey);

    if (!LGPreferenceEnabled(@"Enabled", YES) ||
        !LGPreferenceEnabled(@"SystemPanelsEnabled", YES)) {
        if (original) {
            bar.standardAppearance = [original copy];
            bar.scrollEdgeAppearance = [original copy];
            bar.compactAppearance = [original copy];
        }
        objc_setAssociatedObject(bar, kLGNavAppearanceAppliedKey, nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }

    if (!original) {
        original = [bar.standardAppearance copy];
        objc_setAssociatedObject(
            bar, kLGOriginalNavAppearanceKey, original,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }

    NSInteger profile = LGAppearanceProfile();
    NSNumber *applied = objc_getAssociatedObject(bar, kLGNavAppearanceAppliedKey);
    if (applied && applied.integerValue == profile) return;

    UINavigationBarAppearance *appearance = [bar.standardAppearance copy];
    if (!appearance) {
        appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithDefaultBackground];
    }

    appearance.backgroundEffect = LGCreateGlassMaterial();
    appearance.backgroundColor = LGGlassTintColor();
    appearance.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.12];

    bar.translucent = YES;
    bar.standardAppearance = appearance;
    bar.scrollEdgeAppearance = [appearance copy];
    bar.compactAppearance = [appearance copy];

    objc_setAssociatedObject(bar, kLGNavAppearanceAppliedKey, @(profile),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void LGApplyTabBarAppearance(UITabBar *bar) {
    if (!bar) return;

    UITabBarAppearance *original =
        objc_getAssociatedObject(bar, kLGOriginalTabAppearanceKey);

    if (!LGPreferenceEnabled(@"Enabled", YES) ||
        !LGPreferenceEnabled(@"SystemPanelsEnabled", YES)) {
        if (original) {
            bar.standardAppearance = [original copy];
            bar.scrollEdgeAppearance = [original copy];
        }
        objc_setAssociatedObject(bar, kLGTabAppearanceAppliedKey, nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }

    if (!original) {
        original = [bar.standardAppearance copy];
        objc_setAssociatedObject(
            bar, kLGOriginalTabAppearanceKey, original,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }

    NSInteger profile = LGAppearanceProfile();
    NSNumber *applied = objc_getAssociatedObject(bar, kLGTabAppearanceAppliedKey);
    if (applied && applied.integerValue == profile) return;

    UITabBarAppearance *appearance = [bar.standardAppearance copy];
    if (!appearance) {
        appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithDefaultBackground];
    }

    appearance.backgroundEffect = LGCreateGlassMaterial();
    appearance.backgroundColor = LGGlassTintColor();
    appearance.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.12];

    bar.translucent = YES;
    bar.standardAppearance = appearance;
    bar.scrollEdgeAppearance = [appearance copy];

    objc_setAssociatedObject(bar, kLGTabAppearanceAppliedKey, @(profile),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void LGApplyToolbarAppearance(UIToolbar *toolbar) {
    if (!toolbar) return;

    UIToolbarAppearance *original =
        objc_getAssociatedObject(toolbar, kLGOriginalToolbarAppearanceKey);

    if (!LGPreferenceEnabled(@"Enabled", YES) ||
        !LGPreferenceEnabled(@"SystemPanelsEnabled", YES)) {
        if (original) {
            toolbar.standardAppearance = [original copy];
            toolbar.compactAppearance = [original copy];
        }
        objc_setAssociatedObject(toolbar, kLGToolbarAppearanceAppliedKey, nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }

    if (!original) {
        original = [toolbar.standardAppearance copy];
        objc_setAssociatedObject(
            toolbar, kLGOriginalToolbarAppearanceKey, original,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }

    NSInteger profile = LGAppearanceProfile();
    NSNumber *applied = objc_getAssociatedObject(toolbar, kLGToolbarAppearanceAppliedKey);
    if (applied && applied.integerValue == profile) return;

    UIToolbarAppearance *appearance = [toolbar.standardAppearance copy];
    if (!appearance) {
        appearance = [[UIToolbarAppearance alloc] init];
        [appearance configureWithDefaultBackground];
    }

    appearance.backgroundEffect = LGCreateGlassMaterial();
    appearance.backgroundColor = LGGlassTintColor();
    appearance.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.12];

    toolbar.translucent = YES;
    toolbar.standardAppearance = appearance;
    toolbar.compactAppearance = [appearance copy];

    objc_setAssociatedObject(toolbar, kLGToolbarAppearanceAppliedKey, @(profile),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void LGRemoveGlassView(UIView *surface, const void *key) {
    UIVisualEffectView *glassView = objc_getAssociatedObject(surface, key);
    if (glassView) [glassView removeFromSuperview];
    objc_setAssociatedObject(surface, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void LGApplyGlassToPrivateSurface(UIView *surface, CGFloat cornerRadius, BOOL isHUD) {
    if (!surface || CGRectIsEmpty(surface.bounds)) return;

    BOOL shouldApply = LGPreferenceEnabled(@"Enabled", YES);
    if (isHUD) shouldApply = shouldApply && LGPreferenceEnabled(@"VolumeHUDEnabled", YES);
    else shouldApply = shouldApply && LGPreferenceEnabled(@"DockAndFoldersEnabled", YES);

    if (!shouldApply) {
        LGRemoveGlassView(surface, kLGPrivateGlassViewKey);
        return;
    }

    UIVisualEffectView *glassView = objc_getAssociatedObject(surface, kLGPrivateGlassViewKey);
    BOOL isNew = (glassView == nil);

    if (!glassView) {
        glassView = [[UIVisualEffectView alloc] initWithEffect:LGCreateGlassMaterial()];
        glassView.userInteractionEnabled = NO;
        glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleHeight;
        [surface insertSubview:glassView atIndex:0];

        objc_setAssociatedObject(
            surface,
            kLGPrivateGlassViewKey,
            glassView,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }

    glassView.frame = surface.bounds;
    LGConfigureGlassView(glassView, cornerRadius, isHUD);
    if (isNew) LGAnimateGlassEntrance(glassView, isHUD);
}

static UILabel *LGFindLargestClockLabel(UIView *view, CGFloat *largestFontSize) {
    UILabel *result = nil;

    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        CGFloat pointSize = label.font.pointSize;
        if (!label.hidden && label.alpha > 0.01 && label.text.length > 0 &&
            pointSize >= 34.0 && pointSize > *largestFontSize) {
            *largestFontSize = pointSize;
            result = label;
        }
    }

    for (UIView *subview in view.subviews) {
        UILabel *candidate = LGFindLargestClockLabel(subview, largestFontSize);
        if (candidate) result = candidate;
    }

    return result;
}

static void LGApplyLockScreenClock(UIView *dateView) {
    if (!LGPreferenceEnabled(@"Enabled", YES) ||
        !LGPreferenceEnabled(@"LockScreenClockEnabled", YES)) {
        LGRemoveGlassView(dateView, kLGClockGlassViewKey);
        return;
    }

    CGFloat largestFontSize = 0.0;
    UILabel *timeLabel = LGFindLargestClockLabel(dateView, &largestFontSize);
    if (!timeLabel) return;

    UIVisualEffectView *glassView = objc_getAssociatedObject(dateView, kLGClockGlassViewKey);
    BOOL isNew = (glassView == nil);

    if (!glassView) {
        glassView = [[UIVisualEffectView alloc] initWithEffect:LGCreateGlassMaterial()];
        glassView.userInteractionEnabled = NO;
        [dateView insertSubview:glassView atIndex:0];

        objc_setAssociatedObject(
            dateView,
            kLGClockGlassViewKey,
            glassView,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }

    CGRect labelFrame = [timeLabel convertRect:timeLabel.bounds toView:dateView];
    CGFloat horizontalPadding = MIN(18.0, MAX(10.0, largestFontSize * 0.17));
    CGFloat verticalPadding = MIN(10.0, MAX(5.0, largestFontSize * 0.07));
    CGRect glassFrame = CGRectInset(labelFrame, -horizontalPadding, -verticalPadding);

    glassView.frame = glassFrame;
    glassView.autoresizingMask = UIViewAutoresizingNone;
    LGConfigureGlassView(glassView, MIN(30.0, CGRectGetHeight(glassFrame) * 0.42), NO);

    if (isNew) LGAnimateGlassEntrance(glassView, NO);
}

static BOOL LGIsPillSizedHUD(UIView *view) {
    CGSize screen = UIScreen.mainScreen.bounds.size;
    CGSize size = view.bounds.size;
    CGFloat shortSide = MIN(size.width, size.height);
    CGFloat longSide = MAX(size.width, size.height);

    if (shortSide < 26.0 || longSide < 48.0) return NO;
    if ((longSide / MAX(shortSide, 1.0)) < 1.35) return NO;
    if (size.width > screen.width * 0.92) return NO;
    if (size.height > screen.height * 0.30) return NO;
    return YES;
}

static UIView *LGFindHUDSurfaceInTree(UIView *root, CGFloat *largestArea) {
    UIView *best = nil;

    if (LGIsPillSizedHUD(root)) {
        CGFloat area = root.bounds.size.width * root.bounds.size.height;
        if (area > *largestArea) {
            *largestArea = area;
            best = root;
        }
    }

    for (UIView *subview in root.subviews) {
        UIView *candidate = LGFindHUDSurfaceInTree(subview, largestArea);
        if (candidate) best = candidate;
    }

    return best;
}

static IMP LGOriginalLayoutImplementationForObject(id object) {
    if (!gLGOriginalLayoutImplementations) return NULL;

    for (Class cls = object_getClass(object); cls != Nil; cls = class_getSuperclass(cls)) {
        NSValue *stored = gLGOriginalLayoutImplementations[NSStringFromClass(cls)];
        if (stored) return (IMP)stored.pointerValue;
    }

    return NULL;
}

static CGFloat LGPrivateSurfaceRadiusForObject(id object) {
    if (!gLGPrivateSurfaceRadii) return 0.0;

    for (Class cls = object_getClass(object); cls != Nil; cls = class_getSuperclass(cls)) {
        NSNumber *radius = gLGPrivateSurfaceRadii[NSStringFromClass(cls)];
        if (radius) return radius.doubleValue;
    }

    return 0.0;
}

static void LGLayoutSubviewsHook(UIView *view, SEL selector) {
    IMP originalImplementation = LGOriginalLayoutImplementationForObject(view);
    if (originalImplementation) {
        ((void (*)(id, SEL))originalImplementation)(view, selector);
    }

    if ([view isKindOfClass:[UINavigationBar class]]) {
        LGApplyNavigationBarAppearance((UINavigationBar *)view);
        return;
    }

    if ([view isKindOfClass:[UITabBar class]]) {
        LGApplyTabBarAppearance((UITabBar *)view);
        return;
    }

    if ([view isKindOfClass:[UIToolbar class]]) {
        LGApplyToolbarAppearance((UIToolbar *)view);
        return;
    }

    NSString *className = NSStringFromClass(object_getClass(view));
    if ([className isEqualToString:@"SBFLockScreenDateView"]) {
        LGApplyLockScreenClock(view);
        return;
    }

    BOOL isHUD = [className containsString:@"VolumeHUD"] ||
                 [className containsString:@"RingerHUD"] ||
                 [className isEqualToString:@"SBElasticSliderView"];

    if (isHUD) {
        CGFloat largestHUDArea = 0.0;
        UIView *hudSurface = LGFindHUDSurfaceInTree(view, &largestHUDArea);
        if (hudSurface) {
            LGApplyGlassToPrivateSurface(hudSurface, 28.0, YES);
        }
        return;
    }

    CGFloat radius = LGPrivateSurfaceRadiusForObject(view);
    if (radius > 0.0) {
        LGApplyGlassToPrivateSurface(view, radius, NO);
    }
}

static void LGInstallLayoutHook(Class cls) {
    if (!cls) return;

    SEL selector = @selector(layoutSubviews);
    Method method = class_getInstanceMethod(cls, selector);
    if (!method) return;

    IMP originalImplementation = method_getImplementation(method);
    if (originalImplementation == (IMP)LGLayoutSubviewsHook) return;

    const char *typeEncoding = method_getTypeEncoding(method);
    BOOL addedMethod = class_addMethod(cls, selector, (IMP)LGLayoutSubviewsHook, typeEncoding);

    if (!addedMethod) {
        Method ownMethod = class_getInstanceMethod(cls, selector);
        originalImplementation = method_setImplementation(ownMethod, (IMP)LGLayoutSubviewsHook);
    }

    if (originalImplementation) {
        gLGOriginalLayoutImplementations[NSStringFromClass(cls)] =
            [NSValue valueWithPointer:(const void *)originalImplementation];
    }
}

static void LGInstallUIKitHooks(void) {
    LGInstallLayoutHook([UINavigationBar class]);
    LGInstallLayoutHook([UITabBar class]);
    LGInstallLayoutHook([UIToolbar class]);
}

static void LGInstallSpringBoardHooks(void) {
    gLGPrivateSurfaceRadii = @{
        @"SBFloatingDockView": @28.0,
        @"SBFloatingDockPlatterView": @28.0,
        @"SBFolderBackgroundView": @24.0,
        @"NCNotificationShortLookView": @22.0,
        @"CCUIContentModuleContainerView": @20.0,
        @"CCUIModuleContainerView": @20.0
    };

    for (NSString *className in gLGPrivateSurfaceRadii) {
        Class cls = objc_getClass(className.UTF8String);
        if (cls && [cls isSubclassOfClass:[UIView class]]) {
            LGInstallLayoutHook(cls);
        }
    }

    Class clockClass = objc_getClass("SBFLockScreenDateView");
    if (clockClass && [clockClass isSubclassOfClass:[UIView class]]) {
        LGInstallLayoutHook(clockClass);
    }

    NSArray<NSString *> *hudClasses = @[
        @"SBVolumeHUDView",
        @"SBRingerHUDView",
        @"SBElasticSliderView"
    ];

    for (NSString *className in hudClasses) {
        Class cls = objc_getClass(className.UTF8String);
        if (cls && [cls isSubclassOfClass:[UIView class]]) {
            LGInstallLayoutHook(cls);
        }
    }
}

static void LGMarkViewTreeForLayout(UIView *view) {
    [view setNeedsLayout];
    for (UIView *subview in view.subviews) {
        LGMarkViewTreeForLayout(subview);
    }
}

static void LGPreferencesChanged(CFNotificationCenterRef center,
                                 void *observer,
                                 CFStringRef name,
                                 const void *object,
                                 CFDictionaryRef userInfo) {
    dispatch_async(dispatch_get_main_queue(), ^{
        LGReloadPreferences();

        // Refresh already-visible interfaces so preference changes take effect
        // without requiring an app relaunch or respring.
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;

            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                LGMarkViewTreeForLayout(window);
                [window layoutIfNeeded];
            }
        }
    });
}

// Liquid Glass 26 v0.3.1 Safe Mode hotfix.
__attribute__((constructor))
static void LiquidGlassInitialize(void) {
    @autoreleasepool {
        LGReloadPreferences();
        gLGOriginalLayoutImplementations = [NSMutableDictionary dictionary];

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            LGPreferencesChanged,
            (__bridge CFStringRef)kLGPreferenceNotification,
            NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately
        );

        NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;

        // Safety hotfix: never activate private SpringBoard hooks by default.
        // Those classes are undocumented and can differ across iOS point releases.
        if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
            if (LGPreferenceEnabled(@"ExperimentalSpringBoardHooks", NO)) {
                LGInstallUIKitHooks();
                LGInstallSpringBoardHooks();
            }
            return;
        }

        // Keep the supported UIKit appearance hooks in selected user-facing apps.
        LGInstallUIKitHooks();
    }
}
