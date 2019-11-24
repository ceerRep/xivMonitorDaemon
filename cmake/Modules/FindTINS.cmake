# - Try to find libtins include dirs and libraries
#
# Usage of this module as follows:
#
#     find_package(TINS)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  TINS_ROOT_DIR             Set this variable to the root installation of
#                            libtins if the module has problems finding the
#                            proper installation path.
#
# Variables defined by this module:
#
#  TINS_FOUND                System has libtins, include and library dirs found
#  TINS_INCLUDE_DIR          The libtins include directories.
#  TINS_LIBRARY              The libtins library 

find_path(TINS_ROOT_DIR
    NAMES include/tins/tins.h
)

find_path(TINS_INCLUDE_DIR
    NAMES tins/tins.h
    HINTS ${TINS_ROOT_DIR}/include
)

set (HINT_DIR ${TINS_ROOT_DIR}/lib)

find_library(TINS_LIBRARY
    NAMES tins
    HINTS ${HINT_DIR}
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TINS DEFAULT_MSG
    TINS_LIBRARY
    TINS_INCLUDE_DIR
)

include(CheckCXXSourceCompiles)
set(CMAKE_REQUIRED_LIBRARIES ${TINS_LIBRARY})
check_cxx_source_compiles("int main() { return 0; }" TINS_LINKS_SOLO)
set(CMAKE_REQUIRED_LIBRARIES)

# check if linking against libtins also needs to link against a thread library
if (NOT TINS_LINKS_SOLO)
    find_package(Threads)
    if (THREADS_FOUND)
        set(CMAKE_REQUIRED_LIBRARIES ${TINS_LIBRARY} ${CMAKE_THREAD_LIBS_INIT})
        check_cxx_source_compiles("int main() { return 0; }" TINS_NEEDS_THREADS)
        set(CMAKE_REQUIRED_LIBRARIES)
    endif (THREADS_FOUND)
    if (THREADS_FOUND AND TINS_NEEDS_THREADS)
        set(_tmp ${TINS_LIBRARY} ${CMAKE_THREAD_LIBS_INIT})
        list(REMOVE_DUPLICATES _tmp)
        set(TINS_LIBRARY ${_tmp}
            CACHE STRING "Libraries needed to link against libtins" FORCE)
    else (THREADS_FOUND AND TINS_NEEDS_THREADS)
        message(FATAL_ERROR "Couldn't determine how to link against libtins")
    endif (THREADS_FOUND AND TINS_NEEDS_THREADS)
endif (NOT TINS_LINKS_SOLO)

include(CheckFunctionExists)
set(CMAKE_REQUIRED_LIBRARIES ${TINS_LIBRARY})
set(CMAKE_REQUIRED_LIBRARIES)

mark_as_advanced(
    PCAP_ROOT_DIR
    PCAP_INCLUDE_DIR
    PCAP_LIBRARY
)
