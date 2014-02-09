#include <mylib/mylib.h>

#include <string>
#include <iostream>

int main(int argc, char **argv) {
  mylib::Message msg("hello");
  std::cout << msg.get() << "\n";
  return 0;
}
