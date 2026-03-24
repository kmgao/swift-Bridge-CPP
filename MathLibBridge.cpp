//
//  MathLibBridge.cpp
//  MobileApp
//
//  Created by kmgao on 2026/3/23.
//

#include "MathLibBridge.h"
#include "MathLib.hpp"
#include <cstring>
 

// 此文件必须用C++编译器编译，因为它包含了C++代码。

extern "C" {

    MathCalculatorRef createMathCalculator(double baseValue) {
        // 在堆上创建C++对象，返回其指针
        return reinterpret_cast<MathCalculatorRef>(new MathCalculator(baseValue));
    }

    void deleteMathCalculator(MathCalculatorRef ref) {
        // 将不透明指针转换回C++对象指针并删除
        auto* calc = reinterpret_cast<MathCalculator*>(ref);
        delete calc;
    }

    int mathCalculatorPower(MathCalculatorRef ref, double exponent, double* result) {
        if (ref == nullptr || result == nullptr) {
            return -1; // 无效参数错误码
        }
        try {
            auto* calc = reinterpret_cast<MathCalculator*>(ref);
            *result = calc->power(exponent);
            return 0; // 成功
        } catch (const std::invalid_argument& e) {
            // 这里可以记录日志，或者将错误信息通过其他渠道传递。
            // 目前仅返回错误码。更复杂的方案见下文“错误处理桥接”。
            return -2; // 计算域错误码
        } catch (...) {
            return -99; // 未知C++异常
        }
    }

    const char* mathLibGetVersion(void) {
        try {
            std::string version = MathCalculator::getVersion();
            // 需要将std::string的内容复制到C风格字符串中。
            // 调用者（Swift）需要负责释放这片内存，这通常通过一个配套的free函数来完成。
            // 这里使用静态缓冲区简化示例（实际项目需动态分配并管理生命周期）。
            static char buffer[256];
            std::strncpy(buffer, version.c_str(), sizeof(buffer) - 1);
            buffer[sizeof(buffer) - 1] = '\0';
            return buffer;
        } catch (...) {
            return "Error retrieving version";
        }
    }

      PersonRef createPerson(){
        Person *person = new Person;
        memset((void*)person, 0, sizeof(Person));
        return person;
    }
      void deletePerson(PersonRef ref){
        if(ref != NULL){
            if(ref->name != NULL){
                free((void*)ref->name);
            }
            delete ref;
        }
    }

      void setPersonName(PersonRef ref,const char* name){
        if(ref != NULL){
            if (ref->name == NULL) {
                ref->name = (char*)malloc(strlen(name+1));
                memset((void*)ref->name,0,strlen(name+1));
                memcpy((void*)ref->name,(const void *)name,strlen(name));
            }
            
        }
    }

const char* getName(PersonRef ref){
        if(ref != NULL){
            return ref->name;
        }
        else{
            return NULL;
        }
    }
}
