//SPDX-License-Identifier: MIT

pragma  solidity >=0.6.0<0.9.0;

import"@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
	// safe math library check uint256 for integer overflows
    using SafeMathChainlink for uint256;
    

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;


    constructor() public{
        owner = msg.sender;
    }
 
    function fund() public payable{
        // What eth -> usd conversion rate
        uint256 minimumUSD = 50*10**18;
        require(getConverstuinRate(msg.value) >= minimumUSD, "You need to spend more Eth");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);


    }

    function getVersion() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        return priceFeed.version();
    }
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
         (
      ,
      int256 answer,
      ,
      ,
      
    ) = priceFeed.latestRoundData();
    return uint256(answer*10_000_000_000);
    }

    function getConverstuinRate(uint256 _ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (_ethAmount * ethPrice )/1_000_000_000_000_000_000;
        //uint256 ethAmountInUsd = (_ethAmount * ethPrice )/1_000_000_000_000_000_000;
        return ethAmountInUsd;
    }


    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function withdraw() payable onlyOwner public{
        msg.sender.transfer(address(this).balance);
        for(uint256 funderIndex =0; funderIndex < funders.length;funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;

        }
        funders = new address[](0);

    }

    function getBalance() public view returns (uint256){
        return address(this).balance/1_000_000_000_000_000_000;}
    
    function getBalanceInDollars() public view returns (uint256){
        return getConverstuinRate(address(this).balance)/1_000_000_000_000_000_000;
    }

}
