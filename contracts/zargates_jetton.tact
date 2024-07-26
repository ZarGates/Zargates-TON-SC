import "@stdlib/deploy";
import "./jetton/jetton_wallet";
import "./jetton/jetton_master";

contract ZargatesJetton with JettonMaster, Deployable {
    total_supply: Int as coins = 0;
    mintable: Bool = true;
    owner: Address;
    jetton_content: Cell;
    init(owner: Address, jetton_content: Cell){
        self.owner = owner;
        self.jetton_content = jetton_content;
    }
}