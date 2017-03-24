pragma solidity ^0.4.0;

import "RegistrarProxy.sol";

contract AbstractENS {
    function owner(bytes32 node) constant returns(address);
    function resolver(bytes32 node) constant returns(address);
    function ttl(bytes32 node) constant returns(uint64);
    function setOwner(bytes32 node, address owner);
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
    function setResolver(bytes32 node, address resolver);
    function setTTL(bytes32 node, uint64 ttl);

    event Transfer(bytes32 indexed node, address owner);
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
    event NewResolver(bytes32 indexed node, address resolver);
    event NewTTL(bytes32 indexed node, uint64 ttl);
}

contract Registrar {
    address owner;
    AbstractENS ens;
    bytes32 rootNode;
    mapping (bytes32 => uint) registeredTime;
    address proxy;
 
    modifier onlyOwner {
        if (msg.sender != owner)
            throw;
        _;
    }
    
    function Registrar(address ensAddr, bytes32 node) {
        owner = msg.sender;
        ens = AbstractENS(ensAddr);
        rootNode = node;
    }
    
    function register(bytes32 subnode, address owner) {
        if (registeredTime[subnode] != 0)
            throw;
        
        registeredTime[subnode] = now;
        ens.setSubnodeOwner(rootNode, subnode, owner);
        return;
    }
    
    function enableProxy() onlyOwner {
        if (proxy != 0)
            throw;
            
        proxy = new RegistrarProxy(this);
    }

    function disableProxy() onlyOwner {
        if (proxy == 0)
            throw;
            
        // TODO call proxy method to suicide?
        proxy = 0;
    }
    
    function destruct() onlyOwner {
        ens.setOwner(rootNode, owner);
        selfdestruct(owner);
    }
}