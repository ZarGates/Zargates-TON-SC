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
}