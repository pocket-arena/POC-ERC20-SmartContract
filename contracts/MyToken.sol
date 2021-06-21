// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
  uint256 constant INIT_SUPPLY_POC = 1000000000;
  uint256 constant MAX_MINT_POC = 2000000000;
    
// address constant _approver1 = 0x2C76A35B071b9299b538c93686903c8Ab9F06e5e;
// address constant _approver2 = 0x65d6D8353566Be8866a03B41d21173C647DBa0dD;
// address constant _approver3 = 0x116EE03B66e0AbF4098B86f8C666cbc919fb7A8D;
// address constant _approver4 = 0xb03aB8c62b6119248720f3E0B1E1404493a25980;
  
  address constant _approver1 = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
  address constant _approver2 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
  address constant _approver3 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
  address constant _approver4 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
  
  address _owner; 
  
  uint8 private _seconds_per_block;
  uint256 private _schedule_term;
  uint256 private _mint_term;
  
  uint256 private _addedSupplyToken;
  uint256 private _listingDate;
  uint256 private _burnApproved1 = 0;
  uint256 private _burnApproved2 = 0;
  uint256 private _burnApproved3 = 0;
  uint256 private _burnApproved4 = 0;
  uint256 private _mintApproved1 = 0;
  uint256 private _mintApproved2 = 0;
  uint256 private _mintApproved3 = 0;
  uint256 private _mintApproved4 = 0;
  uint256 private _rescheduleApproved1 = 0;
  uint256 private _rescheduleApproved2 = 0;
  uint256 private _rescheduleApproved3 = 0;
  uint256 private _rescheduleApproved4 = 0;
  
  struct Schedule{
    uint256 day;
    uint256 POC;
  }
  Schedule[] private schedule;
  
  constructor() ERC20("PocketArena", "POC") {
    _seconds_per_block = 15;
    //_schedule_term = (60 * 60 * 24 * 30) / _seconds_per_block;  // during 30 days
    //_mint_term = (60 * 60 * 24 * 730) / _seconds_per_block;     // during 730 days
    _schedule_term = 30 / _seconds_per_block;  // during 30 seconds
    _mint_term = 730 / _seconds_per_block;     // during 730 seconds
       
    _listingDate = block.number;
    _owner = msg.sender;
    _mint(_owner, (INIT_SUPPLY_POC * (10 ** uint256(decimals()))));
    _addedSupplyToken = 0;  
    
    schedule.push(Schedule(_listingDate, 501666667));  
    schedule.push(Schedule((_listingDate + _schedule_term), 503333334));
    schedule.push(Schedule((_listingDate + (_schedule_term * 2)), 505000001));
    schedule.push(Schedule((_listingDate + (_schedule_term * 3)), 506666668));
    schedule.push(Schedule((_listingDate + (_schedule_term * 4)), 508333335));
    schedule.push(Schedule((_listingDate + (_schedule_term * 5)), 510000002));
    schedule.push(Schedule((_listingDate + (_schedule_term * 6)), 526666669));
    schedule.push(Schedule((_listingDate + (_schedule_term * 7)), 528333336));
    schedule.push(Schedule((_listingDate + (_schedule_term * 8)), 552500003));
    schedule.push(Schedule((_listingDate + (_schedule_term * 9)), 554166670));
    schedule.push(Schedule((_listingDate + (_schedule_term * 10)), 578333337));
    schedule.push(Schedule((_listingDate + (_schedule_term * 11)), 580000004));
    schedule.push(Schedule((_listingDate + (_schedule_term * 12)), 754166671));
    schedule.push(Schedule((_listingDate + (_schedule_term * 13)), 755833338));
    schedule.push(Schedule((_listingDate + (_schedule_term * 14)), 780000005));
    schedule.push(Schedule((_listingDate + (_schedule_term * 15)), 781666672));
    schedule.push(Schedule((_listingDate + (_schedule_term * 16)), 805833339));
    schedule.push(Schedule((_listingDate + (_schedule_term * 17)), 807500006));
    schedule.push(Schedule((_listingDate + (_schedule_term * 18)), 831666673));  
    schedule.push(Schedule((_listingDate + (_schedule_term * 19)), 1666667));
    schedule.push(Schedule((_listingDate + (_schedule_term * 119)), INIT_SUPPLY_POC));
  }
  function scheduleGet(uint16 round) external view returns (Schedule memory) {
    return schedule[round];
  }
  function lockedPOC(uint256 currentDate) public view returns (uint256) {
    if (schedule[(schedule.length - 1)].day <= currentDate) {
      //return (INIT_SUPPLY_POC - schedule[(schedule.length - 1)].POC);
      return 0;
    }
    else if (schedule[(schedule.length - 2)].day <= currentDate) { 
      uint dateDiff = ((currentDate - schedule[(schedule.length - 2)].day) / _schedule_term);
      uint256 newUnlockPOC = (schedule[(schedule.length - 2)].POC * (dateDiff + 1));
      return (INIT_SUPPLY_POC - (schedule[(schedule.length - 3)].POC + newUnlockPOC));
    }
    else {
      for (uint i=(schedule.length - 1); i>0; i--) {
        if (schedule[i-1].day <= currentDate) {
          return (INIT_SUPPLY_POC - schedule[i-1].POC);
        }
      }
      return INIT_SUPPLY_POC;
    }
  }
  function transferable() public view returns (uint256) {
    uint256 locked = (lockedPOC(block.number) * (10 ** uint256(decimals())));
    if (balanceOf(_owner) > locked) {
	  return (balanceOf(_owner) - locked);
    }
    else {
      return 0;
    }
  }

  modifier listingDT() {
    require(_listingDate <= block.number, "listing is not yet");
    _;
  }
  modifier onlyApprover() {
    require((msg.sender == _approver1 || msg.sender == _approver2 || msg.sender == _approver3 || msg.sender == _approver4), "only approver is possible");
    _;
  }
  modifier onlyOwner() {
    require(msg.sender == _owner, "only owner is possible");
    _;
  }
  modifier unlocking(uint256 amount) {
    if (msg.sender != _owner){
       _;
    }
    else {
      require(transferable() >= amount, "lack of transferable token");
      _;
    }
  }
  
  function burn_approve_up(uint256 approveToken) onlyApprover external returns (bool) {
    if (msg.sender == _approver1) {
      _burnApproved1 = approveToken;
    }
    else if (msg.sender == _approver2) {
      _burnApproved2 = approveToken;
    }
    else if (msg.sender == _approver3) {
      _burnApproved3 = approveToken;
    }
    else if (msg.sender == _approver4) {
      _burnApproved4 = approveToken;
    }
    return true;
  }
  function burn_approve_down() onlyApprover external returns (bool) {
    if (msg.sender == _approver1) {
      _burnApproved1 = 0;
    }
    else if (msg.sender == _approver2) {
      _burnApproved2 = 0;
    }
    else if (msg.sender == _approver3) {
      _burnApproved3 = 0;
    }
    else if (msg.sender == _approver4) {
      _burnApproved4 = 0;
    }
    return true;
  }
  function burn(uint256 burnToken) listingDT onlyOwner external returns (bool) {
    require(_addedSupplyToken >= burnToken, "you can burn newly added token only");
    require(balanceOf(msg.sender) >= burnToken, "you can burn in your balance only");
    uint8 sum_approval = 0;
    if (_burnApproved1 > 0) {
      require(_burnApproved1 == burnToken, "you must get the right approval from approver1");
      sum_approval++;
    }
    if (_burnApproved2 > 0) {
      require(_burnApproved2 == burnToken, "you must get the right approval from approver2");
      sum_approval++;
    }
    if (_burnApproved3 > 0) {
      require(_burnApproved3 == burnToken, "you must get the right approval from approver3");
      sum_approval++;
    }
    if (_burnApproved4 > 0) {
      require(_burnApproved4 == burnToken, "you must get the right approval from approver4");
      sum_approval++;
    }
    require((sum_approval >= 2), "you must get the 2 approvals at least");
    _burn(msg.sender, burnToken);
    _addedSupplyToken = (_addedSupplyToken - burnToken);
    _burnApproved1 = 0;
    _burnApproved2 = 0;
    _burnApproved3 = 0;
    _burnApproved4 = 0;
    return true;
  }
  
  function mint_approve_up(uint256 approveToken) onlyApprover external returns (bool) {
    if (msg.sender == _approver1) {
      _mintApproved1 = approveToken;
    }
    else if (msg.sender == _approver2) {
      _mintApproved2 = approveToken;
    }
    else if (msg.sender == _approver3) {
      _mintApproved3 = approveToken;
    }
    else if (msg.sender == _approver4) {
      _mintApproved4 = approveToken;
    }
    return true;
  }
  function mint_approve_down() onlyApprover external returns (bool) {
    if (msg.sender == _approver1) {
      _mintApproved1 = 0;
    }
    else if (msg.sender == _approver2) {
      _mintApproved2 = 0;
    }
    else if (msg.sender == _approver3) {
      _mintApproved3 = 0;
    }
    else if (msg.sender == _approver4) {
      _mintApproved4 = 0;
    }
    return true;
  }
  function mint(uint256 addedToken) listingDT onlyOwner external returns (bool) {
    require((_listingDate + _mint_term) <= block.number, "creating new token is not yet");
    require(MAX_MINT_POC >= (_addedSupplyToken + addedToken), "mint is reached on max");
    uint8 sum_approval = 0;
    if (_mintApproved1 > 0) {
      require(_mintApproved1 == addedToken, "you must get the right approval from approver1");
      sum_approval++;
    }
    if (_mintApproved2 > 0) {
      require(_mintApproved2 == addedToken, "you must get the right approval from approver2");
      sum_approval++;
    }
    if (_mintApproved3 > 0) {
      require(_mintApproved3 == addedToken, "you must get the right approval from approver3");
      sum_approval++;
    }
    if (_mintApproved4 > 0) {
      require(_mintApproved4 == addedToken, "you must get the right approval from approver4");
      sum_approval++;
    }
    require((sum_approval >= 2), "you must get the 2 approvals at least");
    _mint(_owner, addedToken);
    _addedSupplyToken = (_addedSupplyToken + addedToken);
    _mintApproved1 = 0;
    _mintApproved2 = 0;
    _mintApproved3 = 0;
    _mintApproved4 = 0;
    return true;
  }
  
  function reschedule_approve_up(uint256 approveBlock) onlyApprover external returns (bool) {
    if (msg.sender == _approver1) {
      _rescheduleApproved1 = approveBlock;
    }
    else if (msg.sender == _approver2) {
      _rescheduleApproved2 = approveBlock;
    }
    else if (msg.sender == _approver3) {
      _rescheduleApproved3 = approveBlock;
    }
    else if (msg.sender == _approver4) {
      _rescheduleApproved4 = approveBlock;
    }
    return true;
  }
  function reschedule_approve_down() onlyApprover external returns (bool) {
    if (msg.sender == _approver1) {
      _rescheduleApproved1 = 0;
    }
    else if (msg.sender == _approver2) {
      _rescheduleApproved2 = 0;
    }
    else if (msg.sender == _approver3) {
      _rescheduleApproved3 = 0;
    }
    else if (msg.sender == _approver4) {
      _rescheduleApproved4 = 0;
    }
    return true;
  }
  function reschedule(uint256 term_hour_changeDate, uint8 new_seconds_per_block) onlyOwner external {
    uint8 sum_approval = 0;
    if (_rescheduleApproved1 > 0) {
      require(_rescheduleApproved1 == new_seconds_per_block, "you must get the right approval from approver1");
      sum_approval++;
    }
    if (_rescheduleApproved2 > 0) {
      require(_rescheduleApproved2 == new_seconds_per_block, "you must get the right approval from approver2");
      sum_approval++;
    }
    if (_rescheduleApproved3 > 0) {
      require(_rescheduleApproved3 == new_seconds_per_block, "you must get the right approval from approver3");
      sum_approval++;
    }
    if (_rescheduleApproved4 > 0) {
      require(_rescheduleApproved4 == new_seconds_per_block, "you must get the right approval from approver4");
      sum_approval++;
    }
    require((sum_approval >= 2), "you must get the 2 approvals at least");
    // changeDate means the date(block.number) of when ETH2.0 chagnes the rule to 6s
    uint256 changeDate = block.number;
    if (term_hour_changeDate > 0) {
      changeDate = changeDate - (term_hour_changeDate * 60 * 60 / new_seconds_per_block);
    }
    // recalculate some schedules only which it's not used(reached) yet
    uint256 recalculate_target;
    for (uint i=(schedule.length - 1); i>0; i--) {
      if (changeDate <= schedule[i-1].day) {
        recalculate_target = (schedule[i-1].day - changeDate) * _seconds_per_block;
        schedule[i-1].day = changeDate + (recalculate_target / new_seconds_per_block);
      } 
      else {
        break;
      }
    }
    _seconds_per_block = new_seconds_per_block;
  }
  
    function approve_clear(uint8 target) onlyOwner external returns (bool) {
      if (target == 1) {
        _burnApproved1 = 0;
        _burnApproved2 = 0;
        _burnApproved3 = 0;
        _burnApproved4 = 0;
        return true;
      }
      else if (target == 2) {
        _mintApproved1 = 0;
        _mintApproved2 = 0;
        _mintApproved3 = 0;
        _mintApproved4 = 0;
        return true;
      }
      else if (target == 3) {
        _rescheduleApproved1 = 0;
        _rescheduleApproved2 = 0;
        _rescheduleApproved3 = 0;
        _rescheduleApproved4 = 0;
        return true;
      }
      else {
       return false;   
      }
  }

  function transfer(address recipient, uint256 amount) listingDT unlocking(amount) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  function transferFrom(address sender, address recipient, uint256 amount) listingDT public virtual override returns (bool) {
    if (msg.sender == _owner){
      require(transferable() >= amount, "lack of transferable token");
    }
    if (super.transferFrom(sender, recipient, amount)) {
      return true;
    }
    else 
    {
      return false;
    }
  }
  
}
