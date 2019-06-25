#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/fill.h>
#include <vector>
#include <iostream>
#include <stdio.h>
#include <math.h>

#include "setContainer.cuh"

#define DEBUG

template<typename T>
class Set{
    public:
        Set(std::vector<T> i_set, int dim){
            //Set Magnitude of set
            this->vecSize = i_set.size();
            this->dim = dim;
            std::cout << "Setting Indecies\n";
            makeIndex();
            std::cout << "Initializing Cofaces\n";
            initializeCofaces();
            std::cout << "Construction Complete\n";
        }

        Set(){}

        void display(){
            std::cout << "Size: " << size << std::endl;
            for(int i = 0; i < size; i++){
                setContainer tmp = cof[i];

                for(int j = 0; j < tmp.size; j++){
                    std::cout << tmp.set[j] << " ";
                }
                std::cout << std::endl;
            }
        }

        std::vector<T> * getCofaces(std::vector<T> o_set){
            std::vector<T> * cofaces = new std::vector<int>[size];
            for(int i = 0; i < size; i++){
                setContainer tmp = cof[i];
                for(int j = 0; j < tmp.size; j++){
                    int index = tmp.set[j];
                    cofaces[i].push_back(o_set[index]);
                }
            }
            return cofaces;
        }


        __device__
        void d_setCoface(int vecIndex, int valIndex, int pos){
            //X is subset Y is index in subset
            cof[vecIndex].set[valIndex] = pos;
        }

        __host__ __device__
        int ncr(int n, int r){
            int diff = n - r;           
            //Eliminate the larger one to save computation time
            if(diff > r){
                return factRange(n,diff)/fact(r);
            //Research for properties
            }else if(diff == r){
                return factRange(n,diff)/fact(r);
            }else{
                return factRange(n,r)/fact(diff);
            }      
        }

        //Move from gpu to host
        void hostToGPU(){
            std::cout << "Starting moving from Host To GPU\n";

            //Copy Cofaces To Device
            for(int i = 0; i < size; i++){
                cof[i].toDevice();
            }
            //Create new container on device
            setContainer * tmpCof;
            //Allocate Space on device for container
            cudaMalloc((void **) &tmpCof, sizeof(setContainer) * size);
            //Copy from Host To Device
            cudaMemcpy(tmpCof,cof,sizeof(setContainer) * size, cudaMemcpyHostToDevice);
            //Free host
            //free(cof);
            cof = tmpCof;


            //Copy dim_start_indecies, dim_end_indecies, dim_sizes
            int * d_start, *d_end, * d_size; 

            //Start indecies
            //Allocate
            cudaMalloc((void **) &d_start,sizeof(int) * (dim+1));
            //Copy
            cudaMemcpy(d_start, dim_start_indecies,sizeof(int) * (dim+1),cudaMemcpyHostToDevice);  
            //Free
            //free(dim_start_indecies);
            //Point
            dim_start_indecies = d_start;          

            //End indecies
            //Allocate
            cudaMalloc((void **)&d_end,sizeof(int) * (dim+1));
            //Copy
            cudaMemcpy(d_end, dim_end_indecies,sizeof(int) * (dim+1),cudaMemcpyHostToDevice);            
            //Free
            //free(dim_end_indecies);
            //Point
            dim_end_indecies = d_end;

            //Sizes
            //Allocate
            cudaMalloc((void **) &d_size,sizeof(int) * (dim+1));
            //Copy
            cudaMemcpy(d_size, dim_sizes,sizeof(int) * (dim+1),cudaMemcpyHostToDevice);
            //Free
            //free(dim_sizes);
            //Point
            dim_sizes = d_size;
            std::cout << "Finished moving from Host To GPU\n";

        }

        void GPUtoHost(){
            std::cout << "Starting moving from GPU To Host\n";

            //Copy dim_start_indecies, dim_end_indecies, dim_sizes
            int * h_start, *h_end, * h_size; 

            //Start indecies
            //Allocate
            h_start = new int[dim+1];
            //Copy
            cudaMemcpy(h_start, dim_start_indecies,sizeof(int) * (dim+1),cudaMemcpyDeviceToHost);
            //Free
            //cudaFree(dim_start_indecies);
            //Point
            dim_start_indecies = h_start;

            //End indecies
            //Allocate
            h_end = new int[dim+1];
            //Copy
            cudaMemcpy(h_end, dim_end_indecies,sizeof(int) * (dim+1),cudaMemcpyDeviceToHost);            
            //Free
            //cudaFree(dim_end_indecies);
            //Point
            dim_end_indecies = h_end;
            
            //Sizes
            //Allocate
            h_size = new int[dim+1];
            //Copy
            cudaMemcpy(h_size, dim_sizes,sizeof(int) * (dim+1),cudaMemcpyDeviceToHost);
            //Free
            //cudaFree(dim_sizes);
            //Point
            dim_sizes = h_size;


            //Allocate
            setContainer * tmpCof = new setContainer[size];
            //Copy
            cudaMemcpy(tmpCof,cof,sizeof(setContainer) * size, cudaMemcpyDeviceToHost);
            //Free
            //cudaFree(cof);
            //Point
            cof = tmpCof;
            for(int i = 0; i < size; i++){
                cof[i].toHost();
            }
            std::cout << "Finished moving from GPU To Host\n";
        }
               
        //Get Total number of elements for a dimension d
        __host__ __device__
        int getSize(int d){ return dim_sizes[d];}

        //Get start index of a set at dimension d
        __host__ __device__
        int getIndex(int d){ 
            return dim_start_indecies[d];
        }

