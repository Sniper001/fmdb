//
// Created by root-sniper on 15/03/2017.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@interface FMDatabaseQueue (Notify)

- (void)registerObserver:(NSString * _Nonnull )tableName
                  notify:(NSString * _Nonnull )notifyIdentify;

- (void)unRegisterObserver:(NSString * _Nonnull )tableName;
@end
