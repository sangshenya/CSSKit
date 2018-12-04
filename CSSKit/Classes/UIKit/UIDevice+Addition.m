//
//  UIDevice+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#include <sys/sysctl.h>
#include <sys/stat.h>
#include <mach/mach.h>
#import "UIDevice+Addition.h"
#import "NSString+Addition.h"
#import "NSArray+Addition.h"

@implementation UIDevice (Addition)

+ (double)systemVersion {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

- (BOOL)isPad {
    static BOOL pad;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    });
    return pad;
}

- (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

- (BOOL)isJailbroken {
    if ([self isSimulator]) return NO;
    
    NSArray *paths = @[@"/Applications/Cydia.app",
                       @"/private/var/lib/apt/",
                       @"/private/var/lib/cydia",
                       @"/private/var/stash"];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    }
    
    FILE *bash = fopen("/bin/bash", "r");
    if (bash != NULL) {
        fclose(bash);
        return YES;
    }
    
    //攻击者可能会hook NSFileManager 的方法，让你的想法不能如愿。
    //那么，你可以回避 NSFileManager，使用stat系列函数检测Cydia等工具
    struct stat stat_info;
    if (0 == stat("Applications/Cydia.app", &stat_info)) {
        return YES;
    }
    
    NSString *path = [NSString stringWithFormat:@"/private/%@", [NSString stringWithUUID]];
    if ([@"test" writeToFile : path atomically : YES encoding : NSUTF8StringEncoding error : NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return YES;
    }
    
    return NO;
}

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
- (BOOL)canMakePhoneCalls {
    __block BOOL can;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        can = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
    });
    return can;
}
#endif

- (NSDate *)systemUptime {
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];
    return [[NSDate alloc] initWithTimeIntervalSinceNow:(0 - time)];
}

- (int64_t)diskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

- (int64_t)diskSpaceFree {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

- (int64_t)diskSpaceUsed {
    int64_t total = self.diskSpace;
    int64_t free = self.diskSpaceFree;
    if (total < 0 || free < 0) return -1;
    int64_t used = total - free;
    if (used < 0) used = -1;
    return used;
}

- (int64_t)memoryTotal {
    int64_t mem = [[NSProcessInfo processInfo] physicalMemory];
    if (mem < -1) mem = -1;
    return mem;
}

- (int64_t)memoryUsed {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return page_size * (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count);
}

- (int64_t)memoryFree {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size;
}

- (int64_t)memoryActive {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.active_count * page_size;
}

- (int64_t)memoryInactive {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.inactive_count * page_size;
}

- (int64_t)memoryWired {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.wire_count * page_size;
}

- (int64_t)memoryPurgable {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.purgeable_count * page_size;
}

- (NSUInteger)cpuCount {
    return [NSProcessInfo processInfo].activeProcessorCount;
}

- (float)cpuUsage {
    float cpu = 0;
    NSArray *cpus = [self cpuUsagePerProcessor];
    if (cpus.count == 0) return -1;
    for (NSNumber *n in cpus) {
        cpu += n.floatValue;
    }
    return cpu;
}

- (NSArray *)cpuUsagePerProcessor {
    processor_info_array_t _cpuInfo, _prevCPUInfo = nil;
    mach_msg_type_number_t _numCPUInfo, _numPrevCPUInfo = 0;
    unsigned _numCPUs;
    NSLock *_cpuUsageLock;
    
    int _mib[2U] = { CTL_HW, HW_NCPU };
    size_t _sizeOfNumCPUs = sizeof(_numCPUs);
    int _status = sysctl(_mib, 2U, &_numCPUs, &_sizeOfNumCPUs, NULL, 0U);
    if (_status)
        _numCPUs = 1;
    
    _cpuUsageLock = [[NSLock alloc] init];
    
    natural_t _numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &_numCPUsU, &_cpuInfo, &_numCPUInfo);
    if (err == KERN_SUCCESS) {
        [_cpuUsageLock lock];
        
        NSMutableArray *cpus = [NSMutableArray new];
        for (unsigned i = 0U; i < _numCPUs; ++i) {
            Float32 _inUse, _total;
            if (_prevCPUInfo) {
                _inUse = (
                          (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                          );
                _total = _inUse + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                _inUse = _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                _total = _inUse + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            [cpus addObject:@(_inUse / _total)];
        }
        
        [_cpuUsageLock unlock];
        if (_prevCPUInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * _numPrevCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCPUInfo, prevCpuInfoSize);
        }
        return cpus;
    } else {
        return nil;
    }
}

#pragma mark - 设备型号

+ (NSString *)getCurrentDeviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G (A1491)";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3G (A1599)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3G (A1600)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3G (A1601)";
    
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad Mini 4G (A1538)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad Mini 4G (A1550)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (A1566)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (A1567)";
    
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro (A1673)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro (A1674/A1675)";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro (A1584)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro (A1652)";
    if ([platform isEqualToString:@"iPad6,11"])     return @"iPad Pro (A1822)";
    if ([platform isEqualToString:@"iPad6,12"])     return @"iPad Pro (A1823)";
    
    if ([platform isEqualToString:@"iPad7,1"])      return @"iPad Pro (A1670)";
    if ([platform isEqualToString:@"iPad7,2"])      return @"iPad Pro (A1671/A1821)";
    if ([platform isEqualToString:@"iPad7,3"])      return @"iPad Pro (A1701)";
    if ([platform isEqualToString:@"iPad7,4"])      return @"iPad Pro (A1709)";
    if ([platform isEqualToString:@"iPad7,5"])      return @"iPad (A1893)";
    if ([platform isEqualToString:@"iPad7,6"])      return @"iPad (A1954)";
    if ([platform isEqualToString:@"iPad7,6"])      return @"iPad (A1954)";
    
    if ([platform isEqualToString:@"i386"])         return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"iPhone Simulator";
    
    return platform;
}

