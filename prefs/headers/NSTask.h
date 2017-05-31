
@interface NSTask : NSObject

@property (copy, nonatomic) NSArray *arguments;
@property (copy, nonatomic) NSString *launchPath;
@property (strong, nonatomic) id standardOutput;

- (void)launch;

@end
