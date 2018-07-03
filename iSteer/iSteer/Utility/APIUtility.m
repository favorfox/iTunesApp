//
//  APIUtility.m
//

#import "APIUtility.h"

static APIUtility *sharedObject;

@interface APIUtility()

@end


@implementation APIUtility

+(APIUtility *)sharedInstance{

    if (sharedObject == nil) {
        sharedObject = [[APIUtility alloc] init];
        sharedObject. operationManager = [AFHTTPSessionManager manager];
    }
    
    return sharedObject;
}

+(void)servicePostToEndPoint:(NSString *)endPoint withParams:(NSDictionary *)params aResultBlock:(void(^)(NSDictionary *response, NSError *error,bool isSuccess))resultBlock{    
    
    if ([self isInternetConnected]) {
        
        NSString *url = [APIBaseURL stringByAppendingString:endPoint];
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",jsonString);
        
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [serializer setValue:jsonString forHTTPHeaderField:@"Body"];
        [APIUtility sharedInstance].operationManager.requestSerializer = serializer;
        
//        [[APIUtility sharedInstance].operationManager.requestSerializer setTimeoutInterval:60];
        
        [[APIUtility sharedInstance].operationManager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (resultBlock) {
                resultBlock((NSDictionary *)responseObject , nil,true);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (resultBlock) {
                NSLog(@"%@",error);
                
                NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                NSLog(@"%@",ErrorResponse);

                resultBlock(nil,(NSError *)error,false);
            }
        }];
    }else{
//        [SVProgressHUD showErrorWithStatus:@"No Internet Connection"];
        resultBlock(nil,nil,false);
        [AppData displayAlert:@"No Internet Connection"];
        
    }
}


+(void)serviceGetToEndPoint:(NSString *)endPoint withParams:(NSDictionary *)params aResultBlock:(void(^)(NSDictionary *response, NSError *error))resultBlock{
    
    if ([self isInternetConnected]) {
        
        NSString *url = [APIBaseURL stringByAppendingString:endPoint];

        [[APIUtility sharedInstance].operationManager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }else{
        [SVProgressHUD showInfoWithStatus:@"No Internet Connection"];
    }
}


+(void)servicePostToEndPoint:(NSString *)endPoint withImageData:(NSArray *)arrImageData withImageKeyName:(NSString *)keyName withParams:(NSDictionary *)param aResultBlock:(void (^)(NSDictionary *response, NSError *error))resultBlock{
    
    if ([self isInternetConnected]) {
        
        NSString *url = [APIBaseURL stringByAppendingString:endPoint];
        
        [[APIUtility sharedInstance].operationManager POST:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
            
            for (int i = 0; i < arrImageData.count; i++) {
                NSString *strI = [NSString stringWithFormat:@"%d",i];
                NSString *keyImagepath = [NSString stringWithFormat:@"child[%@][%@]",strI,keyName];
                [formData appendPartWithFileData:[arrImageData objectAtIndex:i] name:keyImagepath fileName:@"samplethumbnail1.png" mimeType:@"image/png"];
            }
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (resultBlock) {
                //[SVProgressHUD dismiss];
                resultBlock((NSDictionary*)responseObject,nil);
            }

        }failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error %@", error);
            if (resultBlock) {
                [SVProgressHUD dismiss];
                resultBlock(nil,(NSError*)error);
            }
        }];
    }else{
        [SVProgressHUD showInfoWithStatus:@"No Internet Connection"];
    }
}


+(void)servicePostToEndPointWithImage:(NSString *)endPoint withParams:(NSDictionary *)params aResultBlock:(void(^)(NSDictionary *response, NSError *error,bool isSuccess))resultBlock{
    
    if ([self isInternetConnected]) {
        
        NSString *url = [APIBaseURL stringByAppendingString:endPoint];
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",jsonString);
        
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [serializer setValue:jsonString forHTTPHeaderField:@"Body"];
        [APIUtility sharedInstance].operationManager.requestSerializer = serializer;
        
        //[[APIUtility sharedInstance].operationManager.requestSerializer setTimeoutInterval:60];
        
        [[APIUtility sharedInstance].operationManager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (resultBlock) {
                resultBlock((NSDictionary *)responseObject , nil,true);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (resultBlock) {
                NSLog(@"%@",error);
                
                NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                NSLog(@"%@",ErrorResponse);
                
                resultBlock(nil,(NSError *)error,false);
            }
        }];
    }else{
        [SVProgressHUD showInfoWithStatus:@"No Internet Connection"];
    }
}


+(BOOL)isInternetConnected{
        return [AFNetworkReachabilityManager sharedManager].reachable;
}



+(void)getContactDetail:(NSString *)endPoint withParams:(NSDictionary *)params aResultBlock:(void(^)(NSDictionary *response, NSError *error,bool isSuccess))resultBlock{
    
    if ([self isInternetConnected]) {
        
        NSString *url = [APIBaseURL stringByAppendingString:endPoint];
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",jsonString);
        
        //        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        //[serializer setValue:jsonString forHTTPHeaderField:@"Body"];
        [APIUtility sharedInstance].operationManager.requestSerializer = serializer;
        
        //        [[APIUtility sharedInstance].operationManager.requestSerializer setTimeoutInterval:60];
        
        [[APIUtility sharedInstance].operationManager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (resultBlock) {
                resultBlock((NSDictionary *)responseObject , nil,true);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (resultBlock) {
                NSLog(@"%@",error);
                
                NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                NSLog(@"%@",ErrorResponse);
                
                resultBlock(nil,(NSError *)error,false);
            }
        }];
    }else{
        [SVProgressHUD showInfoWithStatus:@"No Internet Connection"];
    }
}

@end






