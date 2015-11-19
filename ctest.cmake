# pour lancer ce script sur la branche develop : 
# ctest -DBRANCH=develop -S ctest.cmake

set(CTEST_BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
set(CTEST_SOURCE_DIRECTORY "${CTEST_BASE_DIRECTORY}/src")
set(CTEST_BINARY_DIRECTORY "${CTEST_BASE_DIRECTORY}/bin")

set(CTEST_SITE "build-win")
set(CTEST_BUILD_NAME "build-windows")
set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015")

set(CTEST_BUILD_CONFIGURATION "Release")

SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY_ONCE TRUE)

ctest_empty_binary_directory("${CTEST_BINARY_DIRECTORY}")

find_program(CTEST_GIT_COMMAND NAMES git)

if(NOT EXISTS "${CTEST_SOURCE_DIRECTORY}")
  set(CTEST_CHECKOUT_COMMAND "\"${CTEST_GIT_COMMAND}\" clone -b \"${BRANCH}\" git@github.com:twxs/ctest.git ${CTEST_SOURCE_DIRECTORY}")
endif()

set(CTEST_UPDATE_COMMAND "${CTEST_GIT_COMMAND}")

set(CTEST_CONFIGURE_COMMAND "\"${CMAKE_COMMAND}\" \"-G${CTEST_CMAKE_GENERATOR}\" \"${CTEST_SOURCE_DIRECTORY}\"")

set(CTEST_TEST_TYPE "Continuous")

message("*** CTEST STARTING ${CTEST_TEST_TYPE} ***")
ctest_start(${CTEST_TEST_TYPE})
message("*** CTEST UPDATING ***")
ctest_update()
message("*** CTEST CONFIGURING ***")
ctest_configure() #(BUILD "${CTEST_BINARY_DIRECTORY}" SOURCE "${CTEST_SOURCE_DIRECTORY}") # par dÃ©faut
message("*** CTEST BUILDING ***")
ctest_build()
message("*** CTEST TESTING ***")
ctest_test()
# if (WITH_COVERAGE AND CTEST_COVERAGE_COMMAND)
#   message("*** CTEST TESTING COVERAGE ***")
#   ctest_coverage()
# endif (WITH_COVERAGE AND CTEST_COVERAGE_COMMAND)
# if (WITH_MEMCHECK AND CTEST_MEMORYCHECK_COMMAND)
#   message("*** CTEST TESTING MEMORY LEAKS ***")
#   ctest_memcheck()
# endif (WITH_MEMCHECK AND CTEST_MEMORYCHECK_COMMAND)
message("*** CTEST SUBMITING ***")
#ctest_submit()