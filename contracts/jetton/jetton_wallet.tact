import "./messages";
struct WalletData {
    balance: Int as coins;
    owner: Address;
    jetton: Address;
    jetton_wallet_code: Cell;
}

contract JettonWallet {
    balance: Int as coins = 0;
    owner: Address;
    jetton_master: Address;
    const gasConsumption: Int = ton("0.01");
    const minTonsForStorage: Int = ton("0.01");
    init(owner: Address, jetton_master: Address){
        self.owner = owner;
        self.jetton_master = jetton_master;
    }

    receive(msg: JettonTransfer){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "JettonWallet: Only owner can transfer jettons");
        require(msg.amount > 0, "JettonWallet: Amount must be greater than zero");
        require(ctx.value > ((2 * ctx.readForwardFee() + 2 * self.gasConsumption) + self.minTonsForStorage),
            "JettonWallet: Value not enough"
        );
        self.balance = (self.balance - msg.amount);
        require(self.balance >= 0, "JettonWallet: Insufficientl balance!");
        let init: StateInit = initOf JettonWallet(msg.destination, self.jetton_master);
        let receiver: Address = contractAddress(init);
        send(SendParameters{
                to: receiver,
                value: 0,
                bounce: true,
                mode: SendRemainingValue,
                body: JettonInternalTransfer{
                    query_id: msg.query_id,
                    amount: msg.amount,
                    response_address: msg.response_destination,
                    from: self.owner,
                    forward_ton_amount: msg.forward_ton_amount,
                    forward_payload: msg.forward_payload
                }.toCell(),
                code: init.code,
                data: init.data
            }
        );
    }

    receive(msg: JettonInternalTransfer){
        let ctx: Context = context();
        require(msg.amount > 0, "JettonWallet: Amount must be greater than zero");
        self.balance = (self.balance + msg.amount);
        if (ctx.sender != self.jetton_master) {
            let init: StateInit = initOf JettonWallet(msg.from, self.jetton_master);
            require(ctx.sender == contractAddress(init), "JettonWallet: Available only for owner or master");
        }
        let storage_fee: Int = (self.minTonsForStorage - min((myBalance() - ctx.value), self.minTonsForStorage));
        let remain: Int = (ctx.value - (storage_fee + self.gasConsumption));
        if (msg.forward_ton_amount > 0) {
            remain = (remain - (ctx.readForwardFee() + msg.forward_ton_amount));
            send(SendParameters{
                    to: self.owner,
                    value: msg.forward_ton_amount,
                    mode: SendPayGasSeparately,
                    bounce: false,
                    body: JettonTransferNotification{
                        query_id: msg.query_id,
                        amount: msg.amount,
                        sender: msg.from,
                        forward_payload: msg.forward_payload
                    }.toCell()
                }
            );
        }
        if (msg.response_address != null && remain > 0) {
            send(SendParameters{
                    to: msg.response_address,
                    value: remain,
                    bounce: false,
                    mode: SendIgnoreErrors,
                    body: JettonExcesses{query_id: msg.query_id}.toCell()
                }
            );
        }
    }

    receive(msg: JettonBurn){
        let ctx: Context = context();
        self.balance = (self.balance - msg.amount);
        require(ctx.sender == self.owner, "JettonWallet: Only owner can burn tokens");
        require(self.balance >= 0, "JettonWallet: Amount to burn exceeds balance");
        send(SendParameters{
                to: self.jetton_master,
                value: 0,
                mode: SendRemainingValue,
                bounce: true,
                body: JettonBurnNotification{
                    query_id: msg.query_id,
                    amount: msg.amount,
                    sender: self.owner,
                    response_destination: msg.response_destination
                }.toCell()
            }
        );
    }

    bounced(src: bounced<JettonInternalTransfer>){
        self.balance = (self.balance + src.amount);
    }

    bounced(src: bounced<JettonBurnNotification>){
        self.balance = (self.balance + src.amount);
    }

    get fun get_wallet_data(): WalletData {
        return
            WalletData{
                balance: self.balance,
                owner: self.owner,
                jetton: self.jetton_master,
                jetton_wallet_code: initOf JettonWallet(self.owner, self.jetton_master).code
            };
    }
}