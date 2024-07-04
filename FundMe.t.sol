//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("Abhay");
    uint256 constant SEND_AMOUNT = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUSDisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundAmountMoreThanRequiredEth() public {
        vm.expectRevert();

        fundMe.fund();
    }

    function testFundAmountIsMorethanEqualRequiredAmount() public funded {
        // vm.prank(USER); //set msg.sender - The next trans send by the USER
        // fundMe.fund{value: SEND_AMOUNT}();

        uint256 getAmountFunded = fundMe.s_addressToAmountFunded(USER);
        assertEq(getAmountFunded, SEND_AMOUNT);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_AMOUNT}();

        _;
    }

    function testAddsFundersToTheFundersArray() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: SEND_AMOUNT}();

        address funder = fundMe.s_funders(0);
        assertEq(funder, USER);
    }

    function testFundWithraw() public funded {
        //  vm.prank(USER);
        //  fundMe.fund{value: SEND_AMOUNT}();

        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawASingleFunderBalance() public funded {
        //Arrange

        uint256 StartingOwnerBal = fundMe.i_owner().balance;
        uint256 StratingFundedBal = address(fundMe).balance;

        //Act
        vm.prank(fundMe.i_owner()); // 200
        fundMe.withdraw();

        //console.log(gasUsed); // 200
        //assert
        uint256 EndingOwnerBal = fundMe.i_owner().balance;
        uint256 EndingFundedBal = address(fundMe).balance;
        assertEq(EndingFundedBal, 0);
        assertEq(StratingFundedBal + StartingOwnerBal, EndingOwnerBal);
    }

    function testWithdrawASingleFunderBalanceCheaper() public funded {
        //Arrangec

        uint256 StartingOwnerBal = fundMe.i_owner().balance;
        uint256 StratingFundedBal = address(fundMe).balance;

        //Act
        vm.prank(fundMe.i_owner()); // 200
        fundMe.cheaperWithdraw();

        //console.log(gasUsed); // 200
        //assert
        uint256 EndingOwnerBal = fundMe.i_owner().balance;
        uint256 EndingFundedBal = address(fundMe).balance;
        assertEq(EndingFundedBal, 0);
        assertEq(StratingFundedBal + StartingOwnerBal, EndingOwnerBal);
    }

    function testMultipleFundersWithdarw() public funded {
        //arrange
        uint160 numberoffunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberoffunders; i++) {
            //vm.prank() new address
            //vm.deal() send value to new address
            //hoax ----> combination of prank and deal --- set new address with some in-build ether
            hoax(address(i), SEND_AMOUNT);
            fundMe.fund{value: SEND_AMOUNT}();
        }

        uint256 StartingOwnerBal = fundMe.i_owner().balance;
        uint256 StratingFundedBal = address(fundMe).balance;

        //act
        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        assert(address(fundMe).balance == 0);
        assert(startingFunderIndex + StartingOwnerBal == fundMe.i_owner().balance);
    }
}

//    what can we do to work with address out side from our system?
//    1. Unit test ---> test a specefic part of the code.
//    2. Integration --> test how out code works with different part of the code.
//    3. Forked --> test code in real enviroment.
