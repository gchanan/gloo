set(gloo_DEPENDENCY_LIBS "")

# Configure path to modules (for find_package)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/Modules/")

if(USE_REDIS)
  # If HIREDIS_ROOT_DIR is not set, default to using hiredis in third-party
  if (NOT HIREDIS_ROOT_DIR)
    if (EXISTS "${PROJECT_SOURCE_DIR}/third-party/hiredis")
      set(HIREDIS_ROOT_DIR "${PROJECT_SOURCE_DIR}/third-party/hiredis")
    endif()
  endif()

  find_package(hiredis REQUIRED)
  if(hiredis_FOUND)
    include_directories(SYSTEM ${hiredis_INCLUDE_DIR})
    list(APPEND gloo_DEPENDENCY_LIBS ${hiredis_LIBRARIES})
  else()
    message(WARNING "\
Not compiling with Redis support. \
Suppress this warning with -DUSE_REDIS=OFF")
    set(USE_REDIS OFF)
  endif()
endif()

if(USE_IBVERBS)
  find_package(ibverbs REQUIRED)
  if(ibverbs_FOUND)
    include_directories(SYSTEM ${ibverbs_INCLUDE_DIR})
    list(APPEND gloo_DEPENDENCY_LIBS ${ibverbs_LIBRARIES})
  else()
    message(WARNING "\
Not compiling with ibverbs support. \
Suppress this warning with -DUSE_IBVERBS=OFF")
    set(USE_IBVERBS OFF)
  endif()
endif()

# Make sure we can find googletest if building the tests
if(BUILD_TEST)
  set(BUILD_GTEST ON CACHE INTERNAL "Builds the googletest subproject")
  set(BUILD_GMOCK OFF CACHE INTERNAL "Builds the googlemock subproject")
  if (EXISTS "${PROJECT_SOURCE_DIR}/third-party/googletest")
    add_subdirectory(third-party/googletest)
  else()
    message(FATAL_ERROR "Could not find googletest; cannot compile tests")
  endif()
endif()

# Make sure we can find Eigen if building the benchmark tool
if(BUILD_BENCHMARK)
  find_package(eigen REQUIRED)
  if(eigen_FOUND)
    include_directories(SYSTEM ${eigen_INCLUDE_DIR})
  else()
    message(FATAL_ERROR "Could not find eigen headers; cannot compile benchmark")
  endif()

  # If hiredis was already found, the following check can be skipped
  if(NOT hiredis_FOUND)
    find_package(hiredis REQUIRED)
    if(hiredis_FOUND)
      include_directories(SYSTEM ${hiredis_INCLUDE_DIR})
      list(APPEND gloo_DEPENDENCY_LIBS ${hiredis_LIBRARIES})
    else()
      message(FATAL_ERROR "Could not find hiredis; cannot compile benchmark")
    endif()
  endif()
endif()
