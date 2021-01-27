# Qt Widgets for Technical Applications
# available at http://www.http://qwt.sourceforge.net/
#
# The module defines the following variables:
#  Qwt_FOUND - the system has Qwt
#  QWT_INCLUDE_DIR - where to find qwt_plot.h
#  QWT_INCLUDE_DIRS - qwt includes
#  QWT_LIBRARY - where to find the Qwt library
#  QWT_LIBRARIES - aditional libraries
#  QWT_VERSION_STRING - version (ex. 5.2.1)
#
# It also defines this imported target:
#  Qwt::Qwt

#=============================================================================
# Copyright 2010-2013, Julien Schueller
# Copyright 2018-2020, Rolf Eike Beer
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies, 
# either expressed or implied, of the FreeBSD Project.
#=============================================================================

if (Qt5Gui_FOUND)
  get_target_property(QT_INCLUDE_DIR Qt5::Gui INTERFACE_INCLUDE_DIRECTORIES)
endif ()

message(STATUS "Qt include dir: ${QT_INCLUDE_DIR}")

find_path ( QWT6_INCLUDE_DIR
  NAMES qwt_plot.h
  HINTS ${QT_INCLUDE_DIR}
  PATH_SUFFIXES qwt qwt-qt5 qwt6 qwt6-qt5
)


set ( QWT6_INCLUDE_DIRS ${QWT6_INCLUDE_DIR} )
message(STATUS "Qwt6 include dir: ${QWT6_INCLUDE_DIR}")

# version
set ( _VERSION_FILE ${QWT6_INCLUDE_DIR}/qwt_global.h )
if ( EXISTS ${_VERSION_FILE} )
  file ( STRINGS ${_VERSION_FILE} _VERSION_LINE REGEX "define[ ]+QWT_VERSION_STR" )
  if ( _VERSION_LINE )
    string ( REGEX REPLACE ".*define[ ]+QWT_VERSION_STR[ ]+\"([^\"]*)\".*" "\\1" QWT6_VERSION_STRING "${_VERSION_LINE}" )
  endif ()
endif ()
unset ( _VERSION_FILE )

find_library ( QWT6_LIBRARY
  NAMES qwt qwt-qt5 qwt6 qwt6-qt5
  HINTS ${QT_LIBRARY_DIR}
)

set ( QWT6_LIBRARIES ${QWT6_LIBRARY} )

include ( FindPackageHandleStandardArgs )
find_package_handle_standard_args( Qwt6 REQUIRED_VARS QWT6_LIBRARY QWT6_INCLUDE_DIR VERSION_VAR QWT6_VERSION_STRING )

if (Qwt6_FOUND AND NOT TARGET Qwt6::Qwt6)
  add_library(Qwt6::Qwt6 UNKNOWN IMPORTED)
  set_target_properties(Qwt6::Qwt6 PROPERTIES
                        INTERFACE_INCLUDE_DIRECTORIES "${QWT6_INCLUDE_DIRS}"
                        IMPORTED_LOCATION "${QWT6_LIBRARIES}")
endif ()

mark_as_advanced (
  QWT6_LIBRARY
  QWT6_INCLUDE_DIR
)
