// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
contract MyToken is ERC20{
 uint256 constant INIT_SUPPLY_POC = 1000000000;
 uint8 constant SECONDS_PER_BLOCK = 15;
  
 uint256 constant SCHEDULE_TERM = (60 * 60 * 24 * 30) / SECONDS_PER_BLOCK;  // during 30 days
 uint256 constant MINT_TERM = (60 * 60 * 24 * 730) / SECONDS_PER_BLOCK;  // during 730 days
 address constant _approver1 = 0x2C76A35B071b9299b538c93686903c8Ab9F06e5e;
 address constant _approver2 = 0x65d6D8353566Be8866a03B41d21173C647DBa0dD;
 
 //uint256 constant SCHEDULE_TERM = 30 / SECONDS_PER_BLOCK;  // during 30 seconds
 //uint256 constant MINT_TERM = 730 / SECONDS_PER_BLOCK;  // during 730 seconds
 //address constant _approver1 = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
 //address constant _approver2 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
 
 address _owner; 
 
 uint256 private _addedSupplyToken;
 uint256 private _listingDate;
 uint256 private _burnApproved1 = 0;
 uint256 private _burnApproved2 = 0;
 uint256 private _mintApproved1 = 0;
 uint256 private _mintApproved2 = 0;
 
 struct Schedule{
  uint256 day;
  uint256 POC;
 }
 Schedule[] private schedule;
 
 constructor() ERC20("PocketArena", "POC"){
  _listingDate = block.number;
  _owner = msg.sender;
  _mint(_owner, (INIT_SUPPLY_POC * (10 ** uint256(decimals()))));
  _addedSupplyToken = 0;  
  
  schedule.push(Schedule(_listingDate, 501666667));  
  schedule.push(Schedule((_listingDate + SCHEDULE_TERM), 503333334));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 2)), 505000001));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 3)), 506666668));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 4)), 508333335));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 5)), 510000002));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 6)), 526666669));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 7)), 528333336));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 8)), 552500003));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 9)), 554166670));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 10)), 578333337));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 11)), 580000004));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 12)), 754166671));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 13)), 755833338));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 14)), 780000005));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 15)), 781666672));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 16)), 805833339));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 17)), 807500006));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 18)), 831666673));  
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 19)), 1666667));
  schedule.push(Schedule((_listingDate + (SCHEDULE_TERM * 119)), INIT_SUPPLY_POC));
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
   uint dateDiff = ((currentDate - schedule[(schedule.length - 2)].day) / SCHEDULE_TERM);
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
  require((msg.sender == _approver1 || msg.sender == _approver2), "only approver is possible");
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
  return true;
 }
 function burn_approve_down() onlyApprover external returns (bool) {
  if (msg.sender == _approver1) {
      _burnApproved1 = 0;
  }
  else if (msg.sender == _approver2) {
      _burnApproved2 = 0;
  }
  return true;
 }
 function burn(uint256 burnToken) listingDT onlyOwner external returns (bool) {
   require(_addedSupplyToken >= burnToken, "you can burn newly added token only");
   require(balanceOf(msg.sender) >= burnToken, "you can burn in your balance only");
   require((_burnApproved1 > 0 || _burnApproved2 > 0), "you must get the approval");
   if (_burnApproved1 > 0) {
    require(_burnApproved1 == burnToken, "you must get the approval from approver1");
   }
   if (_burnApproved2 > 0) {
    require(_burnApproved2 == burnToken, "you must get the approval from approver2");
   }
   _burn(msg.sender, burnToken);
   _addedSupplyToken = (_addedSupplyToken - burnToken);
   _burnApproved1 = 0;
   _burnApproved2 = 0;
   return true;
 }
 function mint_approve_up(uint256 approveToken) onlyApprover external returns (bool) {
  if (msg.sender == _approver1) {
      _mintApproved1 = approveToken;
  }
  else if (msg.sender == _approver2) {
      _mintApproved2 = approveToken;
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
  return true;
 }
 function mint(uint256 addedToken) listingDT onlyOwner external returns (bool) {
  require((_listingDate + MINT_TERM) <= block.number, "creating new token is not yet");
  require((_mintApproved1 > 0 || _mintApproved2 > 0), "you must get the approval");
  if (_mintApproved1 > 0) {
    require(_mintApproved1 == addedToken, "you must get the approval from approver1");
   }
   if (_mintApproved2 > 0) {
    require(_mintApproved2 == addedToken, "you must get the approval from approver2");
   }
  _mint(_owner, addedToken);
  _addedSupplyToken = (_addedSupplyToken + addedToken);
  _mintApproved1 = 0;
  _mintApproved2 = 0;
  return true;
 }
 function approve_clear() onlyOwner external returns (bool) {
  _burnApproved1 = 0;
  _burnApproved2 = 0;
  _mintApproved1 = 0;
  _mintApproved2 = 0;
  return true;
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
