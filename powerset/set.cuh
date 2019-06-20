#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/fill.h>
#include <vector>
#include <iostream>
#include <math.h>

template<typename T>
class Set{
    public:
        Set(std::vector<T> i_set){
            //Set Magnitude of set
            vecSize = i_set.size();
            h_set.resize(vecSize);
            d_set.resize(vecSize);
            //Copy Set to Host
            thrust::copy(i_set.begin(),i_set.end(),h_set.begin());
            //Copy Set to Device
            thrust::copy(h_set.begin(),h_set.end(),d_set.begin());
            //vecSize_fact = fact(vecSize);
        }

        void display(){
            std::cout << "Size: " << vecSize << std::endl;
            //std::cout << "vecSize_fact: " << vecSize_fact << std::endl;
            displayOriginalSet();
        }

        void displayOriginalSet(){
            for(int i = 0; i < vecSize;i++){
                std::cout << d_set[i] << "\t";
            }
            std::cout << std::endl;
        }

        void displayPowerSet(){
            for(int i = 0; i < pow(2,vecSize); i++){
                std::cout << "Element" << i << std::endl;
                for(int j = 0; j < vecSize; j++){
                    if(i & (1 << j)){
                        std::cout<< h_set[j];
                    }
                }
                std::cout << std::endl;
            }
        }

        void makeCofaceSet(int dim){
            std::vector<std::vector<int> > powerSet;
            powerSet.clear();

            for(int i = 0; i < pow(2,vecSize); i++){
                std::vector<int> set;
                set.clear();
                for(int j = 0; j < vecSize; j++){
                    if(i & (1 << j)){
                        set.push_back(h_set[j]);
                        if(set.size() >= dim){
                            break;
                        }
                    }
                }
                powerSet.push_back(set);
            }

            for(int i = 0; i < powerSet.size(); i++){
                for(int j = 0; j < powerSet[i].size(); j++){
                    std::cout << powerSet[i][j];
                }
                std::cout << std::endl;
            }
        }

        __device__
        int * getLowers(int index){
            int * lowerNeighbors;
            cudaMalloc((void **) &lowerNeighbors, sizeof(int) * index);
            for(int i = 0; i < index){
                lowerNeighbors[i] = index;
            }
            return lowerNeighbors;

        }

        void initialize_cofaces(int dim){
            //Maximum number of dimensions for a given subset
            h_cofaces.resize(dim);
            for(int i = 0; i < dim; i++){
                //Each dimension has n ncr i number of sets
                h_cofaces[i].resize(ncr(i));
                //Each set is of length i+1
                //ie) dim 0 has only 1 element, dim 1 has 2 elements
                for(int j = 0; j < h_cofaces.size(); j++){
                    h_cofaces[i][j].resize(i+1);
                }
            }
            //Set d_cofaces to be the same as h_cofaces
            d_cofaces = h_cofaces;
        }

        __device__
        void d_setCoface(dim3 index, int pos){
            //dimension x, coface y, position z
            d_bivector[index.x][index.y][index.z]= pos;
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

    private:
        //Data Type
        typedef thrust::host_vector<thrust::host_vector<T> > h_bivector;
        typedef thrust::device_vector<thrust::device_vector<T> > d_bivector;


        //Data
        size_t vecSize;
        int vecSize_fact;
        int dim;

        thrust::host_vector<T> h_set;
        thrust::device_vector<T> d_set;
        thrust::host_vector<h_bivector> h_cofaces;
        thrust::device_vector<d_bivector> d_cofaces;

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
            for(int i = bottom; i <= top; i++){
                fac *= i;
            }
            return fac;
        }
};


__global__ void setCofaces(Set s, int * nbrs, int cur_dim, int index);

//Initial 0 Dim
__global__ locateCofaces(Set s, int dim){
    int index = threadIdx.x;
    //Get lower neighbor indecies
    int * nbrs = s.getLowers(index);

    //Set the 0 dimension
    dim3 zero_index(0,index,0);
    s.d_setCoface(zero_index,index)

    for(int d = 1; d < dim; d++){
        setCofaces<<<1,1>>>(s,nbrs,d,index);
        
    }
}

__global__ void setCofaces(Set s, int * nbrs, int cur_dim, int index){
    int index = s.ncr(index+1,cur_dim+1);
    int total = s.ncr(index,cur_dim);

    //Grab everything from previous layer
    for(int i = 0; i < total;i++){

    }



}