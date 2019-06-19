#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <stdio.h>


__global__ void display(thrust::device_ptr<float> d_vec, int rows, int cols){
    for(int i = 0; i < rows * cols; i++){
        printf("%f\t",d_vec[i]);
    }
}

class Matrix{
    public:
        Matrix(int rows, int cols, float scalar):rows(rows),cols(cols){
            //Allocate space for host_vector
            h_vec = new thrust::host_vector<float>(rows * cols);
            //Set Vector Values
            setVals(scalar);
            //Copy to device
            d_vec = new thrust::device_vector<float>(*h_vec);
            display<<<1,1>>>(thrust::raw_pointer_cast( &((*d_vec)[0]),rows,cols);
        };



    private:
        //Data
        thrust::host_vector<float> * h_vec;
        thrust::device_vector<float> * d_vec;
        int rows;
        int cols;


        //Private Functions
        void setVals(float scalar){
            for(int i = 0; i < rows; i++){
                for(int j = 0; j < cols; j++){
                    (*h_vec)[(i * cols + j)] = (i+1) * scalar + (j+1);
                }
            }
        }

};