#include <iostream>

struct Matrix;
float * arrToGpu(float * h_arr, int rows, int cols);
Matrix * matrixToGpu(Matrix * h_m);

typedef struct Matrix{
    int rows;
    int cols;
    float * mat;
}Matrix;

 Matrix * makeMatrix(int rows, int cols, float scalar){
    Matrix * m = new Matrix();
    m->rows = rows;
    m->cols = cols;
    m->mat = new float(rows * cols * sizeof(float));
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            m->mat[i * cols + j] = (i+1) * scalar + (j+1);
        }
    }
    return m;
}

Matrix * matrixToGpu(Matrix * h_m){
    std::cout << "Moving matrix to gpu\n";

    //Allocate array to device
    std::cout << "Allocating Array\n";

    float * d_arr;
    cudaMalloc((void **) &d_arr, sizeof(float) * h_m->rows * h_m->cols);

    //Copy host array to device
    std::cout <<"Copying host array to device\n";
    cudaMemcpy(d_arr,h_m->mat,sizeof(float) * h_m->rows * h_m->cols,cudaMemcpyHostToDevice);

    //Free host array and matrix to point to device array
    std::cout << "Freeing host array\n";
    free(h_m->mat);
    std::cout << "Pointing host matrix to device array\n";
    h_m->mat = d_arr;

    Matrix * d_m;
    //Allocate Matrix to Device
    std::cout << "Allocating Matrix Struct\n";
    cudaMalloc((void **) &d_m, sizeof(Matrix));


    //Copy host matrix to device
    std::cout << "Copying host matrix to device\n";
    cudaMemcpy(d_m, h_m, sizeof(Matrix),cudaMemcpyHostToDevice);
    std::cout << "Finished moving matrix to gpu\n";
    return d_m;
}

