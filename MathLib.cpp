//
//  MathLib.cpp
//  MobileApp
//
//  Created by kmgao on 2026/3/23.
//

#include "MathLib.hpp"
#include <cmath>
#include <stdexcept>
#include <iostream>

using namespace std;

struct DataReceiver{
public:
    DataReceiver(int data):mData(data){
        std::cout<<"DataReceiver::DataReceiver called"<<std::endl;
    }
    virtual ~DataReceiver(){
        std::cout<<"DataReceiver::~DataReceiver called"<<std::endl;
    }
public:
    int mData;
};


MathCalculator::MathCalculator(double baseValue) : base(baseValue) {
    std::cout<<"C++ Contruct MathCalculator::MathCalculator"<<std::endl;
}
MathCalculator::~MathCalculator() {
    std::cout<<"C++ DeContruct MathCalculator::~MathCalculator"<<std::endl;
}

double MathCalculator::power(double exponent) const {
    if (base < 0 && std::fmod(exponent, 1.0) != 0.0) {
        // 抛出C++标准异常
        throw std::invalid_argument("Negative base with non-integer exponent is not supported in real domain.");
    }
    return std::pow(base, exponent);
}

void MathCalculator::userSmartPointer()const{
    auto ptr = std::make_unique<DataReceiver>(1);
    auto dataRevicer = std::make_shared<DataReceiver>(0);
}

std::string MathCalculator::getVersion() {
    return "MathLib C++ 1.0";
}
