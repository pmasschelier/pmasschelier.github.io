+++
title = 'Distributed Matrix Multiplication using starpu runtime'
date = 2024-02-19T15:49:10+01:00
draft = true
tags = ['starpu', 'C', 'HPC']
image='/posts/gemm.svg'
toc = true
featured = true
+++

# What is our goal ?


The goal of this article is to run general matrix multiplication:

$$\alpha op(B)\times op(B)+\beta C$$

where op can be the either identity or the transposition.

We'll perform this operation on an heterogeneous system to see what optimization we can get by leveraging the starpu C runtime.

To do so we'll decompose our computation in asynchronous tasks which operates over matrix tiles.

# What is starpu ?

According to [the starpu documentation](https://files.inria.fr/starpu/doc/starpu.pdf) that we will refer from now on:
> StarPU is a software tool designed to enable programmers to harness the computational capabilities of both CPUs and GPUs, all while sparing them the need to meticulously adapt their programs for specific target machines and processing units.

Shorly, starpu is a C runtime which allows to schedule tasks on heterogeneous computing units.

There are numerous frameworks to do HPC (High Performance Computing) on heterogeneous systems let's review some of them and see how they compare to starpu.

Some of the rely on OpenMP and MPI libraries which are both available for C, C++ and Fortran and many architectures.
- OpenMPI is the implementation of the standardized and portable Message Passing Interface (MPI) standard. This standard defines how to pass messages between different nodes (computers) on a parallel computing architechture.
- OpenMP (Open Multi-Processing) is an API for shared-memory multiprocessing.

As such, an HPC application could use both on a computer cluster, leveraging OpenMP for parallel processing within a core and MPI for inter-node parallelism.

Some of these libraries also support CUDA and OpenCL for GPU-accelerated computing.

[Learn more here](https://www-hpc.cea.fr/tgcc-public/en/html/toc/fulldoc/Parallel_programming.html) about using MPI, OpenMP and CUDA to achieve parallelism.

| Name		| Language 	| github stars 	| contributors 	| std interface 	| Scheduling	| OpenMP 	| MPI | CUDA | OpenCL |
| ---		| --- 		| --- 			| ---			| ---				| ---			| --- 		| --- |	---  | --- 	  |
| [StarPU](https://starpu.gitlabpages.inria.fr/) 				| C 	| 48 	| 33 	| no 	| yes 	| yes 	| yes | yes | yes |
| [Charm++](https://charmplusplus.org/) 						| C++ 	| 185	| 84 	| no 	| yes 	| yes 	| yes | no 	| no  |
| [PaRSEC](https://github.com/ICLDisco/parsec) 					| C 	| 40 	| 27 	| no 	| yes 	| no 	| yes | yes | no  |
| [Legion](https://legion.stanford.edu/overview/) 				| C++ 	| --- 	| --- 	| no 	| no 	| no 	| no  | yes | no  |
| [HPX](https://hpx.stellar-group.org/) 						| C++ 	| 2.3k 	| 148 	| yes 	| yes 	| no 	| no  | --- | --- |
| [STAPL](https://parasollab.web.illinois.edu/research/stapl/) 	| C++ 	| --- 	| --- 	| yes 	| yes 	| yes 	| yes | --- | --- |


# Let's get started with starpu

## Compiling and installing starpu with fxt

Ensure you have hwloc, OpenBLAS and CUDA installed before building starpu.
We'll download and compile starpu with fxt support to get offline profiling facilities.

```sh
export SRC_DIR=you_src_directory
export INSTALL_DIR=your_install_directory

cd $SRC_DIR;
wget http://download.savannah.nongnu.org/releases/fkt/fxt-0.3.14.tar.gz
tar xf fxt-0.3.14.tar.gz;
mkdir -p fxt-0.3.14/build;
cd fxt-0.3.14/build;
../configure --prefix=$INSTALL_DIR/fxt;
make -j;
make install -j;

cd $SRC_DIR;
git clone --recurse-submodules https://gitlab.inria.fr/starpu/starpu.git;
cd starpu;
git fetch --all --tags --prune;
git checkout tags/starpu-1.4.1;
./autogen.sh;
mkdir build;
cd build;
../configure --prefix=$INSTALL_DIR/starpu-fxt --disable-opencl --disable-build-doc --disable-build-examples --disable-build-test --with-fxt=$INSTALL_DIR/fxt;
make -j;
make install -j;
```

## Our CMakeLists.txt

