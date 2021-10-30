pragma solidity ^0.5.0;

/**
 * @notice Key sets with enumeration and delete. Uses mappings for random
 * and existence checks and dynamic arrays for enumeration. Key uniqueness is enforced. 
 * @dev Sets are unordered. Delete operations reorder keys. All operations have a 
 * fixed gas cost at any scale, O(1). 
 * author: Rob Hitchens
 */

library AddressSet {
    
    struct Set {
        mapping(address => uint) keyPointers;
        address[] keyList;
    }

    /**
     * @notice insert a key. 
     * @dev duplicate keys are not permitted.
     * @param self storage pointer to a Set. 
     * @param key value to insert.
     */    
    function insert(Set storage self, address key) internal {
        if (!exists(self, key)) {
            self.keyPointers[key] = self.keyList.push(key)-1;
        }
    }
    
    function getSet(Set storage self) internal view returns(address[] memory) {
        return self.keyList;
    }

    /**
     * @notice check if a key is in the Set.
     * @param self storage pointer to a Set.
     * @param key value to check. 
     * @return bool true: Set member, false: not a Set member.
     */  
    function exists(Set storage self, address key) internal view returns(bool) {
        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }
}