#include <stdio.h>
#include <iostream>

/* typedef struct matSize{
    int rows;
    int cols;
    __host__ __device__
    matSize(int rows, int cols){
        this->rows = rows;
        this->cols = cols;
    }
}matSize;

*/


class Matrix{
    public:
    Matrix(int rows, int cols, float scalar):rows(rows),cols(cols){
        makeMatrix(scalar);
    }

/*    Matrix(matSize * mSize, float scalar){
        size = mSize;
        makeMatrix(scalar);
    }
*/

    //To be called for transferring h_mat to device
    Matrix(Matrix * h_mat){
        //Get dimensions for float array
        this->rows = h_mat->getRows();
        this->cols = h_mat->getCols();

        //Get float array
        this->mat = h_mat->getMatrix();
    }

    void makeMatrix(float scalar){
        mat = new float(rows * cols);
        for(int i = 0; i < rows; i++){
            for(int j = 0; j < cols; j++){
                mat[i * cols + j] = (i+1) * scalar + (j+1);
            }
        }
    }

    __host__ __device__
    float * getMatrix(){
        return mat;
    }

    __host__ __device__
    int getRows(){
        return rows;
    }

    __host__ __device__
    int getCols(){
        return cols;
    }

/*    void GPUSetSize(matSize * h_size){
        std::cout << "Moving Size to GPU\n";
        matSize * d_size;
        //Allocate Space to GPU
        std::cout << "Allocating Space To GPU\n";
        cudaMalloc((void **) &d_size, sizeof(matSize));
        //Copy Previous Struct to new struct
        std::cout << "Copying from host to device\n";
        cudaMemcpy(d_size,h_size,sizeof(matSize),cudaMemcpyHostToDevice);
        //Point size to struct on device
        std::cout << "Setting matrix to point to new array\n";
        size = d_size;
        std::cout << "Finished\n";
    }*/

/*    void moveSizeToGPU(){
        matSize * d_size;
        //Allocate Space to GPU
        cudaMalloc((void **) &d_size, sizeof(matSize));
        //Copy Previous Struct to new struct
        cudaMemcpy(d_size,size,sizeof(matSize),cudaMemcpyHostToDevice);
        //Free space from memory
        free(size);
        //Point size to struct on device
        size = d_size;
    }*/

/*    void GPUSetMatrix(float * h_mat, matSize * h_size){
        std::cout << "Moving array to GPU\n";
        float * d_mat;
        size_t d_mat_size = sizeof(float) * h_size->rows * h_size->cols;
        //Allocate Space to GPU
        std::cout << "Allocating Space To GPU\n";
        cudaError_t error = cudaMalloc((void **) & d_mat, d_mat_size);
        checkError(error);

        //Copy host array to device
        std::cout << "Copying array from host to device\n";
        cudaMemcpy(d_mat,h_mat,d_mat_size,cudaMemcpyHostToDevice);       
        //Set mat to point to matrix allocated to device
        std::cout << "Setting matrix to point to new array\n";
        mat = d_mat;
        std::cout << "Finished\n";
    }*/

    void display(){
        printf("Rows: %d\t Cols:%d\n",rows, cols);
        for(int i = 0; i < rows; i++){
            for(int j = 0; j < cols; j++){
                printf("%f\t",mat[i * rows + j]);
            }
            printf("\n");
        }
    }

    void setMatrix(float * n_mat){
        this->mat = n_mat;
    }
    
    private:
    float * mat;
    int rows;
    int cols;
    
    void checkError(cudaError_t err){
        if(err != cudaSuccess){
            fprintf(stderr,"Error %s\n",cudaGetErrorString(err));
            exit(1);
        }
    }

};



void matToGpu(Matrix * h_m){
    std::cout << "Moving Matrix To GPU\n";
    float * d_mat, * h_mat = h_m->getMatrix();
    //Allocate memory for matrix to device
    std::cout << "Allocating Space\n";
    cudaMalloc((void **) &d_mat, sizeof(float) * h_m->getRows() * h_m->getCols());

    //Copy values to device
    std::cout << "Copying Values to Device\n";
    cudaMemcpy(d_mat,h_mat,sizeof(float) * h_m->getRows() * h_m->getCols(), cudaMemcpyHostToDevice);

    //Free mat and set to point to device array
    std::cout << "Setting mat to point to GPU array";
    free(h_mat);
    h_m->setMatrix(d_mat);
}
