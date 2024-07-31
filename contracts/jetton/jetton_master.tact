import "./jetton_wallet";
struct JettonData {
    total_supply: Int as coins;
    mintable: Bool;
    admin_address: Address;
    jetton_content: Cell;
    jetton_wallet_code: Cell;
}
trait JettonMaster {
    total_supply: Int;
    mintable: Bool;
    owner: Address;
    jetton_content: Cell;

    //////////////////////////////////////
    /////          MESSAGES          /////
    //////////////////////////////////////

    //
    /// @notice Handles incoming JettonBurnNotification messages;
    /// @notice Ensures only the associated JettonWallet can send burn notifications;
    /// @notice Updates the total supply of the jetton;
    ///
    /// @param msg - The JettonBurnNotification message containing burn details;

    receive(msg: JettonBurnNotification){
        let ctx: Context = context();
        require(ctx.sender == contractAddress(initOf JettonWallet(msg.sender, myAddress())),
            "JettonMaster: Only JettonWallet"
        );
        self.total_supply = (self.total_supply - msg.amount);
        if (msg.response_destination != null) {
            send(SendParameters{
                    to: msg.response_destination,
                    value: 0,
                    bounce: false,
                    mode: (SendRemainingValue + SendIgnoreErrors)
                }
            );
        }
    }

    //////////////////////////////////////
    /////          GETTERS           /////
    //////////////////////////////////////

    //
    /// @notice Retrieves the jetton data;
    ///
    /// @return JettonData - Struct containing the jetton data;

    get fun get_jetton_data(): JettonData {
        return
            JettonData{
                total_supply: self.total_supply,
                mintable: self.mintable,
                admin_address: self.owner,
                jetton_content: self.jetton_content,
                jetton_wallet_code: initOf JettonWallet(myAddress(), myAddress()).code
            };
    }

    //
    /// @notice Retrieves the wallet address for a given owner address;
    ///
    /// @param owner_address - The address of the wallet owner;
    ///
    /// @return Address - The address of the associated JettonWallet;

    get fun get_wallet_address(owner_address: Address): Address {
        return contractAddress(initOf JettonWallet(owner_address, myAddress()));
    }
}