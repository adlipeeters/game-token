// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameToken is ERC20, Ownable {
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public stakingTime;

    mapping(uint => mapping(address => bool)) public votes;
    mapping(uint => uint256) public proposals; // Simple proposal with proposal ID -> votes count
    constructor() ERC20("GameToken", "GTK") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Initial mint to the deployer for the ecosystem setup
    }

    // Function to mint new tokens (can be restricted or modified as per game design)
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Function to burn tokens (to control inflation or as a game mechanic)
    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }

    // Stake tokens to earn rewards
    function stake(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient token balance");
        _burn(msg.sender, amount); // Tokens are locked/burned
        stakes[msg.sender] += amount;
        stakingTime[msg.sender] = block.timestamp;
    }

    // Unstake tokens with reward calculation
    function unstake() public {
        require(stakes[msg.sender] > 0, "No tokens staked");
        uint256 stakedAmount = stakes[msg.sender];
        uint256 stakingDuration = block.timestamp - stakingTime[msg.sender];
        uint256 reward = calculateReward(stakedAmount, stakingDuration);

        stakes[msg.sender] = 0;
        stakingTime[msg.sender] = 0;
        _mint(msg.sender, stakedAmount + reward); // Return staked tokens and reward
    }

    function calculateReward(
        uint256 amount,
        uint256 duration
    ) private pure returns (uint256) {
        // Reward logic, for example 0.1% per day
        return amount * (1 + duration / 86400 / 1000);
    }

    // Create or vote on a proposal
    function voteOnProposal(uint proposalId) public {
        require(balanceOf(msg.sender) > 0, "You need tokens to vote");
        require(!votes[proposalId][msg.sender], "Already voted");

        votes[proposalId][msg.sender] = true;
        proposals[proposalId] += balanceOf(msg.sender);
    }

    // Example of checking a proposal's vote count
    function checkProposal(uint proposalId) public view returns (uint256) {
        return proposals[proposalId];
    }
}
