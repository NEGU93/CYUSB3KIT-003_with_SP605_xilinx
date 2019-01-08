cmake_minimum_required(VERSION 3.10)
project(testing_cpp_code)

set(CMAKE_CXX_STANDARD 14)


file(GLOB SOURCES
        include/*.h
        src/*.cpp
        main.cpp
        )

add_executable(testing_cpp_code ${SOURCES})
target_link_libraries(testing_cpp_code usb-1.0 pthread)