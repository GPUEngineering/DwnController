/*
 * cudaKernalHeader.cuh
 *
 *  Created on: Mar 14, 2017
 *      Author: Ajay Kumar Samparthirao
 */

/*TODO Rename cudaKernalHeader into DWNCudaKernels */
/* IT IS 'KERNEL', NOT 'KERNAL' */
/*TODO Add documentation */

#ifndef CUDAKERNALHEADER_CUH_
#define CUDAKERNALHEADER_CUH_

/**
 *
 * @param matF
 * @param matG
 * @param dualDiagPrcnd
 * @param scaleVec
 * @param nx
 * @param nu
 */
__global__ void preconditionSystem(
		real_t *matF,
		real_t *matG,
		real_t *dualDiagPrcnd,
		real_t *scaleVec,
		uint_t nx,
		uint_t nu);

/**
 *
 * @param devDeltaUhat
 * @param devUhat
 * @param prevUhat
 * @param devTreeAncestor
 * @param nu
 * @param nodes
 */
__global__ void calculateDiffUhat(
		real_t *devDeltaUhat,
		real_t *devUhat,
		real_t *prevUhat,
		uint_t *devTreeAncestor,
		uint_t nu,
		uint_t nodes);

/**
 *
 * @param devZeta
 * @param devDeltaUhat
 * @param devTreeProb
 * @param devNumChildCuml
 * @param nu
 * @param numNonleafNodes
 * @param nodes
 */
__global__ void calculateZeta(
			real_t *devZeta,
			real_t *devDeltaUhat,
			real_t *devTreeProb,
			uint_t *devNumChildCuml,
			uint_t nu,
			uint_t numNonleafNodes,
			uint_t nodes);


/**
 *
 * @param src
 * @param dst
 * @param devTreeAncestor
 * @param iStageCumulNodes
 * @param dim
 */
__global__ void solveChildNodesUpdate(
			real_t *src,
			real_t *dst,
			uint_t *devTreeAncestor,
			uint_t iStageCumulNodes,
			uint_t dim);

/**
 *
 * @param src
 * @param dst
 * @param devTreeNumChildren
 * @param devTreeNumChildCumul
 * @param iStageCumulNodes
 * @param iStageNodes
 * @param iStage
 * @param dim
 */
__global__  void solveSumChildren(
			real_t *src,
			real_t *dst,
			uint_t *devTreeNumChildren,
			uint_t *devTreeNumChildCumul,
		  uint_t iStageCumulNodes,
			uint_t iStageNodes,
			uint_t iStage,
			uint_t dim);
/**
 *
 * @param vecDualW
 * @param vecPrevDual
 * @param vecCurrentDual
 * @param alpha
 * @param size
 */
/*TODO kernal ---> kernel */
/*TODO int size --> uint_t size */
__global__ void kernalDualExtrapolationStep(
			real_t *vecDualW,
			real_t *vecPrevDual,
			real_t *vecCurrentDual,
			real_t alpha,
			int size);



/**
 *
 * @param vecX
 * @param lowerbound
 * @param upperbound
 * @param dim
 * @param offset
 * @param size
 */
/*TODO int dim --> uint_t dim */
/*TODO int offset --> uint_t offset */
/*TODO int size --> uint_t size */
__global__ void projectionBox(
			real_t *vecX,
			real_t *lowerbound,
			real_t *upperbound,
			int dim,
			int offset,
			int size);


/**
 *
 * @param dst
 * @param src
 * @param dimVec
 * @param numVec
 * @param numBlocks
 */
/*TODO int dimVec --> uint_t dimVec */
/*TODO int numVec --> uint_t numVec */
/*TODO int numBlocks --> uint_t numBlocks */
__global__ void shuffleVector(
				real_t *dst,
				real_t *src,
				int dimVec,
				int numVec,
				int numBlocks);
/**
 *
 * @param dst
 * @param src
 * @param scale
 * @param dim
 * @param offset
 * @param size
 */
 /*TODO int dim --> uint_t dim */
 /*TODO int offset --> uint_t offset */
 /*TODO int size --> uint_t size */
__global__ void additionVectorOffset(
			real_t *dst,
			real_t *src,
			real_t scale,
			int dim,
			int offset,
			int size);

/**
 *
 * @param vecDualY
 * @param vecDualW
 * @param vecHX
 * @param vecZ
 * @param stepSize
 * @param size
 */
/*TODO kernal --> kernel */
/*TODO int dim --> uint_t dim */
/*TODO int stepSize --> uint_t stepSize */
/*TODO int size --> uint_t size */
__global__ void kernalDualUpdate(
			real_t *vecDualY,
			real_t *vecDualW,
			real_t *vecHX,
			real_t *vecZ,
			float stepSize,
			int size);

/*TODO remove this test - there shouldn't be any tests here */
__global__ void testGPUAdd(
			real_t *matF,
			real_t *matG,
			uint_t k);

/**
 *
 * @param vecU
 * @param lowerbound
 * @param upperbound
 * @param size
 */
 /*TODO int size --> uint_t size */
__global__ void projectionControl(
			real_t *vecU,
			real_t *lowerbound,
			real_t *upperbound,
			int size);




/*__global__ void preconditionSystem(real_t *matF, real_t *matG, real_t *dualDiagPrcnd, real_t *scaleVec,
		uint_t nx, uint_t nu);
__global__ void calculateDiffUhat(real_t *devDeltaUhat, real_t *devUhat, real_t *prevUhat, uint_t *devTreeAncestor,
		uint_t nu, uint_t nodes);
__global__ void calculateZeta(real_t *devZeta, real_t *devDeltaUhat, real_t *devTreeProb, uint_t *devNumChildCuml,
		uint_t nu, uint_t numNonleafNodes, uint_t nodes);
__global__  void solveSumChildren(real_t *src, real_t *dst, uint_t *devTreeNumChildren, uint_t *devTreeNumChildCumul,
		  uint_t iStageCumulNodes, uint_t iStageNodes, uint_t iStage, uint_t dim);
__global__ void solveChildNodesUpdate(real_t *src, real_t *dst, uint_t *devTreeAncestor,uint_t nextStageCumulNodes, uint_t dim);
__global__ void testGPUAdd(real_t *matF, real_t *matG, uint_t k);*/
#endif /* CUDAKERNALHEADER_CUH_ */