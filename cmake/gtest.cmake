cmake_minimum_required(VERSION 3.2)

set(WORKING_DIR ${CMAKE_CURRENT_BINARY_DIR}/gtest)

find_package(Git)

option(
  gtest_force_shared_crt
  "Use shared (DLL) run-time lib even when Google Test is built as static lib."
  ON)
  
if(NOT EXISTS "${WORKING_DIR}")
	file(MAKE_DIRECTORY "${WORKING_DIR}")
	execute_process(COMMAND ${GIT_EXECUTABLE} clone https://github.com/google/googletest.git ${WORKING_DIR})
else()
	execute_process(COMMAND ${GIT_EXECUTABLE} pull
  WORKING_DIRECTORY ${WORKING_DIR})
endif()

add_subdirectory(${WORKING_DIR}/googletest ${WORKING_DIR}/googletest/build)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set_property(TARGET gtest PROPERTY FOLDER googletest)
set_property(TARGET gtest_main PROPERTY FOLDER googletest)

target_include_directories(gtest PUBLIC ${WORKING_DIR}/googletest/include)


macro(am_incr VAR)
  math(EXPR ${VAR} "${${VAR}}+1")
endmacro(am_incr VAR)


function(am_run_all_tests EXECUTABLE)
  set(TEST_COUNT 0)
  foreach(SRC ${ARGN})
    set(TEST_REGEX "^[ \t]*(INSTANTIATE_TEST_CASE_P|TEST|TEST_F)\\([ ]*([^, ]*)[ ]*,[ ]*([^, \\){]*).*\\)")

    file(STRINGS ${SRC} GTEST_LINES REGEX ${TEST_REGEX})
    foreach(GTEST_LINE ${GTEST_LINES})
      if(${GTEST_LINE} MATCHES ${TEST_REGEX})
        #string(REGEX REPLACE ${TEST_REGEX} "\\2;\\3" GTEST_SPLIT_LINE ${GTEST_LINE})
        set(GTEST_GROUP_NAME ${CMAKE_MATCH_2})
        set(GTEST_TEST_NAME ${CMAKE_MATCH_3})

        #message(${GTEST_LINE})
        #message("1:" ${GTEST_GROUP_NAME})
        #message("2:" ${GTEST_TEST_NAME})
        if(${GTEST_TEST_NAME} STREQUAL "_SAMPLEFILE_")
          file(GLOB SAMPLEFILES "${CMAKE_CURRENT_SOURCE_DIR}/tests/samplefiles/*.gpx")
          foreach(SAMPLEFILE ${SAMPLEFILES})
            get_filename_component(FILENAME "${SAMPLEFILE}" NAME)
            #get_filename_component(FULLPATH "${SAMPLEFILE}" ABSOLUTE)
            am_incr(TEST_COUNT)
            add_test(
              "${GTEST_GROUP_NAME}.${FILENAME}"
              ${EXECUTABLE}
                --gtest_filter="${GTEST_GROUP_NAME}.${GTEST_TEST_NAME}"
                --samplefile="./samplefiles/${FILENAME}"
            )
          endforeach(SAMPLEFILE)
        else()
          if(${CMAKE_MATCH_1} STREQUAL "INSTANTIATE_TEST_CASE_P")
            add_test(
              "${GTEST_GROUP_NAME}.${GTEST_TEST_NAME}"
              ${EXECUTABLE} --gtest_filter="${GTEST_GROUP_NAME}/${GTEST_TEST_NAME}"*
            )
            #message("!!!!${EXECUTABLE} --gtest_filter=${GTEST_GROUP_NAME}/${GTEST_TEST_NAME}*")
          else()
            add_test(
              "${GTEST_GROUP_NAME}.${GTEST_TEST_NAME}"
              ${EXECUTABLE} --gtest_filter="${GTEST_GROUP_NAME}.${GTEST_TEST_NAME}"
            )
            #message("!!!!${GTEST_GROUP_NAME}.${GTEST_TEST_NAME} ${EXECUTABLE} --gtest_filter=${GTEST_GROUP_NAME}.${GTEST_TEST_NAME}")
          endif()
          am_incr(TEST_COUNT)
        endif()
      endif(${GTEST_LINE} MATCHES ${TEST_REGEX})
      #message("    ADDING TEST "${GTEST_GROUP_NAME}"."${GTEST_TEST_NAME})
    endforeach()
  endforeach()
  message("-- Adding ${TEST_COUNT} tests for : ${EXECUTABLE}")
endfunction(am_run_all_tests)

