// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/utils//math/SafeMath.sol";
contract MyToken is ERC20{
 uint256 private _schedule_term;
 uint256 private _mint_term;
 address _owner;
 uint256 private _initSupplyPOC;
 uint256 private _addedSupplyToken;
 uint256 private _listingDate;
 struct Schedule{
   uint256 day;
   uint256 POC;
 }
 Schedule[] private schedule;
 
 constructor(uint listing_days) ERC20("PocketArena", "POC"){
  _schedule_term = 30 days;
  _mint_term = 730 days;
  //_schedule_term = 30 seconds;  
  //_mint_term = 730 seconds;

  _listingDate = block.timestamp + listing_days;
  _owner = msg.sender;
  _initSupplyPOC = 1000000000;
  _mint(_owner, SafeMath.mul(_initSupplyPOC, (10 ** uint256(decimals()))));
  _addedSupplyToken = 0;  
  
  schedule.push(Schedule(_listingDate, 501666667));  
  schedule.push(Schedule(SafeMath.add(_listingDate, _schedule_term), 503333334));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 2)), 505000001));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 3)), 506666668));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 4)), 508333335));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 5)), 510000002));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 6)), 526666669));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 7)), 528333336));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 8)), 552500003));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 9)), 554166670));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 10)), 578333337));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 11)), 580000004));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 12)), 754166671));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 13)), 755833338));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 14)), 780000005));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 15)), 781666672));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 16)), 805833339));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 17)), 807500006));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 18)), 831666673));  
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 19)), 1666667));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 119)), _initSupplyPOC));
 }
 function listingDateGet() public view virtual returns (uint256) {
  return _listingDate;
 }
 function scheduleGet(uint16 round) public virtual view returns (Schedule memory) {
   return schedule[round];
 }
 function lockedPOC(uint256 currentDate) public view returns (uint256) {
  if (schedule[SafeMath.sub(schedule.length, 1)].day <= currentDate) {
   //return SafeMath.sub(_initSupplyPOC, schedule[SafeMath.sub(schedule.length, 1)].POC);
   return 0;
  }
  else if (schedule[SafeMath.sub(schedule.length, 2)].day <= currentDate) { 
   uint dateDiff = SafeMath.div(SafeMath.sub(currentDate, schedule[SafeMath.sub(schedule.length, 2)].day), _schedule_term);
   uint256 newUnlockPOC = SafeMath.mul(schedule[SafeMath.sub(schedule.length, 2)].POC, SafeMath.add(dateDiff, 1));
   return SafeMath.sub(_initSupplyPOC, SafeMath.add(schedule[SafeMath.sub(schedule.length, 3)].POC, newUnlockPOC));
  }
  else {
   for (uint i=SafeMath.sub(schedule.length, 1); i>0; i--) {
    if (schedule[i-1].day <= currentDate) {
     return SafeMath.sub(_initSupplyPOC, schedule[i-1].POC);
    }
   }
   return _initSupplyPOC;
  }
 }
 function transferable() public view returns (uint256) {
   uint256 locked = SafeMath.mul(lockedPOC(block.timestamp), (10 ** uint256(decimals())));
   if (balanceOf(_owner) > locked) {
	   return SafeMath.sub(balanceOf(_owner), locked);
   }
   else {
      return 0;
   }
 }

 modifier listingDT() {
  require(_listingDate <= block.timestamp, "listing is not yet");
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
 function burn(uint256 burnToken) listingDT onlyOwner public returns (bool) {
   require(_addedSupplyToken >= burnToken, "you can burn newly added token only");
   require(balanceOf(msg.sender) >= burnToken, "you can burn in your balance only");
   _burn(msg.sender, burnToken);
   _addedSupplyToken = SafeMath.sub(_addedSupplyToken, burnToken);
   return true;
 }
 function mint(uint256 addedToken) listingDT onlyOwner public returns (bool) {
  require(SafeMath.add(_listingDate, _mint_term) <= block.timestamp, "creating new token is not yet");
  _mint(_owner, addedToken);
  _addedSupplyToken = SafeMath.add(_addedSupplyToken, addedToken);
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