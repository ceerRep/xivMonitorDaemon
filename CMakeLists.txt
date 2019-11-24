CMAKE_MINIMUM_REQUIRED(VERSION 3.10.0)
PROJECT(xivminitordaemon)

# Compilation flags.
IF(MSVC)
    # Don't always use Wall, since VC's /Wall is ridiculously verbose.
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3")
    # Disable VC secure checks, since these are not really issues.
    ADD_DEFINITIONS("-D_CRT_SECURE_NO_WARNINGS=1")
    ADD_DEFINITIONS("-D_SCL_SECURE_NO_WARNINGS=1")
    ADD_DEFINITIONS("-DNOGDI=1")
ELSE()
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")
ENDIF()

IF(APPLE)
    # This is set to ON as of policy CMP0042
    SET(CMAKE_MACOSX_RPATH ON)
ENDIF()

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/")

# CXX STANDARD
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

FIND_PACKAGE(TINS REQUIRED)
FIND_PACKAGE(PCAP REQUIRED)
FIND_PACKAGE(Boost REQUIRED)

# Set some Windows specific flags
IF(WIN32)
    # We need to link against these libs
    SET(OS_LIBS Ws2_32.lib Iphlpapi.lib)

    # Add the NOMINMAX macro to avoid Windows' min and max macros.
    ADD_DEFINITIONS(-DNOMINMAX)

    # MinWG need some extra definitions to compile properly (WIN32 for PCAP and WIN32_WINNT version for ws2tcpip.h)
    IF(MINGW)
        ADD_DEFINITIONS(-DWIN32)
        MACRO(get_WIN32_WINNT version)
        IF (WIN32 AND CMAKE_SYSTEM_VERSION)
            SET(ver ${CMAKE_SYSTEM_VERSION})
            STRING(REPLACE "." "" ver ${ver})
            STRING(REGEX REPLACE "([0-9])" "0\\1" ver ${ver})
            SET(${version} "0x${ver}")
        ENDIF()
        ENDMACRO()
        get_WIN32_WINNT(ver)
        ADD_DEFINITIONS(-D_WIN32_WINNT=${ver})
    ENDIF(MINGW)

ENDIF(WIN32)

include_directories(${Boost_INCLUDE_DIRS}) 
include_directories(${PCAP_INCLUDE_DIR}) 
add_executable(xivMonitorDaemon main.cpp) 
target_link_libraries(xivMonitorDaemon ${Boost_LIBRARIES})
target_link_libraries(xivMonitorDaemon ${PCAP_LIBRARY})
target_link_libraries(xivMonitorDaemon ${OS_LIBS})
