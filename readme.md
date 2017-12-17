# Еthereum voting smart-contract

### Modifier

```
modifier onlyOwner()
```

Functions with this modifier may call only owner of smart-contract

---

### Functions

```
function newAddressesList() public onlyOwner returns(uint64 listId)
```
Creating new list of allowed addresses for voting. Return list id.

---

```
function addBallot(string name, uint64[] allowedListId, uint duration) public onlyOwner
```

Creates a new vote.

Inputs:
* Voting name
* Allowed lists id
* Voting duration in hours


---

```
function addVariant(uint64 ballotId, string name) public onlyOwner
```

Creating new variant for specific voting

Inputs:
* Voting id
* Variant name

```
function voting(uint64 ballotId, string name) public
```

Voting function

Inputs:
* Voting id
* Variant name

---

```
function getNumberOfVotes(uint64 ballotId, uint64 variantId) public constant returns(uint64 votesNumber)
```

Shows count of votes for specific variant

Inputs:
* Voting id
* Variant id

---

```
function getVotedAddresses(uint64 ballotId) public constant returns (address[] votedAddresses)
```
Shows voters for a particular voting

Inputs:
* Voting id

---

```
function getWinnerInVoting(uint64 ballotId) public constant returns (uint64[] winners)
```
Shows the winner's id of a particular vote

Inputs:
* Voting id

Outputs:
* Count of votes

---

```
function getWinnerInVoting(uint64 ballotId) public constant returns (uint16 countOfVotes)
```
Shows the winner of a particular vote

Inputs:
* Voting id

Outputs:
* Count of votes of the winner

---

```
function getLists() public constant returns(address[] list)
```
Shows all avaliable lists of voters

Outputs:
* List of voters

---

```
function getVariant(uint64 ballotId, uint variantId) public constant returns(string name)
```
Shows variant of specific voting

Inputs:
* Voting id
* Variant id

Outputs:
* Variant name

---

```
function getBallot(uint64 id) public constant returns (string name)
```
Shows voting name

Inputs:
* Voting id

Outputs:
* Voting name

---


```
function getBallotAddressesList(uint64 id) public constant returns (address[] votedAddressesList)
```
Shows connected addresses lists

Inputs:
* Voting id

Outputs:
* Connected adresses list

---


### Events

```
event ballotAddedEvent(string name, uint64 id);
```

Returns the name of the added voting and his id

---

```
event variantAddedEvent(uint64 ballotId, string variantName);
```

Returns the name of the added variant and voting id


---

```
event votedEvent(uint64 ballotId, string variantName, uint64 countOfVotes);
```

Returns voting id, the name of the variant, and the number of votes for the selected variant
