//
//  FarkPath.h
//  Arq
//
//  Created by Stefan Reitshamer on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FarkPath : NSObject {

}
+ (NSString *)s3PathForS3BucketName:(NSString *)s3BucketName computerUUID:(NSString *)computerUUID sha1:(NSString *)sha1;
+ (NSString *)s3PathForBucketDataPath:(NSString *)bucketDataPath s3BucketName:(NSString *)s3BucketName computerUUID:(NSString *)computerUUID;
@end
