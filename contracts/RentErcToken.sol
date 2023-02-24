// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
contract RTOToken{
    using SafeMath for uint256;
    address public deployer;
    AggregatorV3Interface  internal priceFeed;

    struct Home{
        address renter;
        address owner;
        uint256 listPrice;
        uint256 totalEarned;
        uint256 earningsPercent;
    }

    mapping (address => bool) public Landlords;
    mapping(address => Home) public Homes;
    mapping(address => uint256) public balances;

    uint256 public totalSupply;
    event TokenMinted(address earner,
        uint256 amount
    );

    event EarningPerentChanged(address renter, 
    uint256 newEarningPercent);


    event ListPriceChanged(
        address renter,
        uint256 newListPrice
    );

    event RenterChanged(
        address renter,
        address newRenter
    );

    event HomePaidOff(address renter);

    constructor(){
        deployer = msg.sender;
        priceFeed = AggregatorV3Interface(0x4a504064996F695dD8ADd2452645046289c4811C);
        totalSupply = 0;
    }

    function addLandlord(address _landlord)public{
        require(msg.sender == deployer,"Only admin can call this function");
        Landlords[_landlord] = true;
    }

    function addHome(uint256 _listPrice, address _renter,
    uint256 _earningsPercent
    )public{
        require(Landlords[msg.sender]== true, "Only approved landlords can list Homes.");
        Homes[_renter] = Home({
            renter:_renter,
            owner: msg.sender,
            listPrice:_listPrice,
            totalEarned: 0,
            earningsPercent: _earningsPercent
        });
    }

    function changeRenter(address _oldRenter, address _newRenter)public{
        require(Homes[_oldRenter].owner == msg.sender, "Only the owner of this proprty can change the owner!");
        Homes[_oldRenter].renter = _newRenter;
        Homes[_newRenter] = Homes[_oldRenter];
        delete Homes[_oldRenter];
        emit RenterChanged(_oldRenter, _newRenter);
    }

    function changeListPrice(address _renter, uint _newListPrice)public{
        require(Homes[_renter].owner == msg.sender,"Only the owner of this property can update the list price");
        Homes[_renter].listPrice = _newListPrice;
        emit ListPriceChanged(_renter, _newListPrice);
    }

    function changeEarningPercent(address _renter, uint _newEarningPercent)public{
        require(Homes[_renter].owner == msg.sender,"Only the owner of this propery can change the value! ");
        Homes[_renter].earningsPercent = _newEarningPercent;
        emit EarningPerentChanged(_renter, _newEarningPercent);
    }

    function getThePrice()public view returns(uint){
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answereInRound        
            )= priceFeed.latestRoundData();

        return uint(price).div(1e8);
    }

    function balanceOf(address _renter)public returns(uint){
        return balances[_renter];
    }

    function payRent(address payable _to)public payable{
        require(Landlords[_to]==true,"Rent must be sent approved landlord");
        require(Homes[msg.sender].owner == _to,"Rent must be paid to the owner of the home");
        _to.transfer(msg.value);
        uint amountToMint = msg.value.mul(uint(getThePrice())).mul(Homes[msg.sender].earningsPercent).div(100);
        balances[msg.sender] += amountToMint;
        Homes[msg.sender].totalEarned += amountToMint;
        totalSupply += amountToMint;

        if(Homes[msg.sender].totalEarned > Homes[msg.sender].listPrice){
            emit HomePaidOff(msg.sender);
        }

        emit TokenMinted(msg.sender, amountToMint);
    }





}