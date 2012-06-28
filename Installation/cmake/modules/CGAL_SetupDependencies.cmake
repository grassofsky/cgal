include(CGAL_Macros)

message ( STATUS "External libraries supported: ${CGAL_SUPPORTING_3RD_PARTY_LIBRARIES}")

foreach (lib ${CGAL_SUPPORTING_3RD_PARTY_LIBRARIES})

  # Part 1: Try to find lib

  set (vlib "${CGAL_EXT_LIB_${lib}_PREFIX}")

  list(FIND CGAL_MANDATORY_3RD_PARTY_LIBRARIES "${lib}" POSITION)
  #if ("${POSITION}" STRGREATER "-1" OR WITH_${lib})
  if (WITH_${lib}) 

    # message (STATUS "With ${lib} given")

    if ( CGAL_ENABLE_PRECONFIG )
      message (STATUS "Preconfiguring library: ${lib} ...")
    else()
      message (STATUS "Configuring library: ${lib} ...")
    endif()
  
    find_package( ${lib} )
   
    if ( ${vlib}_FOUND ) 
      if ( CGAL_ENABLE_PRECONFIG )
        message( STATUS "${lib} has been preconfigured:") 
        message( STATUS "  CGAL_Use${lib}-file: ${${vlib}_USE_FILE}") 
        message( STATUS "  ${lib} include:      ${${vlib}_INCLUDE_DIR}" )
        message( STATUS "  ${lib} libraries:    ${${vlib}_LIBRARIES}" )
        message( STATUS "  ${lib} definitions:  ${${vlib}_DEFINITIONS}" )
      else() 
        message( STATUS "${lib} has been configured") 
        use_lib( ${vlib} "{${vlib}_USE_FILE}")
      endif()
   
      # TODO EBEB what about Qt3, Qt4, zlib etc?
      set ( CGAL_USE_${vlib} TRUE )


      # Part 2: Add some lib-specific definitions or obtain version
   
      if (${lib} STREQUAL "GMP") 
        get_dependency_version(GMP)
      endif()

      if (${lib} STREQUAL "MPFR") 
        set( MPFR_DEPENDENCY_INCLUDE_DIR ${GMP_INCLUDE_DIR} )
        set( MPFR_DEPENDENCY_LIBRARIES   ${GMP_LIBRARIES} )
        get_dependency_version(MPFR)
      endif()

      if (${lib} STREQUAL "LEDA") 
        # special case for LEDA - add a flag
        message( STATUS "$LEDA cxx flags:   ${LEDA_CXX_FLAGS}" )
        uniquely_add_flags( CMAKE_CXX_FLAGS ${LEDA_CXX_FLAGS} )
      endif()

    else() 
   
      if ("${POSITION}" STRGREATER "-1") 
        message( FATAL_ERROR "CGAL requires ${lib} to be found" )
      endif()

    endif()

  endif()

endforeach()

if( (GMP_FOUND AND NOT MPFR_FOUND) OR (NOT GMP_FOUND AND MPFR_FOUND) )
  message( FATAL_ERROR "CGAL needs for its full functionality both GMP and MPFR.")
endif()

if( NOT GMP_FOUND )
  set(CGAL_NO_CORE ON)
  message( STATUS "CGAL_Core needs GMP, cannot be configured.")
endif( NOT GMP_FOUND )

# finally setup Boost
include(CGAL_SetupBoost)
