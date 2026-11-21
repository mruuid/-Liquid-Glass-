#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CoreFoundation/CoreFoundation.h>
#import <spawn.h>
#import <unistd.h>
#import <sys/wait.h>

static CFStringRef const kLGReloadNotification =
    CFSTR("com.mruuid.liquidglass26/reload");

@interface LGRootListController : PSListController
@end

@implementation LGRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Liquid Glass 26";
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        kLGReloadNotification,
        NULL,
        NULL,
        true
    );
}

- (void)respring {
    const char *tool = NULL;
    const char *candidates[] = {
        "/var/jb/usr/bin/sbreload",
        "/usr/bin/sbreload",
        "/var/jb/usr/bin/launchctl",
        "/usr/bin/launchctl",
        NULL
    };

    for (int i = 0; candidates[i] != NULL; i++) {
        if (access(candidates[i], X_OK) == 0) {
            tool = candidates[i];
            break;
        }
    }

    if (!tool) return;

    pid_t pid = 0;
    if (strstr(tool, "sbreload") != NULL) {
        char *const argv[] = { (char *)tool, NULL };
        if (posix_spawn(&pid, tool, NULL, NULL, argv, NULL) == 0) {
            waitpid(pid, NULL, 0);
        }
        return;
    }

    char *const argv[] = { (char *)tool, "reboot", "userspace", NULL };
    if (posix_spawn(&pid, tool, NULL, NULL, argv, NULL) == 0) {
        waitpid(pid, NULL, 0);
    }
}

@end
