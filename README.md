# Swift 调用 C++ 实现指南

本文档介绍如何在 iOS 项目中使用 Swift 调用 C++ 代码。

## 项目结构

```
MobileApp/
├── MathLib.hpp           # C++ 头文件
├── MathLib.cpp           # C++ 实现文件
├── MathLibBridge.h       # C++ 桥接头文件
├── MathLibBridge.cpp     # C++ 桥接实现文件
└── MobileApp/
    └── MobileApp-Bridging-Header.h  # Swift 桥接文件
```

## 核心概念

由于 Swift 无法直接调用 C++，我们需要通过以下方式进行桥接：

1. **C++ 实现层**：MathLib.cpp/MathLib.hpp
2. **C++ 桥接层**：使用 extern "C" 将 C++ 函数暴露给 C 接口
3. **Swift 桥接层**：通过 Objective-C/C 桥接头文件让 Swift 调用

## 实现步骤

### 1. 创建 C++ 类

首先定义 C++ 类（MathLib.hpp）：

```cpp
#ifndef MathLib_h
#define MathLib_h

#include <string>

class MathCalculator {
public:
    MathCalculator(double baseValue);
    virtual ~MathCalculator();
    
    double power(double exponent) const;
    static std::string getVersion();
    void userSmartPointer() const;
    
private:
    double base;
};

#endif
```

### 2. 实现 C++ 类（MathLib.cpp）

```cpp
#include "MathLib.hpp"
#include <cmath>
#include <iostream>

MathCalculator::MathCalculator(double baseValue) : base(baseValue) {
    std::cout << "C++ Construct MathCalculator" << std::endl;
}

MathCalculator::~MathCalculator() {
    std::cout << "C++ Destruct MathCalculator" << std::endl;
}

double MathCalculator::power(double exponent) const {
    return std::pow(base, exponent);
}

std::string MathCalculator::getVersion() {
    return "MathLib C++ 1.0";
}
```

### 3. 创建 C 桥接接口（MathLibBridge.h）

使用 `extern "C"` 将 C++ 函数包装成 C 风格接口：

```c
#ifndef MathLibBridge_h
#define MathLibBridge_h

#ifdef __cplusplus
extern "C" {
#endif

// 不透明指针类型 - 用于隐藏 C++ 对象的实现细节
typedef void* MathCalculatorRef;

// 具体类型对象指针 - 直接暴露 C 结构体，Swift 可以直接访问其成员
typedef struct Person* PersonRef;

// MathCalculator 相关函数
MathCalculatorRef createMathCalculator(double baseValue);
void deleteMathCalculator(MathCalculatorRef ref);
int mathCalculatorPower(MathCalculatorRef ref, double exponent, double* result);
const char* mathLibGetVersion(void);

// Person 相关函数
PersonRef createPerson(void);
void deletePerson(PersonRef ref);
void setPersonName(PersonRef ref, const char* name);
const char* getPersonName(PersonRef ref);

#ifdef __cplusplus
}
#endif

#endif
```

### 4. 实现 C 桥接接口（MathLibBridge.cpp）

```cpp
#include "MathLibBridge.h"
#include "MathLib.hpp"
#include <cstring>

extern "C" {

    // MathCalculator 相关实现
    MathCalculatorRef createMathCalculator(double baseValue) {
        return new MathCalculator(baseValue);
    }

    void deleteMathCalculator(MathCalculatorRef ref) {
        delete static_cast<MathCalculator*>(ref);
    }

    int mathCalculatorPower(MathCalculatorRef ref, double exponent, double* result) {
        if (ref == nullptr || result == nullptr) {
            return -1;
        }
        try {
            auto* calc = static_cast<MathCalculator*>(ref);
            *result = calc->power(exponent);
            return 0;
        } catch (...) {
            return -99;
        }
    }

    const char* mathLibGetVersion(void) {
        static std::string version = MathCalculator::getVersion();
        return version.c_str();
    }

    // Person 相关实现
    PersonRef createPerson(void) {
        Person* person = new Person;
        memset(person, 0, sizeof(Person));
        return person;
    }

    void deletePerson(PersonRef ref) {
        if (ref != NULL) {
            if (ref->name != NULL) {
                free((void*)ref->name);
            }
            delete ref;
        }
    }

    void setPersonName(PersonRef ref, const char* name) {
        if (ref != NULL) {
            if (ref->name == NULL) {
                ref->name = strdup(name);
            }
        }
    }

    const char* getPersonName(PersonRef ref) {
        if (ref != NULL) {
            return ref->name;
        }
        return NULL;
    }
}
```

### 5. 配置 Swift 桥接

在 `MobileApp-Bridging-Header.h` 中导入桥接头文件：

```objective-c
//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "MathLibBridge.h"
```

### 6. Xcode 项目配置

确保以下配置正确：

1. **桥接头文件设置**：
   - Target → Build Settings → Swift Compiler - General
   - Objective-C Bridging Header 设置为 `MobileApp/MobileApp-Bridging-Header.h`

2. **C++ 文件编译**：
   - 确保所有 .cpp 文件都被添加到 Compile Sources
   - Target → Build Phases → Compile Sources

3. **Objective-C++ 支持**：
   - 将包含 C++ 代码的 Objective-C 文件扩展名改为 .mm

## Swift 中使用示例

