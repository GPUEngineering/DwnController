/*
 *    GPU-accelerated scenario-based stochastic MPC for the operational
 *    management of drinking water networks.
 *    Copyright (C) 2017 Ajay. K. Sampathirao and P. Sopasakis
 *
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Lesser General Public
 *    License as published by the Free Software Foundation; either
 *    version 2.1 of the License, or (at your option) any later version.
 *
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public
 *    License along with this library; if not, write to the Free Software
 *    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */

#ifndef SMPCONTROLLERCLASS_CUH_
#define SMPCONTROLLERCLASS_CUH_

#include "Configuration.h"
#include "Engine.cuh"
//#include "cudaKernelHeader.cuh"

/**
 * GPU-based stochastic model predictive controller for management of the
 * drinking water water network. This method is used dual proximal gradient method
 * to solve the optimisation problem resulted from the stochastic mpc
 * controller. This algorithm is completely parallelisable takes full advantage of
 * parallel computational capability of the GPU devices.
 *
 * The object initiates the controller object. This contains
 *   - The forecaster object to predict the nominal water demand and nominal prices
 *   - The Engine object generates matrices that are used in the actual algorithm
 *   - The SmpcConfiguration object that have all the user defined parameters of the
 *     algorithm
 *
 */
class SmpcController {
public:
	/**
	 * Construct a new Controller with a given engine.
	 * @param  myForecaster   An instance of the Forecaster object
	 * @param  myEngine       An instance of Engine object
	 * @param  mySmpcConfig   An instance of the Smpc controller configuration object
	 */
	SmpcController( Forecaster *myForecaster,
			Engine *myEngine,
			SmpcConfiguration *mySmpcConfig );
	/**
	 * Construct a new Controller with a given engine.
	 * @param  pathToConfigFile   path to the controller configuration file
	 */
	SmpcController( string pathToConfigFile );

	/**
	 * Performs the initialise the smpc controller
	 *   - update the current state and previous controls in the device memory
	 *   - perform the factor step
	 */
	void initialiseSmpcController();

	/**
	 * Invoke the SMPC controller on the current state of the network.
	 * This method invokes #updateStateControl, eliminateInputDistubanceCoupling
	 * and finally #algorithmApg.
	 */
	void controllerSmpc();

	/**
	 * Computes a control action and returns a status code
	 * which is an integer (1 = success).
	 * @param  u      pointer to computed control action (CPU variable)
	 * @return status code
	 */
	uint_t controlAction(real_t* u);

