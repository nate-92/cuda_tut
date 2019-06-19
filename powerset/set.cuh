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
            vecSize_fact = fact(vecSize);
        }

        void display(){
            std::cout << "Size: " << vecSize << std::endl;
            std::cout << "vecSize_fact: " << vecSize_fact << std::endl;
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

    private:
        //Data
        size_t vecSize;
        int vecSize_fact;
        thrust::host_vector<T> h_set;
        thrust::device_vector<T> d_set;

        thrust::host_vector<T> h_powerset; 
        thrust::device_vector<T> d_powerset;


        //Private Functions
        int fact(int f){
            int fac = 1;

            for(int i = 1; i <= f; i++){
                fac *= i;
            }

            return fac;
        }
       
       
        int ncr(int f){
            return vecSize_fact/(fact(f) * fact(vecSize - f));
        }
};