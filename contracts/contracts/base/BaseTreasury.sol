// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title BaseTreasury
 * @notice Abstract DAO treasury for holding and streaming funds.
 *
 * Verticals construct this with their canonical engine token (`vgrdToken`),
 * which is the default token for streams that omit an explicit token address.
 * Streams with an explicit `token` parameter still work for arbitrary ERC20s.
 */
abstract contract BaseTreasury is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    IERC20 public immutable vgrdToken;

    struct Stream {
        address recipient;
        address token;
        uint256 totalAmount;
        uint256 claimedAmount;
        uint256 startTime;
        uint256 endTime;
        bool active;
    }

    mapping(uint256 => Stream) public streams;
    uint256 public nextStreamId = 1;

    event Withdrawn(address indexed token, address indexed to, uint256 amount);
    event ETHWithdrawn(address indexed to, uint256 amount);
    event StreamCreated(uint256 indexed streamId, address recipient, address token, uint256 amount, uint256 duration);
    event StreamClaimed(uint256 indexed streamId, uint256 amount);
    event StreamCancelled(uint256 indexed streamId, uint256 refundAmount);

    constructor(address admin, address _vgrdToken) {
        require(admin != address(0), "admin zero");
        require(_vgrdToken != address(0), "token zero");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(DAO_ROLE, admin);
        vgrdToken = IERC20(_vgrdToken);
    }

    // ─── Withdrawals ─────────────────────────────────────────────────────
    function withdraw(address token, address to, uint256 amount) external onlyRole(DAO_ROLE) nonReentrant {
        require(to != address(0), "Invalid recipient");
        require(IERC20(token).transfer(to, amount), "Transfer failed");
        emit Withdrawn(token, to, amount);
    }

    function withdrawETH(address to, uint256 amount) external onlyRole(DAO_ROLE) nonReentrant {
        require(to != address(0), "Invalid recipient");
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success,) = to.call{value: amount}("");
        require(success, "ETH transfer failed");
        emit ETHWithdrawn(to, amount);
    }

    function getBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getETHBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // ─── Streams ─────────────────────────────────────────────────────────
    function createStream(
        address recipient,
        address token,
        uint256 amount,
        uint256 duration
    ) external onlyRole(DAO_ROLE) nonReentrant returns (uint256) {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be > 0");
        require(duration > 0, "Duration must be > 0");
        address streamToken = token == address(0) ? address(vgrdToken) : token;
        require(IERC20(streamToken).balanceOf(address(this)) >= amount, "Insufficient balance");

        uint256 streamId = nextStreamId++;
        streams[streamId] = Stream({
            recipient: recipient,
            token: streamToken,
            totalAmount: amount,
            claimedAmount: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            active: true
        });

        emit StreamCreated(streamId, recipient, streamToken, amount, duration);
        return streamId;
    }

    function getClaimableAmount(uint256 streamId) public view returns (uint256) {
        Stream storage stream = streams[streamId];
        if (!stream.active) return 0;

        uint256 elapsed;
        if (block.timestamp >= stream.endTime) {
            elapsed = stream.endTime - stream.startTime;
        } else {
            elapsed = block.timestamp - stream.startTime;
        }
        uint256 duration = stream.endTime - stream.startTime;
        uint256 vested = (stream.totalAmount * elapsed) / duration;
        return vested - stream.claimedAmount;
    }

    function claimStream(uint256 streamId) external nonReentrant {
        Stream storage stream = streams[streamId];
        require(stream.active, "Stream not active");
        require(stream.recipient == msg.sender, "Not recipient");

        uint256 claimable = getClaimableAmount(streamId);
        require(claimable > 0, "Nothing to claim");

        stream.claimedAmount += claimable;
        if (stream.claimedAmount >= stream.totalAmount) {
            stream.active = false;
        }

        require(IERC20(stream.token).transfer(msg.sender, claimable), "Transfer failed");
        emit StreamClaimed(streamId, claimable);
    }

    function cancelStream(uint256 streamId) external onlyRole(DAO_ROLE) nonReentrant {
        Stream storage stream = streams[streamId];
        require(stream.active, "Stream not active");

        uint256 claimable = getClaimableAmount(streamId);
        uint256 refund = stream.totalAmount - stream.claimedAmount - claimable;

        stream.active = false;

        if (claimable > 0) {
            require(IERC20(stream.token).transfer(stream.recipient, claimable), "Transfer failed");
        }

        emit StreamCancelled(streamId, refund);
    }

    function getStream(uint256 streamId) external view returns (Stream memory) {
        return streams[streamId];
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    receive() external payable {}
}