	/**
	 * Compute the control action, stores in the json file
	 * provided to it and returns a status code (1 = success).
	 * @param   controlJson   file pointer to the output json file
	 * @return  status        code
	 */
	uint_t controlAction(fstream& controlOutputJson);
	/**
	 * Get's the network object
	 * @return  DwnNetwork
	 */
	DwnNetwork* getDwnNetwork();
	/**
	 * Get's the scenario tree object
	 * @return scenarioTree
	 */
	ScenarioTree* getScenarioTree();
	/**
	 * Get's the Smpc controller configuration object
	 * @return SmpcConfiguration
	 */
	SmpcConfiguration* getSmpcConfiguration();
	/**
	 * Get's the Forecaster object
	 * @return Forecaster
	 */
	Forecaster* getForecaster();
	/**
	 * Get's the Engine object
	 * @return Engine
	 */
	Engine* getEngine();
	/*
	 * During the closed-loop of the controller,
	 * the controller moves to the next time instance. It checks
	 * for the flag SIMULATOR_FLAG, 1 corresponds to an in-build
	 * simulator call given by `updateSmpcConfiguration()` and
	 * 0 corresponds to external simulator.
	 *
	 * Reads the smpcControlConfiguration file for currentState,
	 * previousDemand and previousControl action.
	 */
	void moveForewardInTime();
	/*
	 * Get the economical KPI upto the simulation horizon
	 * @param    simualtionTime  simulation horizon
	 */
	real_t getEconomicKpi( uint_t simulationTime);
	/*
	 * Get the smooth KPI upto the simulation horizon
	 * @param    simulationTime   simulation horizon
	 */
	real_t getSmoothKpi( uint_t simulationTime);
	/*
	 * Get the  network KPI upto the simulation horizon
	 * @param   simulationTime    simulation horizon
	 */
	real_t getNetworkKpi( uint_t simulationTime);
	/*
	 * Get the safety KPI upto the simulation horizon
	 * @param   simulationTime    simulation horizon
	 */
	real_t getSafetyKpi( uint_t simulationTime);
	/**
	 * update the KPI at the current time instance
	 */
	void updateKpi(real_t* state,
			real_t* control);
	/**
	 * Get the value of the FBE during the iteration
	 */
	real_t* getValueFbe();
	/**
	 * Destructor. Frees allocated memory.
	 */
	~SmpcController();
protected:
	/**
	 * Performs the dual extrapolation step with given parameter.
	 * @param extrapolation parameter.
	 */
	void dualExtrapolationStep(real_t lambda);
	/**
	 * Computes the dual gradient.This is the main computational
	 * algorithm for the proximal gradient algorithm
	 */
	void solveStep();
	/**
	 * Copy the dual vector pointers to compute the solve step.
	 */
	void initialiseAlgorithmSpecificData();
	/**
	 * Computes the proximal operator of g at the current point and updates
	 * (primal psi, primal xi) - Hx, (dual psi, dual xi) - z.
	 */
	void proximalFunG();
	/**
	 * Performs the update of the dual vector.
	 */
	void dualUpdate();
	/**
	 * This method executes the APG algorithm and returns the primal infeasibility.
	 * @return primalInfeasibilty;
	 */
	uint_t algorithmApg();
	/**
	 * When the SIMULATOR FLAG is set to 1, the previousControl,
	 * currentState and previousDemand vectors in the smpc controller
	 * configuration file are set.
	 * @param    updateState   update the currentX in the controller
	 *                         configuration json
	 * @param    control       update the prevU in the controller
	 *                         configuration json
	 * @param    demand        update the prevDemand in the controller
	 *                         configuration json
	 */
	void updateSmpcConfiguration(real_t* updateState,
			real_t* control,
			real_t* demand);
	/**
	 * calculate the residual Hx - t
	 */
	void computeFixedPointResidual();
	/**
	 * compute the hessian-oracle
	 */
	void computeHessianOracalGlobalFbe();
	/**
	 * compute the gradient of the Fbe
	 */
	void computeGradientFbe();
	/**
	 * calculate the lbfgs direction
	 */
	void computeLbfgsDirection();
	/**
	 * two-loop recursion in the L-BFGS algorithm
	 */
	void twoLoopRecursionLbfgs();
	/**
	 * update the LBFGS buffer for calculating the two-loop recursion
	 * this update depend on the algorithm used
	 *  globalFBE - use the gradient of FBE
	 *  NAMA - use the fixed-point residual
	 */
	void updateLbfgsBuffer();
	/**
	 * compute the line search update of the tau
	 * @param   valueFbeYvar    the value of the fbe at the current dual variable Y
	 *
	 * @param   real_t          step-size in the direction of the lbfgs direction
	 */
	real_t computeLineSearchLbfgsUpdate(real_t valueFbeYvar);
	/*
	 * compute the line search update of the tau for the AME
	 * @param  valueAmeYvar     the value of the AME at the current dual variable Y
	 *
	 * @param  real_t           step-size of the lbfgs direction and fixed point residual
	 */
	real_t computeLineSearchAmeLbfgsUpdate(real_t valueAmeYvar);
	/**
	 * This method executes the APG algorithm and returns the primal infeasibility.
	 * @return primalInfeasibilty;
	 */
	uint_t algorithmGlobalFbe();
	/**
	 * This method executes the NAMA algorithm and returns the primal infeasibility
	 * @return primalInfeasibility
	 */
	uint_t algorithmNama();
	/**
	 * calculate the value of FBE algorithm and returns the primal infeasibility
	 * @return primalInfeasibility
	 */
	real_t computeValueFbe();
	/**
	 * calculate primal infeasibility (Hx - Z) at each iteration
	 */
	real_t updatePrimalInfeasibity();
//private:
	/**
	 * allocate memory of the smpc algorithm
	 */
	void allocateSmpcController();
	/*
	 * Allocate memory for the LBFGS-buffer in the device
	 */
	void allocateLbfgsBuffer();
	/*
	 * Allocate memory for the LBFGS-buffer in the device
	 */
	void allocateLbfgsDirection();
	/**
	 * Allocate memory for APG algorithm
	 */
	void allocateApgAlgorithm();
	/**
	* Allocate memory for globalFbe
	*/
	void allocateGlobalFbeAlgorithm();
	/**
	 * Allocate memory for globalFbe
	 */
	void allocateNamaAlgorithm();
	/**
	 * intialise the lbfgs-buffer at he beginning of the algorithm
	 */
	void initaliseLbfgBuffer();
	/**
	 * intialise the dual vectors in the optimisation algorithm
	 */
	void initialiseAlgorithm();
	/*
	 * update the current and the previous fixed-point residual
	 * for NAMA algorithm
	 */
	void updateFixedPointResidualNamaAlgorithm();
	/*
	 * deallocate the memory of the APG in the device
	 */
	void deallocateApgAlgorithm();
	/*
	 * deallocate the memory of the gloablFbe in the device
	 */
	void deallocateGlobalFbeAlgorithm();
	/*
	 * deallocate the memory of the NAMA in the device
	 */
	void deallocateNamaAlgorithm();
	/*
	 * Allocate memory for the LBFGS-buffer in the device
	 */
	void deallocateLbfgsDirection();
	/*
	 * deallocate the memory of the controller in the device
	 */
	void deallocateSmpcController();
	/**
	 * Pointer to an Engine object.
	 * The Engine is responsible for the factor step.
	 */
	Engine* ptrMyEngine;
	/**
	 * Pointer to the Forecaster object
	 * This contains the forecast of the demand and prices
	 */
	Forecaster* ptrMyForecaster;
	/**
	 * Pointer to the Smpc configuration object
	 * This contains the configurations for the controller
	 */
	SmpcConfiguration* ptrMySmpcConfig;
	/**
	 * Pointer to device state
	 */
	real_t *devVecX;
	/**
	 * Pointer to device control
	 */
	real_t *devVecU;
	/**
	 * Pointer to device reduced control
	 */
	real_t *devVecV;
	/**
	 * Pointer to device Xi
	 */
	real_t *devVecXi;
	/**
	 * Pointer to device Psi
	 */
	real_t *devVecPsi;
	/**
	 * Pointer to device accelerated Xi
	 */
	real_t *devVecAcceleratedXi;
	/**
	 * Pointer to device accelerated Psi
	 */
	real_t *devVecAcceleratedPsi;
	/**
	 * Pointer to device primal Xi
	 */
	real_t *devVecPrimalXi;
	/**
	 * Pointer to device primal Psi
	 */
	real_t *devVecPrimalPsi;
	/**
	 * Pointer to device dual Xi
	 */
	real_t *devVecDualXi;
	/**
	 * Pointer to device dual Psi
	 */
	real_t *devVecDualPsi;
	/**
	 * Pointer to device updated xi
	 */
	real_t *devVecUpdateXi;
	/**
	 * Pointer to device update psi
	 */
	real_t *devVecUpdatePsi;
	/**
	 * Pointer array for device pointers of state
	 */
	real_t **devPtrVecX;
	/**
	 * Pointer array for device pointers of control
	 */
	real_t **devPtrVecU;
	/**
	 * Pointer array for device pointers of reduced
	 * decision variable
	 */
	real_t **devPtrVecV;
	/**
	 * Pointer array for the vector required for solve step Xi
	 */
	real_t **devPtrVecSolveStepXi;
	/**
	 * Pointer array for the vector required for solve step Psi
	 */
	real_t **devPtrVecSolveStepPsi;
	/**
	 * Pointer array for device pointers of primal psi
	 */
	real_t **devPtrVecPrimalPsi;
	/**
	 * Pointer array for device pointer of primal xi
	 */
	real_t **devPtrVecPrimalXi;
	/**
	 * Pointer array for the residual
	 */
	real_t *devVecResidual;
	/**
	 * Pointer for fixed-point residual xi
	 */
	real_t *devVecFixedPointResidualXi;
	/**
	 * Pointer for fixed-point residual xi
	 */
	real_t *devVecFixedPointResidualPsi;
	/**
	 * Pointer array for the vector required for solve step Xi
	 */
	real_t** ptrProximalXi;
	/**
	 * Pointer array for the vector required for solve step Xi
	 */
	real_t** ptrProximalPsi;
	/**
	 * Pointer for Q in solve step
	 */
	real_t *devVecQ;
	/**
	 * Pointer for R in solve step
	 */
	real_t *devVecR;
	/**
	 * Pointer array for device pointers of Q in solve step
	 */
	real_t **devPtrVecQ;
	/**
	 * Pointer array for device pointers of R in solve step
	 */
	real_t **devPtrVecR;
	/*
	 * Final control output calculated after a projection on the
	 * feasible set to ensure feasibility
	 */
	real_t *devControlAction;
	/**
	 * Updated state for the simulator
	 */
	real_t *devStateUpdate;
	/**
	 * Step size
	 */
	real_t stepSize;

