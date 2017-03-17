contract RegistrarProxy {
    mapping (address => address) addresses;
    address registrar;
    bytes32 functioncall = sha3("register(bytes32,address)");
    
    function RegistrarProxy (address _registrar) {
        registrar = _registrar;
    }
    
    function () {
        if (addresses[msg.sender] == 1) {
            throw;
        }
        if (registrar.call(functioncall, msg.data, msg.sender)) {
            addresses[msg.sender] = 1;
        }
    }
}
