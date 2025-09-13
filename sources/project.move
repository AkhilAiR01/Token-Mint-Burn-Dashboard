module MyModule::TokenDashboard {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing the token dashboard state
    struct Dashboard has store, key {
        total_minted: u64,     // Total tokens minted
        total_burned: u64,     // Total tokens burned
        current_supply: u64,   // Current circulating supply
        owner: address,        // Dashboard owner address
    }

    /// Function to initialize the token dashboard
    public fun initialize_dashboard(owner: &signer) {
        let dashboard = Dashboard {
            total_minted: 0,
            total_burned: 0,
            current_supply: 0,
            owner: signer::address_of(owner),
        };
        move_to(owner, dashboard);
    }

    /// Function to mint tokens to a specified address
    public fun mint_tokens(
        dashboard_owner: &signer, 
        recipient: address, 
        amount: u64
    ) acquires Dashboard {
        let dashboard = borrow_global_mut<Dashboard>(signer::address_of(dashboard_owner));
        
        // Only dashboard owner can mint tokens
        assert!(dashboard.owner == signer::address_of(dashboard_owner), 1);
        
        // Create new coins and deposit to recipient
        let minted_coins = coin::withdraw<AptosCoin>(dashboard_owner, amount);
        coin::deposit<AptosCoin>(recipient, minted_coins);
        
        // Update dashboard statistics
        dashboard.total_minted = dashboard.total_minted + amount;
        dashboard.current_supply = dashboard.current_supply + amount;
    }

    /// Function to burn tokens from the caller's account
    public fun burn_tokens(
        user: &signer, 
        dashboard_owner: address, 
        amount: u64
    ) acquires Dashboard {
        let dashboard = borrow_global_mut<Dashboard>(dashboard_owner);
        
        // Withdraw tokens from user and effectively burn them
        let burned_coins = coin::withdraw<AptosCoin>(user, amount);
        coin::destroy_zero(burned_coins);
        
        // Update dashboard statistics
        dashboard.total_burned = dashboard.total_burned + amount;
        dashboard.current_supply = dashboard.current_supply - amount;
    }
}