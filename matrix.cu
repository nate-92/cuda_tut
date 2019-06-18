#include "matrix.h"
#include <stdio.h>
#include <iostream>

__global__ void add(Matrix * m1, Matrix * m2){
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    
    m1->matrix[index] += m2->matrix[index];
}

__global__ void displaySize(Matrix * m1){
    printf("Rows: %d \t Cols: %d\n",m1->rows, m1->cols);
}

__global__ void displayMatrix(Matrix * m){
    for(int i = 0; i < m->rows; i++){
        for(int j = 0; j < m->cols; j++){
            printf("%f\t",m->matrix[i * m->cols + j]);
        }
        printf("\n");
    }
}

void display(Matrix * m){
    for(int i = 0; i < m->rows; i++){
        for(int j = 0; j < m->cols; j++){
            std::cout<< m->matrix[i * m->cols + j] << "\t";
        }
        std::cout << std::endl;
    }
}

void sync(){
    cudaDeviceSynchronize();
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        fprintf(stderr,"Error: %s\n",cudaGetErrorString(error));
        exit(1);
    }
}

int main(){
    Matrix * h_m1 = makeMatrix(5,5,1), * h_m2 = makeMatrix(5,5,1);
    std::cout << "M1\n";
    display(h_m1);
    std::cout << std::endl;
    std::cout << "M2\n";
    display(h_m2);
    std::cout << std::endl;

    

    Matrix * d_m1 = makeDeviceMatrix(h_m1);
    Matrix *d_m2 = makeDeviceMatrix(h_m2);

    std::cout << "M1 Size\n";
    displaySize<<<1,1>>>(d_m1);
    sync();

    std::cout << "M2 Size\n";
    displaySize<<<1,1>>>(d_m2);
    sync();

    add<<<h_m1->rows,h_m1->cols>>>(d_m1, d_m2);
    sync();

    std::cout << "Addition\n";
    displayMatrix<<<1,1>>>(d_m1);
    sync();

    /*free(h_m1);
    h_m1 = copyMatrixToHost(d_m1);
    display(h_m1);*/


}