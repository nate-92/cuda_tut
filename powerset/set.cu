#include "set.cuh"

int main(){
    int set[] = {1,2,3,4};
    std::vector<int> orig_set(set, set + sizeof(set)/sizeof(int));
    Set<int> s(orig_set);
    //s.display();
    s.makeCofaceSet(2);
}