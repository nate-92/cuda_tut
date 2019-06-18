#include <iostream>
#include "matrix.h"

__global__ void add(){

}


int main(){
    Matrix * h_m1 = new Matrix(8,8,1);
    matToGpu(h_m1);
    
}