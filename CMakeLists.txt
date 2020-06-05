if(UNIX)
  if(APPLE OR MINGW)
    cmake_minimum_required(VERSION 3.15.1)
    if (CMAKE_VERSION LESS OR EQUAL 3.15.1)
          message(STATUS "Please upgrade to the latest release of cmake in order to build the project...")
    endif()
  elseif(NOT APPLE)
    cmake_minimum_required(VERSION 3.15.1)
    if (CMAKE_VERSION LESS OR EQUAL 3.15.1)
          message(STATUS "Please upgrade to the latest release of cmake in order to build the project...")
    endif()
  endif()
endif()

project(SpinSwift VERSION 0.1.0.0 LANGUAGES Swift)

message(STATUS "This system is ${CMAKE_HOST_SYSTEM}")

set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if(CMAKE_SYSTEM_NAME STREQUAL Windows OR CMAKE_SYSTEM_NAME STREQUAL Darwin)
  option(BUILD_SHARED_LIBS "Build shared libraries by default" YES)
endif()

# enable testing by default on debug mode
if(CMAKE_BUILD_TYPE STREQUAL Debug)
  option(BUILD_TESTING "Build tests" YES)
endif()

add_subdirectory(Sources)

if(BUILD_TESTING)
  add_subdirectory(Tests)
endif()
