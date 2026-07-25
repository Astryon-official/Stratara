#include "AstryonCore.hpp"

#include <iostream>

AstryonCore::AstryonCore()
{
}

void AstryonCore::initialize()
{
    std::cout << "Astryon Core starting..." << std::endl;
}

void AstryonCore::shutdown()
{
    std::cout << "Astryon Core shutting down..." << std::endl;
}
