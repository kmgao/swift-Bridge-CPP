//
//  MathLibBridge.h
//  MobileApp
//
//  Created by kmgao on 2026/3/23.
//

#ifndef MathLibBridge_h
#define MathLibBridge_h


// 使用C语言的链接规范，确保函数名不被修饰
#ifdef __cplusplus
extern "C" {
#endif


struct Person{
    
    int age;
    double height;
    const char* name;
};




// 不透明指针类型，用于在Swift中安全地持有C++对象
typedef void* MathCalculatorRef;

//具体类型对象指针
typedef struct Person* PersonRef;

PersonRef createPerson();
void deletePerson(PersonRef ref);
void setPersonName(PersonRef ref,const char* name);
const char* getName(PersonRef ref);


// 构造函数和析构函数的包装
MathCalculatorRef createMathCalculator(double baseValue);
void deleteMathCalculator(MathCalculatorRef ref);


// 方法包装：返回错误码，结果通过指针参数返回
int mathCalculatorPower(MathCalculatorRef ref, double exponent, double* result);

// 纯函数包装：注意返回的字符串内存需要管理
const char* mathLibGetVersion(void);

#ifdef __cplusplus
}
#endif



#endif /* MathLibBridge_h */
