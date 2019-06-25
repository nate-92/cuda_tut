typedef struct setContainer{
    int * set;
    int size;

    void createContainer(thrust::device_vector<int> d_vec){
        set = thrust::raw_pointer_cast(&d_vec[0]);
        size = d_vec.size();
    }
    void createContainer(thrust::host_vector<int> h_vec){
        set = thrust::raw_pointer_cast(&h_vec[0]);
        size = h_vec.size();
    }
    void createContainer(int s){
        size = s;
        cudaMalloc((void **) &set, sizeof(int) * size);
    }

    void toHost(){
        //Allocate container on host
        int * h_set = new int[size];

        //Copy from device to host
        cudaMemcpy(h_set,set,sizeof(int) * size, cudaMemcpyDeviceToHost);

        //Free Device
        //cudaFree(set);
        set = h_set;
    }

    void toDevice(){
        int * d_set;
        //Allocate container to GPU
        cudaMalloc((void **) &d_set, sizeof(int) * size);

        //Copy from host to device
        cudaMemcpy(d_set, set, sizeof(int) * size, cudaMemcpyHostToDevice);

        //Free host
        //free(set);
        set = d_set;
    }
}setContainer;