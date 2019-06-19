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

        Matrix(Matrix * h_mat){
            //Get dimensions for float array
            this->rows = h_mat->getRows();
            this->cols = h_mat->getCols();
            //Get float array
            this->mat = h_mat->getMatrix();
        }

        void makeMatrix(float scalar){
            mat = new float[rows * cols];
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

        __host__
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

        __device__ void add(int index, float val){
            mat[index] += val;
        }

        __device__ float getVal(int index){
            return mat[index];
        }

        void matToDevice(){
            float * d_mat;
            //Allocate Matrix to Device
            std::cout << "Allocating Array to Device\n";
            cudaMalloc((void **)&d_mat, sizeof(float) * rows * cols);
            //Copy Contents of Matrix from host to device
            std::cout << "Copying from host to device\n";
            cudaMemcpy(d_mat, mat, sizeof(float) * rows * cols, cudaMemcpyHostToDevice);
            //Free from host
            std::cout << "Freeing from host\n";
            free(mat);
            //Set mat to point to device matrix
            std::cout << "Setting mat to point to device\n\n";
            mat = d_mat;
        }

        void matToHost(){
            //Allocate Matrix to Host
            std::cout << "Allocating Array to Host\n";
            float * h_mat = new float[rows * cols];
            //Copy contents of device matrix to host
            std::cout << "Copying from device to host\n";
            cudaMemcpy(h_mat,mat,sizeof(float) * rows * cols, cudaMemcpyDeviceToHost);
            //Free from device
            std::cout << "Freeing from device\n";
            cudaFree(mat);
            //Set mat to point to host matrix
            std::cout << "Setting mat to point to host\n\n";
            mat = h_mat;
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