	/* ----- globalFbe Algorithm ----*/
	/*
	 * pointer to the FBE gradient xi in the device
	 */
	real_t *devVecGradientFbeXi;
	/*
	 * pointer to the FBE gradient psi in the device
	 */
	real_t *devVecGradientFbePsi;
	/*
	 * pointer to the previous FBE gradient xi in the device
	 */
	real_t *devVecPrevGradientFbeXi;
	/*
	 * pointer to the previous FBE gradient psi in the device
	 */
	real_t *devVecPrevGradientFbePsi;
	/*
	 * pointer array to the device pointer of gradient of FBE xi
	 */
	real_t **devPtrVecGradFbeXi;
	/*
	 * pointer array to the device pointer of gradient of FBE psi
	 */
	real_t **devPtrVecGradFbePsi;

	/* ----- NAMA Algorithm ----*/
	/*
	 * pointer to the previous fixed point residual
	 */
	real_t *devVecPrevFixedPointResidualXi;
	/*
	 * pointer to the previous fixed point residual
	 */
	real_t *devVecPrevFixedPointResidualPsi;
	/*
	 * pointer array to the previous fixed point residual
	 */
	real_t *devVecCurrentFixedPointResidualXi;
	/*
	 * pointer to the previous fixed point residual
	 */
	real_t *devVecCurrentFixedPointResidualPsi;

