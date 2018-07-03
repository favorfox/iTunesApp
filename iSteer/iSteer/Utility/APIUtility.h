//
//  APIUtility.h
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "Constants.h"
#import "AppData.h"

@interface APIUtility : NSObject

@property (nonatomic , assign) AFHTTPSessionManager *operationManager;

+(APIUtility *)sharedInstance;

+(void)servicePostToEndPoint:(NSString *)endPoint withParams:(NSDictionary *)params aResultBlock:(void(^)(NSDictionary *response, NSError *error,bool isSuccess))resultBlock;

+(void)serviceGetToEndPoint:(NSString *)endPoint withParams:(NSDictionary *)params aResultBlock:(void(^)(NSDictionary *response, NSError *error))resultBlock;

+(void)servicePostToEndPoint:(NSString *)endPoint withImageData:(NSArray *)arrImageData withImageKeyName:(NSString *)keyName withParams:(NSDictionary *)param aResultBlock:(void (^)(NSDictionary *response, NSError *error))resultBlock;

+(void)getContactDetail:(NSString *)endPoint withParams:(NSDictionary *)params aResultBlock:(void(^)(NSDictionary *response, NSError *error,bool isSuccess))resultBlock;

+(BOOL)isInternetConnected;


//+(void)servicePostToEndPoint:(NSString *)endPoint withImageData:(NSData *)imageData withImageKeyName:(NSString *)keyName withParams:(NSDictionary *)param aResultBlock:(void (^)(NSDictionary *response, NSError *error))resultBlock;

@end
