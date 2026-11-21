#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static const void *kLGNavAppearanceAppliedKey = &kLGNavAppearanceAppliedKey;
static const void *kLGTabAppearanceAppliedKey = &kLGTabAppearanceAppliedKey;
static const void *kLGToolbarAppearanceAppliedKey = &kLGToolbarAppearanceAppliedKey;
static const void *kLGPrivateGlassViewKey = &kLGPrivateGlassViewKey;

static NSMutableDictionary<NSString *, NSValue *> *gLGOriginalLayoutImplementations;
static NSDictionary<NSString *, NSNumber *> *gLGPrivateSurfaceRadii;

static UIBlurEffect *LGCreateGlassMaterial(void) {
    if (@available(iOS 13.0, *)) {
        return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    }

    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
}

static UIColor *LGGlassTintColor(void) {
    return [UIColor colorWithWhite:1.0 alpha:0.055];
}

static UIColor *LGGlassBorderColor(void) {
    return [UIColor colorWithWhite:1.0 alpha:0.22];
}

static void LGApplyNavigationBarAppearance(UINavigationBar *bar) {
    if (@available(iOS 13.0, *)) {
        if ([objc_getAssociatedObject(bar, kLGNavAppearanceAppliedKey) boolValue]) {
            return;
        }

        UINavigationBarAppearance *appearance = [bar.standardAppearance copy];
        if (!appearance) {
            appearance = [[UINavigationBarAppearance alloc] init];
            [appearance configureWithDefaultBackground];
        }

        appearance.backgroundEffect = LGCreateGlassMaterial();
        appearance.backgroundColor = LGGlassTintColor();
        appearance.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.16];

        bar.translucent = YES;
        bar.standardAppearance = appearance;
        bar.scrollEdgeAppearance = [appearance copy];
        bar.compactAppearance = [appearance copy];

        objc_setAssociatedObject(
            bar,
            kLGNavAppearanceAppliedKey,
            @YES,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }
}

static void LGApplyTabBarAppearance(UITabBar *bar) {
    if (@available(iOS 13.0, *)) {
        if ([objc_getAssociatedObject(bar, kLGTabAppearanceAppliedKey) boolValue]) {
            return;
        }

        UITabBarAppearance *appearance = [bar.standardAppearance copy];
        if (!appearance) {
            appearance = [[UITabBarAppearance alloc] init];
            [appearance configureWithDefaultBackground];
        }

        appearance.backgroundEffect = LGCreateGlassMaterial();
        appearance.backgroundColor = LGGlassTintColor();
        appearance.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.16];

        bar.translucent = YES;
        bar.standardAppearance = appearance;
        bar.scrollEdgeAppearance = [appearance copy];

        objc_setAssociatedObject(
            bar,
            kLGTabAppearanceAppliedKey,
            @YES,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }
}

static void LGApplyToolbarAppearance(UIToolbar *toolbar) {
    if (@available(iOS 13.0, *)) {
        if ([objc_getAssociatedObject(toolbar, kLGToolbarAppearanceAppliedKey) boolValue]) {
            return;
        }

        UIToolbarAppearance *appearance = [toolbar.standardAppearance copy];
        if (!appearance) {
            appearance = [[UIToolbarAppearance alloc] init];
            [appearance configureWithDefaultBackground];
        }

        appearance.backgroundEffect = LGCreateGlassMaterial();
        appearance.backgroundColor = LGGlassTintColor();
        appearance.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.16];

        toolbar.translucent = YES;
        toolbar.standardAppearance = appearance;
        toolbar.compactAppearance = [appearance copy];

        objc_setAssociatedObject(
            toolbar,
            kLGToolbarAppearanceAppliedKey,
            @YES,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }
}

static void LGApplyGlassToPrivateSurface(UIView *surface, CGFloat cornerRadius) {
    if (!surface || CGRectIsEmpty(surface.bounds)) {
        return;
    }

    UIVisualEffectView *glassView = objc_getAssociatedObject(surface, kLGPrivateGlassViewKey);

    if (!glassView) {
        glassView = [[UIVisualEffectView alloc] initWithEffect:LGCreateGlassMaterial()];
        glassView.userInteractionEnabled = NO;
        glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        glassView.contentView.backgroundColor = LGGlassTintColor();

        glassView.layer.cornerRadius = cornerRadius;
        glassView.layer.cornerCurve = kCACornerCurveContinuous;
        glassView.layer.masksToBounds = YES;
        glassView.layer.borderWidth = 0.5;
        glassView.layer.borderColor = LGGlassBorderColor().CGColor;

        [surface insertSubview:glassView atIndex:0];
        surface.backgroundColor = UIColor.clearColor;

        objc_setAssociatedObject(
            surface,
            kLGPrivateGlassViewKey,
            glassView,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }

    glassView.frame = surface.bounds;
    glassView.layer.cornerRadius = cornerRadius;
}

static IMP LGOriginalLayoutImplementationForObject(id object) {
    if (!gLGOriginalLayoutImplementations) {
        return NULL;
    }

    for (Class cls = object_getClass(object); cls != Nil; cls = class_getSuperclass(cls)) {
        NSValue *storedImplementation = gLGOriginalLayoutImplementations[NSStringFromClass(cls)];
        if (storedImplementation) {
            return (IMP)storedImplementation.pointerValue;
        }
    }

    return NULL;
}

static CGFloat LGPrivateSurfaceRadiusForObject(id object) {
    if (!gLGPrivateSurfaceRadii) {
        return 0.0;
    }

    for (Class cls = object_getClass(object); cls != Nil; cls = class_getSuperclass(cls)) {
        NSNumber *radius = gLGPrivateSurfaceRadii[NSStringFromClass(cls)];
        if (radius) {
            return radius.doubleValue;
        }
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

    CGFloat radius = LGPrivateSurfaceRadiusForObject(view);
    if (radius > 0.0) {
        LGApplyGlassToPrivateSurface(view, radius);
    }
}

static void LGInstallLayoutHook(Class cls) {
    if (!cls) {
        return;
    }

    SEL selector = @selector(layoutSubviews);
    Method method = class_getInstanceMethod(cls, selector);
    if (!method) {
        return;
    }

    IMP originalImplementation = method_getImplementation(method);
    if (originalImplementation == (IMP)LGLayoutSubviewsHook) {
        return;
    }

    const char *typeEncoding = method_getTypeEncoding(method);
    BOOL addedMethod = class_addMethod(
        cls,
        selector,
        (IMP)LGLayoutSubviewsHook,
        typeEncoding
    );

    if (!addedMethod) {
        Method ownMethod = class_getInstanceMethod(cls, selector);
        originalImplementation = method_setImplementation(
            ownMethod,
            (IMP)LGLayoutSubviewsHook
        );
    }

    if (originalImplementation) {
        gLGOriginalLayoutImplementations[NSStringFromClass(cls)] =
            [NSValue valueWithPointer:originalImplementation];
    }
}

static void LGInstallUIKitHooks(void) {
    LGInstallLayoutHook([UINavigationBar class]);
    LGInstallLayoutHook([UITabBar class]);
    LGInstallLayoutHook([UIToolbar class]);
}

static void LGInstallSpringBoardSurfaceHooks(void) {
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
}

__attribute__((constructor))
static void LiquidGlassInitialize(void) {
    @autoreleasepool {
        gLGOriginalLayoutImplementations = [NSMutableDictionary dictionary];

        LGInstallUIKitHooks();

        NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
        if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
            LGInstallSpringBoardSurfaceHooks();
        }
    }
}