	/* ----- quasi-newton direction ----- */
	/**
	 * Pointer array for the vector required for solve step Xi
	 */
	real_t **devPtrVecHessianOracleXi;
	/**
	 * Pointer array for the vector required for solve step Psi
	 */
	real_t **devPtrVecHessianOraclePsi;

	/*
	 * Hessian-direction in variable X
	 */
	real_t *devVecXdir;
	/*
	 * Hessian-direction in variable U
	 */
	real_t *devVecUdir;
	/**
	 * Pointer to device Hessian primal Xi
	 */
	real_t *devVecPrimalXiDir;
	/**
	 * Pointer to device Hessian primal Psi
	 */
	real_t *devVecPrimalPsiDir;
	/*
	 * pointer to lbfgs previous xi
	 */
	real_t *devVecPrevXi;
	/*
	 * pointer to lbfgs previous psi
	 */
	real_t *devVecPrevPsi;
	/*
	 * pointer to the direction from the LBFGS xi in the device
	 */
	real_t *devVecLbfgsDirXi;
	/*
	 * pointer to the direction from the LBFGS psi in the device
	 */
	real_t *devVecLbfgsDirPsi;
	/*
	 * Hessian oracle with respect to fixed point residual x
	 */
	real_t *devVecFixedPointXdir;
	/*
	 * Hessian oracle with respect to fixed point residual x
	 */
	real_t *devVecFixedPointUdir;
	/*
	 * Hessian oracle with respect to fixed point residual x
	 */
	real_t *devVecFixedPointPrimalXiDir;
	/*
	 * Hessian oracle with respect to fixed point residual x
	 */
	real_t *devVecFixedPointPrimalPsiDir;
	/*
	 * pointer array to the device pointer of Hessian-direction in X
	 */
	real_t **devPtrVecXdir;
	/*
	 * pointer array to the device pointer of Hessian-direction in U
	 */
	real_t **devPtrVecUdir;
	/**
	 * pointer array to device pointer Hessian primal Xi
	 */
	real_t **devPtrVecPrimalXiDir;
	/**
	 * pointer to device primal Psi
	 */
	real_t **devPtrVecPrimalPsiDir;

