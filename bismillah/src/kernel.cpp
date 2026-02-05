extern "C" void kernel_main();

extern "C" void _start() {
    kernel_main();
     while (1) {}
}
extern "C" void kernel_main() {
    char* video = (char*)0xb8000;
    video[0] = 'X';
    video[1] = 0x0F;

}

