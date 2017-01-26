cmake_minimum_required (VERSION 2.6)
project (Macaroni)
include(CTest)

add_custom_command(
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	COMMAND ./codegen-c.pl ./Macaroni/manuf.txt > ${CMAKE_CURRENT_BINARY_DIR}/mac_tree.c
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mac_tree.c
)

add_library(macaroni SHARED
	macaroni.c 
	${CMAKE_CURRENT_BINARY_DIR}/mac_tree.c
)
set_property(TARGET macaroni PROPERTY C_STANDARD 99)

add_executable(test_all test_all.c)
target_link_libraries(test_all macaroni)
set_property(TARGET test_all PROPERTY C_STANDARD 99)


add_test(NAME test_all 
		COMMAND test_all)

