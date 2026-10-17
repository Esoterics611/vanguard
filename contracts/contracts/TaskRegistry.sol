// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./ArmyRegistry.sol";
import "./RankManager.sol";
import "./RewardPool.sol";

/**
 * @title TaskRegistry
 * @dev Manages objectives and tasks within the Vanguard protocol
 */
contract TaskRegistry is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    bytes32 public constant BOUNTY_ESCROW_ROLE = keccak256("BOUNTY_ESCROW_ROLE");

    ArmyRegistry public immutable registry;
    RankManager public immutable rankManager;
    RewardPool public rewardPool;

    enum ObjectiveStatus { ACTIVE, COMPLETED, CANCELLED }
    enum TaskStatus { OPEN, ASSIGNED, SUBMITTED, APPROVED, REJECTED }

    struct Objective {
        uint256 bountyId;
        uint256 unitId;
        bytes32 descriptionHash;
        uint256 allocatedAmount;
        uint256 taskCount;
        uint256 completedTasks;
        ObjectiveStatus status;
        address creator;
    }

    struct Task {
        uint256 objectiveId;
        address assignee;
        bytes32 descriptionHash;
        uint256 rewardAmount;
        uint256 deadline;
        TaskStatus status;
        bytes32 submissionHash;
        address creator;
    }

    // State
    mapping(uint256 => Objective) public objectives;
    mapping(uint256 => Task) public tasks;
    mapping(address => uint256[]) public soldierTasks;

    uint256 public nextObjectiveId = 1;
    uint256 public nextTaskId = 1;

    // Events
    event ObjectiveCreated(uint256 indexed bountyId, uint256 objectiveId, uint256 unitId);
    event TaskCreated(uint256 indexed objectiveId, uint256 taskId);
    event TaskAssigned(uint256 indexed taskId, address indexed soldier);
    event TaskSubmitted(uint256 indexed taskId, bytes32 submissionHash);
    event TaskApproved(uint256 indexed taskId, uint256 reward);
    event TaskRejected(uint256 indexed taskId, bytes32 reason);
    event ObjectiveCompleted(uint256 indexed objectiveId);

    constructor(
        address admin,
        address _registry,
        address _rankManager
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(DAO_ROLE, admin);
        registry = ArmyRegistry(_registry);
        rankManager = RankManager(_rankManager);
    }

    /**
     * @dev Set reward pool (can only be set once)
     */
    function setRewardPool(address _rewardPool) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(rewardPool) == address(0), "Already set");
        rewardPool = RewardPool(_rewardPool);
    }

    /**
     * @dev Create an objective (unit leaders)
     */
    function createObjective(
        uint256 bountyId,
        uint256 unitId,
        bytes32 descriptionHash,
        uint256 allocation
    ) external whenNotPaused returns (uint256) {
        ArmyRegistry.Unit memory unit = registry.getUnit(unitId);
        require(unit.active, "Unit not active");
        require(
            unit.leader == msg.sender ||
            unit.secondInCommand == msg.sender ||
            hasRole(DAO_ROLE, msg.sender) ||
            hasRole(BOUNTY_ESCROW_ROLE, msg.sender),
            "Not authorized"
        );

        uint256 objectiveId = nextObjectiveId++;
        objectives[objectiveId] = Objective({
            bountyId: bountyId,
            unitId: unitId,
            descriptionHash: descriptionHash,
            allocatedAmount: allocation,
            taskCount: 0,
            completedTasks: 0,
            status: ObjectiveStatus.ACTIVE,
            creator: msg.sender
        });

        emit ObjectiveCreated(bountyId, objectiveId, unitId);
        return objectiveId;
    }

    /**
     * @dev Create a task (squad leaders)
     */
    function createTask(
        uint256 objectiveId,
        bytes32 descriptionHash,
        uint256 reward,
        uint256 deadline
    ) external whenNotPaused returns (uint256) {
        Objective storage objective = objectives[objectiveId];
        require(objective.status == ObjectiveStatus.ACTIVE, "Objective not active");

        ArmyRegistry.Unit memory unit = registry.getUnit(objective.unitId);
        require(
            unit.leader == msg.sender ||
            unit.secondInCommand == msg.sender ||
            hasRole(DAO_ROLE, msg.sender),
            "Not authorized"
        );

        uint256 taskId = nextTaskId++;
        tasks[taskId] = Task({
            objectiveId: objectiveId,
            assignee: address(0),
            descriptionHash: descriptionHash,
            rewardAmount: reward,
            deadline: deadline,
            status: TaskStatus.OPEN,
            submissionHash: bytes32(0),
            creator: msg.sender
        });

        objective.taskCount++;

        emit TaskCreated(objectiveId, taskId);
        return taskId;
    }

    /**
     * @dev Assign a task to a soldier
     */
    function assignTask(uint256 taskId, address soldier) external whenNotPaused {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.OPEN, "Task not open");
        require(registry.isEnlisted(soldier), "Soldier not enlisted");

        Objective storage objective = objectives[task.objectiveId];
        ArmyRegistry.Unit memory unit = registry.getUnit(objective.unitId);

        require(
            unit.leader == msg.sender ||
            unit.secondInCommand == msg.sender ||
            hasRole(DAO_ROLE, msg.sender),
            "Not authorized"
        );

        task.assignee = soldier;
        task.status = TaskStatus.ASSIGNED;
        soldierTasks[soldier].push(taskId);

        emit TaskAssigned(taskId, soldier);
    }

    /**
     * @dev Self-assign an open task
     */
    function selfAssignTask(uint256 taskId) external whenNotPaused {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.OPEN, "Task not open");
        require(registry.isEnlisted(msg.sender), "Not enlisted");

        task.assignee = msg.sender;
        task.status = TaskStatus.ASSIGNED;
        soldierTasks[msg.sender].push(taskId);

        emit TaskAssigned(taskId, msg.sender);
    }

    /**
     * @dev Submit completed work for a task
     */
    function submitTask(uint256 taskId, bytes32 submissionHash) external whenNotPaused {
        Task storage task = tasks[taskId];
        require(task.assignee == msg.sender, "Not assignee");
        require(task.status == TaskStatus.ASSIGNED, "Task not assigned");
        require(block.timestamp <= task.deadline || task.deadline == 0, "Deadline passed");

        task.submissionHash = submissionHash;
        task.status = TaskStatus.SUBMITTED;

        emit TaskSubmitted(taskId, submissionHash);
    }

    /**
     * @dev Approve a submitted task
     */
    function approveTask(uint256 taskId) external whenNotPaused nonReentrant {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.SUBMITTED, "Task not submitted");

        Objective storage objective = objectives[task.objectiveId];
        ArmyRegistry.Unit memory unit = registry.getUnit(objective.unitId);

        require(
            unit.leader == msg.sender ||
            unit.secondInCommand == msg.sender ||
            hasRole(DAO_ROLE, msg.sender),
            "Not authorized"
        );

        task.status = TaskStatus.APPROVED;
        objective.completedTasks++;

        // Distribute reward
        if (address(rewardPool) != address(0)) {
            rewardPool.distributeTaskReward(task.assignee, task.rewardAmount, taskId);
        }

        emit TaskApproved(taskId, task.rewardAmount);

        // Check if objective is complete
        if (objective.completedTasks == objective.taskCount) {
            objective.status = ObjectiveStatus.COMPLETED;
            emit ObjectiveCompleted(task.objectiveId);
        }
    }

    /**
     * @dev Reject a submitted task
     */
    function rejectTask(uint256 taskId, bytes32 reason) external whenNotPaused {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.SUBMITTED, "Task not submitted");

        Objective storage objective = objectives[task.objectiveId];
        ArmyRegistry.Unit memory unit = registry.getUnit(objective.unitId);

        require(
            unit.leader == msg.sender ||
            unit.secondInCommand == msg.sender ||
            hasRole(DAO_ROLE, msg.sender),
            "Not authorized"
        );

        task.status = TaskStatus.REJECTED;
        task.submissionHash = bytes32(0); // Clear submission

        emit TaskRejected(taskId, reason);
    }

    /**
     * @dev Resubmit a rejected task
     */
    function resubmitTask(uint256 taskId, bytes32 submissionHash) external whenNotPaused {
        Task storage task = tasks[taskId];
        require(task.assignee == msg.sender, "Not assignee");
        require(task.status == TaskStatus.REJECTED, "Task not rejected");

        task.submissionHash = submissionHash;
        task.status = TaskStatus.SUBMITTED;

        emit TaskSubmitted(taskId, submissionHash);
    }

    /**
     * @dev Get tasks for a soldier
     */
    function getTasksForSoldier(address soldier) external view returns (uint256[] memory) {
        return soldierTasks[soldier];
    }

    /**
     * @dev Get objective progress
     */
    function getObjectiveProgress(uint256 objectiveId) external view returns (uint256 completed, uint256 total) {
        Objective storage objective = objectives[objectiveId];
        return (objective.completedTasks, objective.taskCount);
    }

    /**
     * @dev Get task details
     */
    function getTask(uint256 taskId) external view returns (Task memory) {
        return tasks[taskId];
    }

    /**
     * @dev Get objective details
     */
    function getObjective(uint256 objectiveId) external view returns (Objective memory) {
        return objectives[objectiveId];
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
