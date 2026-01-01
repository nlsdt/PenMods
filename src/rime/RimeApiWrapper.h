#ifndef RIME_API_WRAPPER_H
#define RIME_API_WRAPPER_H

// 避免与 Qt 元对象系统冲突
#ifdef Bool
#undef Bool
#endif

// 引入 librime 头文件
#include "rime_api.h"

// 取消定义 Bool 宏以避免与 Qt MOC 冲突
#ifdef Bool
#undef Bool
#endif

// 为 librime API 定义别名，避免在使用时出现冲突
typedef int RimeBool;
#define RimeTrue 1
#define RimeFalse 0

#endif // RIME_API_WRAPPER_H