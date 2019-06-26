#include "set.cuh"
#define DEBUG


int main(){
    std::vector<int> set(698);
    for(int i = 0; i < set.size(); i++){
        set[i] = i+1;
    }


    Set<int> * h_s = new Set<int>(set,2);
    Set<int> * d_s = setToGPU(h_s);

    #ifdef DEBUG
        std::cout << "Locating Cofaces\n";
        std::cout << "Local Vec Size: " << h_s->getVecSize() << "\tLocal Dim: " << h_s->getDim() << std::endl;
        display<<<1,1>>>(d_s);
    #endif

    sync();

    locateCofaces<<<1,h_s->getVecSize()>>>(d_s);
    sync();

    #ifdef DEBUG
        std::cout << "Finished locating cofaces\n";
    #endif

    h_s = setToHost(d_s);
    h_s->display();


    std::vector<int> * cofaces = h_s->getCofaces(set);
    /*int size = h_s->getCofaceSize();

    for(int i = 0; i < size; i++){
        std::vector<int> coface = cofaces[i];
        for(int j = 0; j < coface.size(); j++){
            std::cout << coface[j];
        }
        std::cout << std::endl;
    }*/
    //s.makeCofaceSet(2);
}