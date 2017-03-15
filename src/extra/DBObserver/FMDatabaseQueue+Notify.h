//
// Created by root-sniper on 15/03/2017.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@interface FMDatabaseQueue (Notify)

- (void)registerObserver:(_Nonnull NSString *)tableName
                  notify:(_Nonnull NSString *)notifyIdentify;

- (void)unRegisterObserver:(_Nonnull NSString *)tableName;
@end