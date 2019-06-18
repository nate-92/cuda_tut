#include <iostream>

typedef struct Matrix{
    int rows;
    int cols;
    float * matrix;
} Matrix;

typedef struct MatPair{
    Matrix * d_m;
    float * d_mat;
}MatPair;

Matrix * makeMatrix(int rows, int cols, float scalar){
    Matrix * mat = new Matrix();
    mat->rows = rows;
    mat->cols = cols;
    mat->matrix = new float[rows * cols];
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            mat->matrix[i * cols + j] = (i+1) * scalar + j;
        }
    }
    return mat;
}

Matrix * makeMatrix(int rows, int cols){
    Matrix * mat = new Matrix();
    mat->rows = rows;
    mat->cols = cols;
    return mat;
}

void setMatrix(Matrix * m1, int rows, int cols, float * matrix){
    m1->matrix = matrix;
}

Matrix * makeDeviceMatrix(Matrix * h_m){
    Matrix * d_m;
    //Allocating Matrix Struct
    cudaMalloc((void **) &d_m, sizeof(Matrix));
    
    //Allocating Matrix Member
    float * d_mat;
    cudaMalloc((void **) &d_mat, sizeof(float) * h_m->rows * h_m->cols);

    //Copying Matrix
    cudaMemcpy(d_mat,h_m->matrix,sizeof(float) * h_m->rows * h_m->cols, cudaMemcpyHostToDevice);

    //Free host matrix memory and set to point to newly allocated matrix
    free(h_m->matrix);
    h_m->matrix = d_mat;

    //Copying Struct from host to device
    cudaMemcpy(d_m, h_m, sizeof(Matrix), cudaMemcpyHostToDevice);
    return d_m;
}


Matrix * copyMatrixToHost(Matrix * d_m){
    Matrix * h_m = new Matrix();
    //Copying Matrix from Device to Host
    cudaMemcpy(h_m,d_m,sizeof(Matrix),cudaMemcpyDeviceToHost);
    //Allocating Space for new matrix
    float * h_mat = new float(h_m->cols * h_m->rows);

    //Free and point struct matrix member to new matrix
    h_m->matrix = h_mat;    

    return h_m;
}