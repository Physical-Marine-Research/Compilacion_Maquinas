#!/bin/bash

##############################################
##### Create the folders structure

##############################################
### Preinstall the following paquages 

# sudo apt install build-essential  
# esto instala varios paquetes entre ellos gcc g++ make


# sudo apt install gfortran g++ make
# change the binary files name to avoid the latter to be erased 

# This for NETCDF
# sudo apt-get install  zlib1g zlib1g-dev libcurl4 libcurl4-gnutls-dev
# sudo apt-get install m4


# REVISAR 
# gcc gfortran make m4 


module load mpi/2021.9.0


###############################################
###############################################
#####        GENERAL INFORMATION

BASE=`pwd`
IMPLEDIR=${BASE}/00_LIBS

DIR_FVCOM=${BASE}/FVCOM

SOURCEFOLDER=${BASE}/SourceFiles
COMPIDIR=${BASE}/Forcompiling

MPI_FOLDER=${IMPLEDIR}/002_mpich
HDF5_FOLDER=${IMPLEDIR}/003_hdf5
NETCDF_FOLDER=${IMPLEDIR}/004_netcdf

OPENMPI_DIR=${IMPLEDIR}/010_openmpi
HDF5_opnempi_DIR=${IMPLEDIR}/011_hdf5
NETCDF_openmpi_DIR=${IMPLEDIR}/012_netcdf

##################################################
##############       COMPILADORES 
##################################################

#MYFORTRAN=/home/LIBS/001_Impl/001_gfortran/gfortran
MYFORTRAN="/usr/local/gfortran/bin/gfortran -fallow-argument-mismatch"
MYFORTRAN=gfortran
MYCC=/usr/local/gfortran/bin/gcc
MYCPP=/usr/local/gfortran/bin/cpp
MYCXX=/usr/local/gfortran/bin/g++


# -fallow-argument-mismatch
#MYFORTRAN="/opt/homebrew/bin/gfortran-13 -fallow-argument-mismatch"
#MYCC=/opt/homebrew/bin/gcc-13
#MYCPP=/opt/homebrew/bin/cpp-13
#MYCXX=/opt/homebrew/bin/g++-13

MYFORTRAN="gfortran -fallow-argument-mismatch"
MYCC=gcc
MYCPP=cpp
MYCXX=g++


MYFORTRAN=mpif90
MYCC=mpigcc
MYCPP=cpp
MYCXX=mpigxx
##########################################################
######      WHICH SECTION WILL BE EXECUTED 
##########################################################
#SEC=(0 1 0 0   0 0 0 0  0)

# 4 libs based on MPI ##################
SEC[0]=0   # MPI
SEC[1]=0   # HDF5     [mpich2]
SEC[2]=0   # NETCDF   [mpich2]
SEC[3]=0   # NETCDF-FORTRAN  [mpich2]

# 4 libs based on openmpi ##############
SEC[4]=0   # OPENMPI
SEC[5]=0   # HDF5    [openmpi]
SEC[6]=0   # NETCDF  [openmpi]
SEC[7]=0   # NETCDF-Fortran  [openmpi]

# MODELS ################################
SEC[8]=1   # FVCOM0

# >>>>>>>>>>>>>>>>>>     END CONFIGURATION   <<<<<<<<<<<<<<<<<<<<<<<<<


################################
###   CREATE PATHS
################################


[ ! -d "$COMPIDIR" ] && mkdir -p $COMPIDIR

#if true; then exit 1;  fi

iii=0
###############################################
####					COMPILE MPICH

