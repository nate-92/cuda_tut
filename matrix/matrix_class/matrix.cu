#include <iostream>
#include "matrix.cuh"

__global__ void add(Matrix * m1, Matrix * m2){
    int index = threadIdx.x * m1->getCols() + blockIdx.x;
    m1->add(index,m2->getVal(index));
}

void sync(){
    cudaDeviceSynchronize();
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        fprintf(stderr,"Error: %s\n",cudaGetErrorString(error));
        exit(1);
    }
}
Matrix * moveMatrixToDevice(Matrix * h_m);

int main(){
    Matrix * h_m1 = new Matrix(8,8,1), * h_m2 = new Matrix(8,8,1);

    std::cout << "M1\n";
    h_m1->display();
    std::cout << "M2\n";
    h_m2->display();

    h_m1->matToDevice();
    h_m2->matToDevice();


    Matrix * d_m1 = moveMatrixToDevice(h_m1), * d_m2 = moveMatrixToDevice(h_m2);

    std::cout << "Addition\n";
    add<<<8,8>>>(d_m1,d_m2);
    sync();

    std::cout << "After Addition\n";
    std::cout << "M1\n";
    h_m1->matToHost();
    h_m1->display();
    std::cout << "M2\n";
    h_m1->matToHost();
    h_m2->display();
}

Matrix * moveMatrixToDevice(Matrix * h_m){
    Matrix * d_m;
    //Allocate Space
    cudaMalloc((void **) &d_m,sizeof(Matrix));
    //Copy to device
    cudaMemcpy(d_m, h_m, sizeof(Matrix),cudaMemcpyHostToDevice);
    return d_m;
}