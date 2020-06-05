add_library(SpinSwiftCore
 atom.swift
 constants.swift
 demagnetize.swift
 fileManagement.swift
 geometry.swift
 hamiltonian.swift
 linearAlgebra.swift
 materials.swift
 neighbors.swift
 quantity.swift
 region.swift
 solver.swift
 state.swift
 system.swift
 )

target_compile_options(SpinSwiftCore PRIVATE
  $<$<BOOL:BUILD_TESTING>:-enable-testing>)

set_target_properties(SpinSwiftCore PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

install(TARGETS SpinSwiftCore
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
  COMPONENT lib)