```swift
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // ===== 使用不透明指针类型的示例 =====
        // 1. 创建 C++ 对象（不透明指针）
        let calculatorRef = createMathCalculator(2.0)

        // 2. 使用 C++ 对象进行计算
        var result: Double = 0.0
        let errorCode = mathCalculatorPower(calculatorRef, 3.0, &result)

        if errorCode == 0 {
            print("2.0 的 3.0 次方是: \(result)")
        } else {
            print("计算出错，错误码: \(errorCode)")
        }

        // 3. 获取版本信息
        let version = String(cString: mathLibGetVersion())
        print("库版本: \(version)")

        // 4. 释放 C++ 对象
        deleteMathCalculator(calculatorRef)

        // ===== 使用具体类型对象指针的示例 =====
        // 1. 创建 Person 对象（具体类型）
        let personRef = createPerson()

        // 2. 直接访问结构体成员
        if let person = personRef {
            person.pointee.age = 25
            person.pointee.height = 175.5

            // 3. 设置名字
            setPersonName(personRef, "张三")

            // 4. 获取名字
            if let nameCStr = getPersonName(personRef) {
                let name = String(cString: nameCStr)
                print("姓名: \(name), 年龄: \(person.pointee.age), 身高: \(person.pointee.height)")
            }
        }

        // 5. 释放 Person 对象
        deletePerson(personRef)
    }
}
```

## 关键要点

### 1. 内存管理
- **不透明指针类型**（`void*`）：在 Swift 和 C++ 之间传递对象，隐藏实现细节
- **具体类型对象指针**（`struct Person*`）：直接暴露 C 结构体，Swift 可以直接访问成员
- 必须显式调用创建和销毁函数来管理 C++ 对象生命周期
- Swift 端无法直接调用 C++ 的构造函数和析构函数

### 2. 不透明指针 vs 具体类型指针

| 指针类型 | 定义方式 | Swift 访问方式 | 适用场景 |
|---------|---------|--------------|---------|
| 不透明指针 | `typedef void* MathCalculatorRef` | 通过函数调用间接访问 | 隐藏 C++ 类实现细节 |
| 具体类型指针 | `typedef struct Person* PersonRef` | 直接访问 `pointee` 成员 | 需要直接访问结构体字段 |

**不透明指针示例**：
```swift
let calculator = createMathCalculator(2.0)
var result: Double = 0.0
mathCalculatorPower(calculator, 3.0, &result)  // 通过函数调用
```

**具体类型指针示例**：
```swift
let person = createPerson()
person.pointee.age = 25                          // 直接访问成员
person.pointee.height = 175.5
```

### 3. 类型转换
| C++ 类型 | C 接口类型 | Swift 类型 |
|---------|----------|-----------|
| `MathCalculator*` | `MathCalculatorRef` (void*) | `UnsafeMutableRawPointer` |
| `Person*` | `PersonRef` (struct Person*) | `UnsafeMutablePointer<Person>` |
| `std::string` | `const char*` | `String(cString:)` |
| `double` | `double` | `Double` |
| `int` | `int` | `Int32` |
| `char*` | `char*` | `UnsafeMutablePointer<Int8>` |

### 3. 错误处理
- C++ 异常无法直接传递到 Swift
- 在桥接层捕获 C++ 异常并返回错误码
- Swift 端检查返回的错误码进行处理

### 4. 字符串处理
- C++ 的 `std::string` 转换为 C 风格字符串（`const char*`）
- Swift 使用 `String(cString:)` 将 C 字符串转换为 Swift 字符串
- 注意字符串的生命周期管理，避免悬垂指针

## 常见问题

### Q1: 为什么不能直接在 Swift 中调用 C++？
A: Swift 编译器无法直接解析 C++ 语法。需要通过 C 接口作为中间层进行桥接。

### Q2: 不透明指针和具体类型指针有什么区别？
A:
- **不透明指针**（`void*`）：隐藏了 C++ 对象的实现细节，Swift 只能通过桥接函数操作对象
- **具体类型指针**（`struct Person*`）：直接暴露 C 结构体，Swift 可以通过 `pointee` 直接访问和修改结构体成员

### Q3: 如何处理 C++ 类的继承？
A: 只暴露需要使用的基类接口，派生类功能通过桥接层转发。

### Q4: 如何传递复杂数据结构？
A: 将复杂数据序列化为 C 兼容格式（如 JSON）或使用结构体指针。

### Q5: 如何处理 C++ 的 STL 容器？
A: 在桥接层将 STL 容器转换为 C 数组或指针，Swift 端使用相应数据结构。

### Q6: 为什么 Person 使用具体类型指针而 MathCalculator 使用不透明指针？
A:
- `Person` 是简单的 C 结构体，只有数据字段，适合直接暴露给 Swift
- `MathCalculator` 是 C++ 类，包含复杂逻辑和方法，适合隐藏实现细节

## 总结

Swift 调用 C++ 的核心流程：
1. 编写 C++ 实现代码
2. 创建 C 桥接接口（extern "C"）
3. 实现 C 桥接层
4. 配置 Swift 桥接头文件
5. 在 Swift 中调用 C 接口函数

这种方式虽然增加了一些代码量，但提供了类型安全的跨语言调用方式，是 iOS 项目中集成 C++ 代码的标准做法。

## 参考资料

- [Swift - C++ Interop](https://www.swift.org/documentation/cxx-interop/)
- [Xcode - Configure Bridging Headers](https://developer.apple.com/documentation/xcode/building-a-project-that-contains-swift-and-objective-c-files)
- [Using Swift with Cocoa and Objective-C](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/compatibility)
