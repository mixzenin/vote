pragma solidity ^0.4.18;

import "./stringUtils.sol";
//import "https://github.com/ethereum/dapp-bin/library/stringUtils.sol";

contract Ownership {

    address owner;

    function Ownership() public {
        require(owner == 0);
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

}

contract Vote is Ownership {

    function Vote() public {

    }

    struct Variant {
      string name;
      uint16 numberOfVotes;
    }

    struct Ballot {
      uint64 id;
      string name;
      uint endTime;
      mapping (string => Variant) listOfVariants;
      string[] variantsNames;
      mapping (address => bool) isVoted;
      address[] votedAddressesList;

    }

    mapping (uint64 => Ballot) listOfBallots;
    uint64 ballotsIndex = 0;
    mapping (uint64 => address) listOfAllowedAddresses;
    address[] lists;
    mapping (uint64 => address[]) ballotsAllowedAddresses;// allowed addresses for each ballot
    uint64 listIndex = 0;

    function newAddressesList(address[] defaultAddresses) public onlyOwner returns(uint64 listAddr) {
        address newList = new AllowedAddresses(defaultAddresses);
        listOfAllowedAddresses[listIndex] = newList;
        lists.push(newList);
        listIndex++;
        return listIndex-1;
    }
    function getLists() public constant returns(address[] list) {
        return lists;
    }

    event ballotAddedEvent(string name, uint64 id);
    function addBallot(string name, uint64[] allowedListId, uint duration) public onlyOwner { // TODO Is possible same name
      for(uint64 i = 0; i < allowedListId.length; i++) require(listOfAllowedAddresses[allowedListId[i]] != 0);
      listOfBallots[ballotsIndex].id = ballotsIndex;
      listOfBallots[ballotsIndex].name = name;
      listOfBallots[ballotsIndex].endTime = now + duration*3600;
      for(i = 0; i < allowedListId.length; i++) {
        AllowedAddresses addr = AllowedAddresses(listOfAllowedAddresses[allowedListId[i]]);//connect contract
        addr.addAddress(msg.sender);
        ballotsAllowedAddresses[ballotsIndex].push(listOfAllowedAddresses[allowedListId[i]]);
      }
      ballotAddedEvent(name, ballotsIndex);
      ballotsIndex++;
    }

    function getBallot(uint64 id) public constant returns (string name) {
      Ballot storage ballot = listOfBallots[id];
      return ballot.name;
    }

    function getBallotAddressesList(uint64 id) public constant returns (address[] votedAddressesList) {
      return ballotsAllowedAddresses[id];
    }

    event variantAddedEvent(uint64 ballotId, string variantName);
    function addVariant(uint64 ballotId, string name) public onlyOwner {
        Ballot storage ballot = listOfBallots[ballotId];
        require(!StringUtils.equal(ballot.listOfVariants[name].name, name));
        ballot.listOfVariants[name].name = name;
        ballot.variantsNames.push(name);
        ballot.listOfVariants[name].numberOfVotes = 0;

        variantAddedEvent(ballotId, name);
    }

    function getVariant(uint64 ballotId, uint variantId) public constant returns(string name) {
        return listOfBallots[ballotId].variantsNames[variantId];
    }

    event votedEvent(uint64 ballotId, string variantName, uint64 countOfVotes);
    function voting(uint64 ballotId, string name) public {
        require(!listOfBallots[ballotId].isVoted[msg.sender]);
        require(StringUtils.equal(listOfBallots[ballotId].listOfVariants[name].name, name));
        assert(listOfBallots[ballotId].endTime > now);
        bool notErr = false;
        for(uint64 i = 0; i < ballotsAllowedAddresses[ballotId].length; i++) {
            AllowedAddresses list = AllowedAddresses(ballotsAllowedAddresses[ballotId][i]);
            if (list.checkVoter(msg.sender)){
              notErr = true;
              break;
            }
        }
        assert(notErr);
        listOfBallots[ballotId].isVoted[msg.sender] = true;
        listOfBallots[ballotId].votedAddressesList.push(msg.sender);
        listOfBallots[ballotId].listOfVariants[name].numberOfVotes++;
        votedEvent(ballotId, name, listOfBallots[ballotId].listOfVariants[name].numberOfVotes);

    }

    function getNumberOfVotes(uint64 ballotId, uint64 variantId) public constant returns(uint64 votesNumber) {
      Ballot storage ballot = listOfBallots[ballotId];
      string memory variantName = getVariant(ballotId, variantId);
      Variant storage variant = ballot.listOfVariants[variantName];
      return variant.numberOfVotes;
    }

     function getVotedAddresses(uint64 ballotId) public constant returns (address[] votedAddresses) {
        Ballot storage ballot = listOfBallots[ballotId];
        return ballot.votedAddressesList;
    }

    function getWinnerInVoting(uint64 ballotId) public constant returns (uint16 countOfVotes) {
        Ballot storage ballot = listOfBallots[ballotId];
        uint16 maximum;
        for (uint16 i = 0; i < ballot.variantsNames.length; i++)
            if(ballot.listOfVariants[ballot.variantsNames[i]].numberOfVotes > maximum) {
                maximum = ballot.listOfVariants[ballot.variantsNames[i]].numberOfVotes;
            }
        return (maximum);
    }

    function getCountOfVariants(uint64 ballotId) public constant returns(uint countOfVariants) {
        return listOfBallots[ballotId].variantsNames.length;
    }
}

//------------------------------------------------------------------------------

contract AllowedAddresses is Ownership {
    function AllowedAddresses(address[] defaultAddresses) {
      listOfAdresses = defaultAddresses;
      for(uint16 i = 0; i < listOfAdresses.length; ++i) {
          addresses[listOfAdresses[i]] = true;
      }
    }
    mapping (address => bool) addresses;// allow adresses for this list
    address[] listOfAdresses;


    function addAddress(address addr) public {
        addresses[addr] = true;
        listOfAdresses.push(addr);
    }

    function deleteAddress(address addr) public {
        addresses[addr] = false;
        for(uint16 i = 0; i < listOfAdresses.length; ++i) {
          if (addr == listOfAdresses[i]) {
            delete listOfAdresses[i];
            break;
          }
        }
    }

    function getAdresses() public constant returns(address[] addr) {
        return listOfAdresses;
    }

    function checkVoter(address addr) public constant returns(bool isVoter) {
        return addresses[addr];
    }
}
