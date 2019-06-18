int main(){
    float * tst;
    cudaMalloc((void **) &tst, sizeof(float) * 10);
}