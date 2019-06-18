#include "matrix.h"
#include <iostream>

int main(){
    Matrix * h_m1 = makeMatrix(5,5,1);

    Matrix * h_m2 = matrixToGpu(h_m1);
}