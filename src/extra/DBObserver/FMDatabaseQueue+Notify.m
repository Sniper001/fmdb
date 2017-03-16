//
// Created by root-sniper on 15/03/2017.
//

#import <sqlite3.h>
#import <pthread.h>
#import "FMDatabaseQueue+Notify.h"
#import "FMDatabase.h"

#define BUFFER_SIZE 256
static NSMutableDictionary *notifyDic = nil;
static char buf[BUFFER_SIZE] = {0};
static pthread_mutex_t pLock;

@implementation FMDatabaseQueue (Notify)

void update_callback(void *user_data, int operation_type,
        char const *database, char const *table, sqlite3_int64 rowid) {
    NSString *tableStr = [NSString stringWithCString:table
                                            encoding:NSUTF8StringEncoding];
    NSString *observe_key = [NSString stringWithFormat:@"%@/%@", _path, tableStr];
    pthread_mutex_lock(&pLock);
    if ([[notifyDic allKeys] containsObject:observe_key]) {
        NSString *notifyStr = [notifyDic objectForKey:observe_key];
        [[NSNotificationCenter defaultCenter] postNotificationName:notifyStr
                                                            object:nil];
    }
    pthread_mutex_unlock(&pLock);
}

/**
 * register db change observer for table: tableName
 * SQLITE_INSERT, SQLITE_DELETE, or SQLITE_UPDATE
 */
- (void)registerObserver:( NSString * _Nonnull )tableName
                  notify:( NSString * _Nonnull )notifyIdentify {
    NSString *observe_key = [NSString stringWithFormat:@"%@/%@", _path, tableName];
    pthread_mutex_lock(&pLock);
    if (![[notifyDic allKeys] containsObject:observe_key]) {
        [notifyDic setObject:notifyIdentify forKey:observe_key];
    }
    pthread_mutex_unlock(&pLock);

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sqlite3_update_hook((sqlite3 *) [_db sqliteHandle], update_callback, (void *) buf);
    });
}

/**
 * unregister db change observer for table: tableName
 */
- (void)unRegisterObserver:(NSString * _Nonnull )tableName {
    NSString *observe_key = [NSString stringWithFormat:@"%@/%@", _path, tableName];
    pthread_mutex_lock(&pLock);
    [notifyDic removeObjectForKey:observe_key];
    pthread_mutex_unlock(&pLock);
}

#pragma mark FMDatabaseQueue_Notify initialization

+ (void)load {
    pthread_mutex_init(&pLock, NULL);
    notifyDic = [NSMutableDictionary dictionary];
    memset(buf, 0, BUFFER_SIZE);
}
@end