	/* --- LBFGS buffer --- */
	/**
	 * pointer to the current xi in y vector of the lbfgs algorithm
	 */
	real_t **ptrLbfgsCurrentYvecXi;
	/**
	 * pointer to the current psi in y vector of the lbfgs algorithm
	 */
	real_t **ptrLbfgsCurrentYvecPsi;
	/**
	 * pointer to the previous xi in y vector of the lbfgs algorithm
	 */
	real_t **ptrLbfgsPreviousYvecXi;
	/**
	 * pointer to the previous xi in y vector of the lbfgs algorithm
	 */
	real_t **ptrLbfgsPreviousYvecPsi;
	/*
	 * matrix s in the lfbs-buffer s = x_{k} - x_{k - 1}
	 */
	real_t *devLbfgsBufferMatS;
	/*
	 * matrix y in the lbfgs-buffer y = \delta F_{k} - \delta F_{k - 1}
	 */
	real_t *devLbfgsBufferMatY;
	/*
	 * vector rho in the lbfgs-buffer rho_k = 1/(y_k*s_k)
	 */
	real_t *lbfgsBufferRho;
	/*
	 * current col of the lbfgs buffer
	 */
	uint_t lbfgsBufferCol;
	/*
	 * memory of the lbfgs buffer
	 */
	uint_t lbfgsBufferMemory;
	/*
	 * skip count of the lbfgs buffer
	 */
	uint_t lbfgsSkipCount;
	/*
	 * inverse Hessian with the lbfgs
	 */
	real_t lbfgsBufferHessian;
	/*
	 * value of the proximal function of g with state box
	 */
	real_t valueFunGxBox;
	/*
	 * value of the proximal function of g with state safe volume
	 */
	real_t valueFunGxSafe;
	/*
	 * value of the proximal function of g with control box
	 */
	real_t valueFunGuBox;

	/**
	 * Flag Factor step
	 */
	bool factorStepFlag;
	/*
	 * Flag for the simulator flag (default is set to 1 or true);
	 */
	bool simulatorFlag;
	/*
	 * primal Infeasibilty
	 */
	real_t *vecPrimalInfs;
	/*
	 * KPI to measure the economical cost
	 */
	real_t economicKpi;
	/*
	 * KPI to measure the smooth operation of the controller
	 */
	real_t smoothKpi;
	/*
	 * KPI to measure the safe operation of the controller
	 */
	real_t safeKpi;
	/*
	 * KPI to measure the network utility of the system
	 */
	real_t networkKpi;
	/*
	 * value of the fbe
	 */
	real_t* vecValueFbe;
	/*
	 * tau in the line search
	 */
	real_t* vecTau;
};

#endif /* SMPCONTROLLERCLASS_CUH_ */