# sudo apt install gfortran g++ make
if [ "${SEC[${iii}]}" == 1 ]; then
        echo " Implementing MPICH library"
	cd ${COMPIDIR}
	rm -r ${COMPIDIR}/*
	tar -xzf ${SOURCEFOLDER}/mpich-4.1.1.tar.gz
	#mpich-3.2.tar.gz
	cd mpich-4.1.1/
	[ ! -d "$MPI_FOLDER" ] && mkdir -p ${MPI_FOLDER}
        echo $IMPLEDIR
	# $MYFORTRAN -w -fallow-argument-mismatch -O2
	# -L/usr/local/gfortran/lib . -L/opt/homebrew/Cellar/gcc/13.1.0/lib/gcc/13
        CC=$MYCC  \
        CPP=$MYCPP  \
	CXX=$MYCXX  \
	#LDFLAGS="-L/opt/homebrew/Cellar/gcc/13.1.0/lib/gcc/13"  \
	FC=$MYFORTRAN ./configure --prefix=${MPI_FOLDER} --enable-fortran=all  &>  ${IMPLEDIR}/CONF_MPICH
	# --enable-cxx  --disable-cxx
	make  &>  ${IMPLEDIR}/MAKE_MPICH
	make install  &>  ${IMPLEDIR}/MAKEINSTALL_MPICH
fi



((iii+=1))
echo $iii
###############################################
####					COMPILE HDF5
if [ "${SEC[${iii}]}" == 1 ]; then
	echo " Implementing HDF5 library"
	cd ${COMPIDIR}
	rm -r ${COMPIDIR}/*
	tar -xf ${SOURCEFOLDER}/hdf5-1.8.23.tar.gz 
	cd hdf5-1.8.23
	[ ! -d "$HDF5_FOLDER" ] && mkdir -p ${HDF5_FOLDER}
	FC=$MYFORTRAN \
        CC=$MYCC \
        CXX=$MYCXX \
	CPP=$MYCPP \
        ./configure --prefix=${HDF5_FOLDER} --enable-fortran --enable-parallel &> ${IMPLEDIR}/CONF_HDF5
        # aarch64-unknown-linux-gnu        aarch64-unknown-linux-gnu   --build=aarch64-unknown-linux-gnu
	make &> ${IMPLEDIR}/MAKE_HDF5
	make install &> ${IMPLEDIR}/MAKEINSTALL_HDF5
fi

((iii+=1))
echo $iii

###############################################
####					COMPILE NETCDF4
if [ "${SEC[${iii}]}" == 1 ]; then
	echo " Implementing NetCDF library"
	cd ${COMPIDIR}
	rm -r ${COMPIDIR}/*
	tar -xf ${SOURCEFOLDER}/netcdf-4.4.1.1.tar.gz
	cd netcdf-4.4.1.1
	[ ! -d "$NETCDF_FOLDER" ] && mkdir -p ${NETCDF_FOLDER}
	CC="${MYCC} -Wno-implicit-function-declaration" \
        CPPFLAGS=-I${HDF5_FOLDER}/include  \
        CXX=${MYCXX} \
        LDFLAGS=-L${HDF5_FOLDER}/lib ./configure --prefix=${NETCDF_FOLDER}  --enable-parallel-test --enable-dap &> ${IMPLEDIR}/CONF_NETCDF
	# --disable-shared
	make &> ${IMPLEDIR}/MAKE_NETCDF
	make install &> ${IMPLEDIR}/MAKEINSTALL_NETCDF
fi

((iii+=1))
echo $iii
#echo ${SEC[${iii}]}
###############################################
####					COMPILE NETCDF4-FORTRAN
if [ "${SEC[${iii}]}" == 1 ]; then
	echo " Implementing NETCDF-FORTRAN library"
	cd ${COMPIDIR}
	rm -r ${COMPIDIR}/*
	tar -xf ${SOURCEFOLDER}/netcdf-fortran-4.4.4.tar.gz
	cd netcdf-fortran-4.4.4

	
	[ ! -d "$NETCDF_FOLDER" ] &&  echo "Directory $NETCDF_FOLDER does not exist"


	LIBS="`${NETCDF_FOLDER}/bin/nc-config --libs`"
	echo $LIBS
	F90=${MYFORTRAN} \
	FC=${MYFORTRAN} \
	CC=${MYCC}  \
	LIBS="`${NETCDF_FOLDER}/bin/nc-config --libs`" \
	LDFLAGS=-L${HDF5_FOLDER}/lib \
	CPPFLAGS="-I${NETCDF_FOLDER}/include -I${HDF5_FOLDER}/include" \
	CXX=${MYCXX} \
	./configure --prefix=${NETCDF_FOLDER}  &> ${IMPLEDIR}/CONF_NETCDF_FORTRAN
	make &> ${IMPLEDIR}/MAKE_NETCDF_FORTRAN
	make install &> ${IMPLEDIR}/MAKEINSTALL_NETCDF_FORTRAN
	# Se necesita defenir LIBS para que se genere el netcdf4
	#LIBS="-L${NETCDF_FOLDER}/lib -L${HDF5_FOLDER}/lib -lnetcdf -lhdf5_hl -lhdf5 -ldl -lm -lz" \
	# LDFLAGS no se necesita para que aparesca el nc4
	#LDFLAGS="-L/home/Modelling/001_Impl/004_netcdf/lib -L/home/Modelling/001_Impl/003_hdf5/lib -lnetcdf -lhdf5_hl -lhdf5 -ldl -lm -lz" \
fi

((iii+=1))
echo $iii



###############################################
####                                    COMPILE OPENMP
if [ "${SEC[${iii}]}" == 1 ]; then
        echo " Implementing OPENMPI library"
        cd ${COMPIDIR}
        rm -r ${COMPIDIR}/*
        tar -xf ${SOURCEFOLDER}/openmpi-4.1.5.tar.gz
        cd openmpi-4.1.5 


        [ ! -d "$OPENMPI_DIR" ] &&  echo "Directory $OPENMPI_DIR does not exist"
        #FC="$MYFORTRAN -w -fallow-argument-mismatch -O2"
	echo $IMPLEDIR 
        CC=$MYCC \
        CPP=$MYCPP \
        CXX=$MYCXX \
        FC=$MYFORTRAN \
        ./configure --prefix=${OPENMPI_DIR} &> ${IMPLEDIR}/CONF_OPENMPI 
        #--enable-fortran=all
        # --enable-cxx  --disable-cxx
        make  &>  ${IMPLEDIR}/MAKE_OPENMPI
        make install  &>  ${IMPLEDIR}/MAKEINSTALL_OPENMPI
fi






((iii+=1))
echo $iii
###############################################
####                                    COMPILE HDF5  WITH OPENMPI 
if [ "${SEC[${iii}]}" == 1 ]; then
        echo " Implementing HDF5 WITH OPENMPI library"
        cd ${COMPIDIR}
        rm -r ${COMPIDIR}/*
        tar -xf ${SOURCEFOLDER}/hdf5-1.8.19.tar
        cd hdf5-1.8.19
        [ ! -d "$HDF5_openmpi_DIR" ] && mkdir -p ${HDF5_openmpi_DIR}

        FC=${OPENMPI_DIR}/bin/mpif90 \
        CC=${OPENMPI_DIR}/bin/mpicc \
	LIBS="" \
	LDFLAGS=-L${OPENMPI_DIR}/lib \
        CXX=${OPENMPI_DIR}/bin/mpicxx \
	./configure --prefix=${HDF5_openmpi_DIR} --enable-fortran  &> ${IMPLEDIR}/CONF_HDF5_openmpi
        make &> ${IMPLEDIR}/MAKE_HDF5_openmpi 
        make install &> ${IMPLEDIR}/MAKEINSTALL_HDF5_openmpi
fi



((iii+=1))
echo $iii
###############################################
####                                    COMPILE NETCDF4
if [ "${SEC[${iii}]}" == 1 ]; then
        echo " Implementing NetCDF with openmpi library"
        cd ${COMPIDIR}
        rm -r ${COMPIDIR}/*
        tar -xf ${SOURCEFOLDER}/netcdf-4.4.1.1.tar.gz
        cd netcdf-4.4.1.1
        [ ! -d "$NETCDF_FOLDER" ] && mkdir -p ${NETCDF_FOLDER}
        CC="${MPI_FOLDER}/bin/mpicc -Wno-implicit-function-declaration"
        CPPFLAGS=-I${HDF5_FOLDER}/include
        CXX=${MPI_FOLDER}/bin/mpicxx  
        LDFLAGS=-L${HDF5_FOLDER}/lib ./configure --prefix=${NETCDF_FOLDER}  --enable-parallel-test --enable-dap &> ${IMPLEDIR}/CONF_NETCDF
        # --disable-shared
        make &> ${IMPLEDIR}/MAKE_NETCDF
        make install &> ${IMPLEDIR}/MAKEINSTALL_NETCDF
fi



###############################################
##	UPDATE THE PATH AND LIBRARY_PATH ENVIROMENT VARIABLES



###############################################
####             FVCOM   
###############################################
((iii+=1))
echo $iii
if [ "${SEC[8]}" == 1 ]; then
  echo "FVCOM"
  cd ${BASE}
  tar -xf ${SOURCEFOLDER}/fvcom-4.1_simple.tar.gz
  cd FVCOM_SIMPLE/FVCOM_source
  cp make.inc_example make.inc
  sed -i 's/DEF_FLAGS     = -P -traditional/DEF_FLAGS     = -Wcomment -P -traditional/g' make.inc
  sed -i -e 's*           TOPDIR        = *           TOPDIR        ='"${BASE}"'/FVCOM_SIMPLE/FVCOM_source*g' make.inc
  sed -i 's*             LIBDIR       =  -L$(subst $(colon),$(dashL),$(LIBPATH))*#             LIBDIR       =  -L$(subst $(colon),$(dashL),$(LIBPATH))*g' make.inc
  sed -i 's*             INCDIR       =  -I$(subst $(colon),$(dashI),$(INCLUDEPATH))*#             INCDIR       =  -I$(subst $(colon),$(dashI),$(INCLUDEPATH))*g' make.inc
  sed -i 's*-ljulian* -L'"${BASE}"'/FVCOM_SIMPLE/FVCOM_source/libs/install/lib  -ljulian*g' make.inc
  sed -i 's| DTINCS | DTINCS      = -I'"${BASE}"'/FVCOM_SIMPLE/FVCOM_source/libs/install/include   #|g' make.inc
  sed -i 's*             IOLIBS       =  -lnetcdff -lnetcdf #-lhdf5_hl -lhdf5 -lz -lcurl -lm*             IOLIBS       = -L/home/dbrieva/00_LIBS/00_LIBS/004_netcdf/lib  -lnetcdff -lnetcdf   -L/home/dbrieva/00_LIBS/00_LIBS/003_hdf5/lib -lhdf5 -lhdf5_hl *g' make.inc
  sed -i 's*             IOINCS       =  '"#"'-I/hosts/mao/usr/medm/install/netcdf/3.6.3/em64t/include*             IOINCS       = -I/home/dbrieva/00_LIBS/00_LIBS/004_netcdf/include  -I'"${BASE}"'/FVCOM_SIMPLE/FVCOM_source/libs/install/include  *g' make.inc

  sed -i 's*             PARLIB = -lmetis  #-L/usr/local/lib -lmetis*             PARLIB = -L'"${BASE}"'/FVCOM_SIMPLE/METIS_source/ -lmetis*g' make.inc

  # does not work sed -i -ne '/#  Intel Compiler Definitions/{p; r "  "'  -e  ':a;  n; /#  gfortran defs/ {p; b}; ba}; p' make.inc
  #sed '/MPI Compiler/,/VISITLIBPATH/d' make.inc


  # DESCOMENTAR LAS LINEAS CORRESPONDIENTES
  sed -i 's*         COMPILER = -DIFORT*         COMPILER = -DGFORTARN*g'  make.inc
  #sed -i 's*         CC       = mpicc*         CC       = '"$MPI_FOLDER"'/bin/mpicc *g' make.inc
  #sed -i 's*         CXX      = mpicxx*         CXX      = '"$MPI_FOLDER"'/bin/mpicxx *g' make.inc
  #sed -i 's*         CFLAGS   = -O3**g' make.inc
  #sed -i 's*         FC       = mpif90*         FC       = '"$MPI_FOLDER"'/bin/mpif90 *g' make.inc
  #sed -i 's*         OPT      = -O3**g' make.inc

  #sed -i 's***g' make.inc
  
  ###################################################
  ####      COMPILE FJULIAN   
  echo COMPILING fjulian ----------------------------------------------------------------------------------------------------------------------
  pwd
  cd ${BASE}/FVCOM_SIMPLE/FVCOM_source/libs
  pwd
  tar -xzf julian.tgz 
  cd julian
  echo DONE
  mkdir -p ../install/{lib,include,bin}
  make
  make install
  echo "DONE FJULIA  <<<<<<<<<<<<<<<<<<<< "
  
  #################################################
  ###  COMPILE METIS
  echo ############## METIS -----------------------------------------------------------------------------------------------------
  cd ${BASE}/FVCOM_SIMPLE/METIS_source
  sed -i 's*CC = icc*CC = mpicc *g' makefile
  sed -i 's|__log2|__log2_function|g' rename.h
  make
  echo "DONE METIS  <<<<<<<<<<<<<<<<<<<< "
  
  #################################################
  ###  COMPILE FVCOM
  echo 
  echo   COMPILE FVCOM  --------------------------------------------------------------------------------
  echo
  cd ${BASE}/FVCOM_SIMPLE/FVCOM_source

  pwd
  #grep size mod_newinp.f90
  sed -i 's|<size>| |g' mod_newinp.F
  sed -i 's|BACKWARD_ADVECTION/=.TRUE.|BACKWARD_ADVECTION.neqv..TRUE.|g' mod_scal.F

  sed -i 's|THE NUMBER OF NESTING NODE FILES MUST EQUAL TO THE NUMBER OF NESTING CELL FILES|THE NUMBER OF NESTING NODE \& \n FILES MUST EQUAL TO THE NUMBER OF NESTING CELL FILES|g' mod_esmf_nesting.F

  sed -i 's|BACKWARD_ADVECTION==.TRUE.|BACKWARD_ADVECTION.eqv..TRUE.|g' internal_step.F


  sed -i 's|/(DZ(I,K)+DZ(I,K+1))|/\& \n                   (DZ(I,K)+DZ(I,K+1))|g' adv_t.F
  sed -i 's|/(DZ(I,K)+DZ(I,K-1))|/\& \n                   (DZ(I,K)+DZ(I,K-1))|g' adv_t.F

  sed -i 's|/(DZ(I,K)+DZ(I,K+1))|/\& \n                   (DZ(I,K)+DZ(I,K+1))|g' adv_s.F
  sed -i 's|/(DZ(I,K)+DZ(I,K-1))|/\& \n                   (DZ(I,K)+DZ(I,K-1))|g' adv_s.F

  sed -i 's|BACKWARD_ADVECTION==.FALSE.|BACKWARD_ADVECTION.eqv..FALSE.|g' adv_s.F

  sed -i 's|BACKWARD_ADVECTION==.FALSE.|BACKWARD_ADVECTION.eqv..FALSE.|g' adv_t.F

  #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NETCDF_FOLDER/lib:$MPI_FOLDER/lib:$HDF5_FOLDER/lib
  module load mpi/2021.9.0
  make 

  mv ${BASE}/FVCOM_SIMPLE/FVCOM_source/fvcom ${BASE}/FVCOM_SIMPLE/fvcom$(date +"%Y%m%d%H%M")
  $(date +"%Y%m%d%H%M%S")
  
fi













