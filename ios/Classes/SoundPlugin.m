#import "SoundPlugin.h"
#if __has_include(<sound_plugin/sound_plugin-Swift.h>)
#import <sound_plugin/sound_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sound_plugin-Swift.h"
#endif

@implementation SoundPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSoundPlugin registerWithRegistrar:registrar];
}
@end
