import "@stdlib/deploy";
import "./jetton/jetton_wallet";
import "./jetton/jetton_master";

contract ZargatesJetton with JettonMaster, Deployable {
    total_supply: Int as coins = 0;
    mintable: Bool = true;
    owner: Address;
    jetton_content: Cell;
    receiver_address: Address; // address that receive all new minted jettons
    init(owner: Address, jetton_content: Cell, receiver_address: Address){
        self.owner = owner;
        self.jetton_content = jetton_content;
        self.receiver_address = receiver_address; // sholed be setter function for it, use ownable trait
    }

    // make it callable by text message! as comment 
    // mint amount should be in coins , for ex = ton("1")
    // here should be functions to calculate instead arg mint_amount
    fun _mint(mint_amount: Int) {
        let ctx: Context = context();
        require(self.mintable, "ZargatesJetton: Mint disabled");
        let initCode: StateInit = initOf JettonWallet(self.receiver_address, myAddress());
        self.total_supply = (self.total_supply + mint_amount);
        send(SendParameters{
                to: contractAddress(initCode),
                value: 0,
                bounce: true,
                mode: SendRemainingValue,
                body: JettonInternalTransfer{
                    query_id: 0,
                    amount: mint_amount,
                    response_address: ctx.sender,
                    from: myAddress(),
                    forward_ton_amount: 0,
                    forward_payload: emptySlice()
                }.toCell(),
                code: initCode.code,
                data: initCode.data
            }
        );
    }
}