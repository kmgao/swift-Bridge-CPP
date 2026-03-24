//
//  MathLib.hpp
//  MobileApp
//
//  Created by kmgao on 2026/3/23.
//

#ifndef MathLib_h
#define MathLib_h

#include <string>

class MathCalculator {
public:
    MathCalculator(double baseValue);
    virtual ~MathCalculator();

    // 一个可能抛出异常的C++方法
    double power(double exponent) const;

    // 一个使用标准库的C++函数
    static std::string getVersion();
    
    // 在方法内部使用C++ smart pointer  unique_ptr and shared_ptr
    void userSmartPointer()const;

private:
    double base;
}; 

#endif /* MathLib_h */