+ (NSString *)getCurrentDeviceShortModel {
    NSString *device = [UIDevice getCurrentDeviceModel];
    device = [[device componentsSeparatedByString:@" ("] objectOrNilAtIndex:0];
    return device;
}

+ (NSInteger)getCurrentDevicePPI {
    NSString *platform = [self getCurrentDeviceModel];
    
    if ([platform isEqualToString:@"iPhone 2G (A1203)"])                    return 163;
    if ([platform isEqualToString:@"iPhone 3G (A1241/A1324)"])              return 163;
    if ([platform isEqualToString:@"iPhone 3GS (A1303/A1325)"])             return 163;
    if ([platform isEqualToString:@"iPhone 4 (A1332)"])                     return 326;
    if ([platform isEqualToString:@"iPhone 4 (A1332)"])                     return 326;
    if ([platform isEqualToString:@"iPhone 4 (A1349)"])                     return 326;
    if ([platform isEqualToString:@"iPhone 4S (A1387/A1431)"])              return 326;
    if ([platform isEqualToString:@"iPhone 5 (A1428)"])                     return 326;
    if ([platform isEqualToString:@"iPhone 5 (A1429/A1442)"])               return 326;
    if ([platform isEqualToString:@"iPhone 5c (A1456/A1532)"])              return 326;
    if ([platform isEqualToString:@"iPhone 5c (A1507/A1516/A1526/A1529)"])  return 326;
    if ([platform isEqualToString:@"iPhone 5s (A1453/A1533)"])              return 326;
    if ([platform isEqualToString:@"iPhone 5s (A1457/A1518/A1528/A1530)"])  return 326;
    if ([platform isEqualToString:@"iPhone 6 Plus (A1522/A1524)"])          return 401;
    if ([platform isEqualToString:@"iPhone 6 (A1549/A1586)"])               return 326;
    if ([platform isEqualToString:@"iPhone 6s"])                            return 306;
    if ([platform isEqualToString:@"iPhone 6s Plus"])                       return 401;
    if ([platform isEqualToString:@"iPhone SE"])                            return 306;
    if ([platform isEqualToString:@"iPhone 7 Plus"])                        return 401;
    if ([platform isEqualToString:@"iPhone 7"])                             return 326;
    if ([platform isEqualToString:@"iPhone 8"])                             return 326;
    if ([platform isEqualToString:@"iPhone 8 Plus"])                        return 401;
    if ([platform isEqualToString:@"iPhone X"])                             return 458;
    
    if ([platform isEqualToString:@"iPod Touch 1G (A1213)"])                return 326;
    if ([platform isEqualToString:@"iPod Touch 2G (A1288)"])                return 326;
    if ([platform isEqualToString:@"iPod Touch 3G (A1318)"])                return 326;
    if ([platform isEqualToString:@"iPod Touch 4G (A1367)"])                return 326;
    if ([platform isEqualToString:@"iPod Touch 5G (A1421/A1509)"])          return 326;
    
    if ([platform isEqualToString:@"iPad 1G (A1219/A1337)"])                return 326;
    
    if ([platform isEqualToString:@"iPad 2 (A1395)"])                       return 326;
    if ([platform isEqualToString:@"iPad 2 (A1396)"])                       return 326;
    if ([platform isEqualToString:@"iPad 2 (A1397)"])                       return 326;
    if ([platform isEqualToString:@"iPad 2 (A1395+New Chip)"])              return 326;
    if ([platform isEqualToString:@"iPad Mini 1G (A1432)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 1G (A1454)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 1G (A1455)"])                 return 326;
    
    if ([platform isEqualToString:@"iPad 3 (A1416)"])                       return 326;
    if ([platform isEqualToString:@"iPad 3 (A1403)"])                       return 326;
    if ([platform isEqualToString:@"iPad 3 (A1430)"])                       return 326;
    if ([platform isEqualToString:@"iPad 4 (A1458)"])                       return 326;
    if ([platform isEqualToString:@"iPad 4 (A1459)"])                       return 326;
    if ([platform isEqualToString:@"iPad 4 (A1460)"])                       return 326;
    
    if ([platform isEqualToString:@"iPad Air (A1474)"])                     return 326;
    if ([platform isEqualToString:@"iPad Air (A1475)"])                     return 326;
    if ([platform isEqualToString:@"iPad Air (A1476)"])                     return 326;
    if ([platform isEqualToString:@"iPad Mini 2G (A1489)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 2G (A1490)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 2G (A1491)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 3G (A1599)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 3G (A1600)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 3G (A1601)"])                 return 326;
    
    if ([platform isEqualToString:@"iPad Mini 4G (A1538)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 4G (A1550)"])                 return 326;
    if ([platform isEqualToString:@"iPad Air 2 (A1566)"])                   return 326;
    if ([platform isEqualToString:@"iPad Air 2 (A1567)"])                   return 326;
    
    if ([platform isEqualToString:@"iPad Pro (A1673)"])                     return 401;
    if ([platform isEqualToString:@"iPad Pro (A1674/A1675)"])               return 401;
    if ([platform isEqualToString:@"iPad Pro (A1584)"])                     return 401;
    if ([platform isEqualToString:@"iPad Pro (A1652)"])                     return 401;
    if ([platform isEqualToString:@"iPad Pro (A1822)"])                     return 401;
    if ([platform isEqualToString:@"iPad Pro (A1823)"])                     return 401;
    
    if ([platform isEqualToString:@"iPad Pro (A1670)"])                     return 401;
    if ([platform isEqualToString:@"iPad Pro (A1671/A1821)"])               return 401;
    if ([platform isEqualToString:@"iPad Pro (A1701)"])                     return 401;
    if ([platform isEqualToString:@"iPad Pro (A1709)"])                     return 401;
    if ([platform isEqualToString:@"iPad (A1893)"])                         return 326;
    if ([platform isEqualToString:@"iPad (A1954)"])                         return 326;
    if ([platform isEqualToString:@"iPad (A1954)"])                         return 326;
    
    if ([platform isEqualToString:@"iPhone Simulator"])                     return 326;
    if ([platform isEqualToString:@"iPhone Simulator"])                     return 326;
    
    return 326;
}

@end
