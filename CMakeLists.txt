cmake_minimum_required (VERSION 3.1)
project (Macaroni)
include(CTest)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

add_custom_command(
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	COMMAND ./codegen-c.pl ./manuf.txt > ${CMAKE_CURRENT_BINARY_DIR}/mac_tree.c
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mac_tree.c
)

add_library(macaroni SHARED
	macaroni.c 
	${CMAKE_CURRENT_BINARY_DIR}/mac_tree.c
)
set_property(TARGET macaroni PROPERTY C_STANDARD 99)

add_executable(mlookup mlookup.c)
set_property(TARGET mlookup PROPERTY C_STANDARD 99)
target_link_libraries(mlookup macaroni)

add_executable(tests test_all.c)
target_link_libraries(tests macaroni)
set_property(TARGET tests PROPERTY C_STANDARD 99)


add_test(NAME test_all_entries 
		COMMAND tests test_all_entries)

add_test(NAME test_bits_maps 
		COMMAND tests test_bits_maps)

add_test(NAME test_partial_match 
		COMMAND tests test_partial_match)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wall")
