// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "src/MyGovernor.sol";
import {Box} from "src/Box.sol";
import {GovToken} from "src/GovToken.sol";
import {TimeLock} from "src/TimeLock.sol";

contract MyGovernorTest is Test {
    MyGovernor governor;
    Box box;
    GovToken govToken;
    TimeLock timelock;
    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;

    uint256 public constant MIN_DELAY = 3600; //seconds
    uint256 public constant VOTING_DELAY = 1; //blocks til the vote is active
    uint256 public constant VOTING_PEROID = 50400; //blocks til the vote is active
    address[] proposers;
    address[] executors;
    uint256[] values;
    bytes[] calldatas;
    address[] targets;

    function setUp() external {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);

        vm.startPrank(USER);
        govToken.delegate(USER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timelock);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();
        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.grantRole(adminRole, USER);

        vm.stopPrank();

        box = new Box();
        box.transferOwnership(address(timelock));
    }

    function testCanUpdateWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdateBox() public {
        uint256 valueToStore = 888;
        string memory decp = "store 888 in box";
        bytes memory encodedFuncCall = abi.encodeWithSignature(
            "store(uint256)",
            valueToStore
        );
        values.push(0);
        calldatas.push(encodedFuncCall);
        targets.push(address(box));

        //1. propose to DAO
        uint256 proposeId = governor.propose(targets, values, calldatas, decp);
        console.log("Propose State: ", uint256(governor.state(proposeId)));
        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Propose State: ", uint256(governor.state(proposeId)));

        //2. vote
        string memory reason = "cuz i want to make it happen";
        uint8 voteWay = 1; //voteType.for
        vm.prank(USER);
        governor.castVoteWithReason(proposeId, voteWay, reason);
        vm.warp(block.timestamp + VOTING_PEROID + 1);
        vm.roll(block.number + VOTING_PEROID + 1);

        //3 queue the TX
        bytes32 descriptionHash = keccak256(abi.encodePacked(decp));
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);

        // 4.execute
        governor.execute(targets, values, calldatas, descriptionHash);

        assertEq(box.getNumber(), valueToStore);
    }
}
