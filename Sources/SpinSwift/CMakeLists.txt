
add_executable(SpinSwift main.swift)

target_link_libraries(SpinSwift PRIVATE SpinSwiftCore)

set_target_properties(SpinSwift PROPERTIES Swift_LANGUAGE_VERSION 5)

install(TARGETS SpinSwift DESTINATION bin COMPONENT exe)