        __host__ __device__ int getIndex(int d, int index){
            return dim_start_indecies[d] + ncr(index+1,d+1) - ncr(index,d);            
        }

        //Get value of element at a given index
        __host__ __device__
        int getVal(int vecIndex, int valIndex){ return cof[vecIndex].set[valIndex];}

        //Get total number of dimensions
        __host__ __device__
        int getDim(){ return dim;}

        //Get size of original set
        __host__ __device__
        int getVecSize(){ return vecSize;}

        //Get size of coface set
        __host__ __device__
        int getCofaceSize(){ return size;}


    private:
        //Data
        int vecSize;
        int dim;
        int size;

        int * dim_start_indecies;
        int * dim_sizes;
        int * dim_end_indecies;

        
        //Cofaces
        setContainer * cof;


        //Private Functions
        __host__ __device__
        int fact(int f){
            int fac = 1;
            for(int i = 1; i <= f; i++){
                fac *= i;
            }
            return fac;
        }

        __host__ __device__
        int factRange(int top, int bottom){
            int fac = 1;
            for(int i = bottom+1; i <= top; i++){
                fac *= i;
            }
            return fac;
        }

        void makeIndex(){
            //Total number of subsets in each dimension
            dim_sizes = new int[dim+1];
            dim_sizes[0] = ncr(vecSize,1);

            //Start point for each dimension
            dim_start_indecies = new int[dim+1];
            dim_start_indecies[0] = 0;
            
            
            //End point for each dimension
            dim_end_indecies = new int[dim+1];
            dim_end_indecies[0] = dim_sizes[0] - 1;

            for(int i = 1; i < dim+1; i++){
                dim_sizes[i] = ncr(vecSize,i+1);
                dim_start_indecies[i] = dim_sizes[i-1] + dim_start_indecies[i-1];
                dim_end_indecies[i] = dim_end_indecies[i-1] + dim_sizes[i];
            }

            //End index + 1 is size
            size = dim_end_indecies[dim]+1;

            #ifdef DEBUG
                for(int i = 0; i < dim+1; i++){
                    std::cout << "Dim: " << i << "\tDim Size: " << dim_sizes[i] << "\tDim Start Index: " << dim_start_indecies[i] << 
                        "\tDim End Index: " << dim_end_indecies[i] << std::endl;
                }
            #endif
        }

        void initializeCofaces(){
            //Initialize host cofaces
            cof = new setContainer[size];

            int index = 0;
            for(int i = 0; i < dim + 1; i++){
                while(index <= dim_end_indecies[i]){
                    cof[index].createContainer(i+1);
                    index++;
                }
            }
        }
};


template<typename T>
__device__ void setCofaces(Set<T> * s, int cur_dim, int index){
    //Get Current Dimension Starting Point
    int cur_dim_index = s->getIndex(cur_dim,index);

    //Get Previous Dimension Start Point
    int prev_dim_index = s->getIndex(cur_dim - 1);


    //Total number of subsets to be added
    int total = s->ncr(index,cur_dim);

    //Grab everything from previous layer
    for(int i = 0; i < total;i++){
        for(int j = 0; j < cur_dim; j++){
            int val = s->getVal(prev_dim_index + i,j);
            s->d_setCoface(cur_dim_index+i,j,val);
        }
        s->d_setCoface(cur_dim_index + i, cur_dim,index);
    }
}

//Initial Dim
template<typename T>
__global__ void locateCofaces(Set<T> * s){

    int index = threadIdx.x; 
    int dim = s->getDim();
    //Set the 0 dimension
    s->d_setCoface(index,0,index);
    printf("Setting Dim 0: %d\n", index);
    __syncthreads();
    for(int d = 1; d <= dim && index >= d; d++){
        printf("Setting Dim %d: %d\n",d,index);
        //setCofaces<<<1,1>>>(s,d,index);
        setCofaces(s,d,index);
        __syncthreads();
    }
}

template<typename T>
Set<T> * setToGPU(Set<T> * h_s){
    #ifdef DEBUG
        std::cout << "Preparing to move set to device memory\n";
    #endif
    //Move Data To Device
    h_s->hostToGPU();

    //Create Device Set
    #ifdef DEBUG
        std::cout << "Creating Device Set\n";
    #endif
    Set<T> * d_s;

    //Allocate
    #ifdef DEBUG
        std::cout << "Allocating Device Set\n";
    #endif
    cudaMalloc((void **) &d_s, sizeof(Set<T>));

    //Copy
    #ifdef DEBUG
        std::cout << "Copying Set from Host To Device\n";
    #endif
    cudaMemcpy(d_s,h_s,sizeof(Set<T>),cudaMemcpyHostToDevice);

    #ifdef DEBUG
        std::cout << "Finished Copying Set To Device\n";
    #endif
    return d_s;
}

template<typename T>
Set<T> * setToHost(Set<T> * d_s){
    //Allocate Host Set
    Set<T> * h_s = new Set<T>();

    //Copy
    cudaMemcpy(h_s,d_s,sizeof(Set<T>), cudaMemcpyDeviceToHost);
    h_s->GPUtoHost();
    return h_s;
}

template<typename T>
__global__ void display(Set<T> *s){
    printf("Device Vec Size: %d\tDevice Dim: %d\n", s->getVecSize(),s->getDim());   
}

void sync(){
    cudaDeviceSynchronize();
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        fprintf(stderr,"Error: %s\n",cudaGetErrorString(error));
        exit(1);
    }
}
