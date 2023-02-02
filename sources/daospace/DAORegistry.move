module DAOSpaceFramework::DAORegistry{
    use StarcoinFramework::Errors;
    use StarcoinFramework::Signer;
    use StarcoinFramework::Account;

    friend DAOSpaceFramework::DAOSpace;
    friend DAOSpaceFramework::DAOExtensionPoint;
    friend DAOSpaceFramework::DAOPluginMarketplace;
    friend DAOSpaceFramework::DAOAccount;
    friend DAOSpaceFramework::GasOracleProposalPlugin;

    struct DAOSpaceSignerCapability has key {
        cap: Account::SignerCapability,
    }

    spec module {
        pragma verify = false;
        pragma aborts_if_is_strict = true;
    }

    const ERR_ALREADY_INITIALIZED: u64 = 100;
    const ERROR_NOT_HAS_PRIVILEGE: u64 = 101;

    /// Global DAO registry info
    struct DAORegistry has key{
        next_dao_id: u64,
    }

    /// Registry Entry for record the mapping between `DAOT` and `dao_address`
    struct DAORegistryEntry<phantom DAOT> has key{
        dao_id: u64,
        dao_address: address,
    }

    // public(friend) fun initialize(){
    //     assert!(!exists<DAORegistry>(CoreAddresses::GENESIS_ADDRESS()), Errors::already_published(ERR_ALREADY_INITIALIZED));
    //     let signer = GenesisSignerCapability::get_genesis_signer();
    //     move_to(&signer, DAORegistry{next_dao_id: 1})
    // }

    public(friend) fun initialize(signer: &signer, cap: Account::SignerCapability){
        assert!(Signer::address_of(signer) == @DAOSpaceFramework, Errors::invalid_state(ERROR_NOT_HAS_PRIVILEGE));
        assert!(!exists<DAORegistry>(@DAOSpaceFramework), Errors::already_published(ERR_ALREADY_INITIALIZED));
        move_to(signer, DAOSpaceSignerCapability{cap});
        move_to(signer, DAORegistry{next_dao_id: 1})
    }

    public(friend) fun get_daospace_signer(): signer acquires DAOSpaceSignerCapability {
        let cap = borrow_global<DAOSpaceSignerCapability>(@DAOSpaceFramework);
        Account::create_signer_with_cap(&cap.cap)
    }

    // This function should call from DAOSpace module
    public(friend) fun register<DAOT>(dao_address: address): u64 acquires DAORegistry, DAOSpaceSignerCapability {
        let daospace_account = get_daospace_signer();
        let dao_id = next_dao_id();
        move_to(&daospace_account, DAORegistryEntry<DAOT>{
            dao_id,
            dao_address,
        });
        dao_id
    }

    fun next_dao_id(): u64 acquires DAORegistry {
        let dao_registry = borrow_global_mut<DAORegistry>(@DAOSpaceFramework);
        let dao_id = dao_registry.next_dao_id;
        dao_registry.next_dao_id = dao_id + 1;
        dao_id
    
    }
  
    public fun dao_address<DAOT>():address acquires DAORegistryEntry{
        *&borrow_global<DAORegistryEntry<DAOT>>(@DAOSpaceFramework).dao_address
    }   

}