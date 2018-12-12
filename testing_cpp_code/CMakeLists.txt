cmake_minimum_required(VERSION 3.10)
project(testing_cpp_code)

set(CMAKE_CXX_STANDARD 14)

add_library(mylib SHARED IMPORTED)
set_target_properties( mylib PROPERTIES IMPORTED_LOCATION /src/libcyusb.so)

file(GLOB SOURCES
        include/*.h
        main.cpp
        )

add_executable(testing_cpp_code ${SOURCES})
TARGET_LINK_LIBRARIES(testing_cpp_code mylib)