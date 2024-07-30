import "@stdlib/deploy";
import "@stdlib/ownable";
import "./zargates_jetton_messages";
import "./jetton/jetton_wallet";
import "./jetton/jetton_master";

contract ZargatesJetton with JettonMaster, Deployable, OwnableTransferable {
    const DAILY_MINT: Int = ton("1280");
    const ONE_DAY: Int = 86400;
    total_supply: Int as coins = 0;
    mintable: Bool;
    owner: Address;
    jetton_content: Cell;
    is_initialized: Bool;
    start_time: Int = 0;
    halvings: map<Int, Int>;
    halvings_length: Int as uint8 = 0;
    currently_minted: Int = 0;
    receiver_address: Address = null;
    init(owner: Address, jetton_content: Cell){
        self.owner = owner;
        self.jetton_content = jetton_content;
        self.mintable = false;
        self.is_initialized = false;
    }

    receive("Mint"){
        self.mint();
    }

    receive(msg: Mint){
        self.mint();
    }

    receive(msg: InitMint){
        self.initMint(msg.init_mint_data);
    }

    receive(msg: SetReceiverAddress){
        self.setReceiverAddress(msg.new_receiver_address);
    }

    fun initMint(init_data: InitMintData) {
        let ctx: Context = context();
        self.requireOwner();
        require(!(self.is_initialized), "ZargatesJetton: Already initialized!");
        require(init_data.start_time >= now(), "ZargatesJetton: Start time must be later than now");
        require(init_data.first_halving_timestamp >= init_data.start_time,
            "ZargatesJetton: First halving must be after start time"
        );
        require(init_data.second_halving_timestamp >= init_data.first_halving_timestamp,
            "ZargatesJetton: Second halving must be after first halving"
        );
        require(init_data.third_halving_timestamp >= init_data.second_halving_timestamp,
            "ZargatesJetton: Third halving must be after second halving"
        );
        require(init_data.fourth_halving_timestamp >= init_data.third_halving_timestamp,
            "ZargatesJetton: Fourth halving must be after third halving"
        );
        require(init_data.end_of_emission_timestamp >= init_data.fourth_halving_timestamp,
            "ZargatesJetton: End of emission must be after fourth halving"
        );
        self.receiver_address = init_data.receiver_address;
        self.start_time = init_data.start_time;
        self._halvingsPush(init_data.first_halving_timestamp);
        self._halvingsPush(init_data.second_halving_timestamp);
        self._halvingsPush(init_data.third_halving_timestamp);
        self._halvingsPush(init_data.fourth_halving_timestamp);
        self._halvingsPush(init_data.end_of_emission_timestamp);
        self.mintable = true;
        self.is_initialized = true;
    }

    fun mint() {
        require(self.mintable, "ZargatesJetton: Mint disabled");
        let mint_available: Int = self._calculateMintAvailable();
        self.currently_minted = (self.currently_minted + mint_available);
        self._mint(mint_available);
    }

    fun setReceiverAddress(new_receiver_address: Address) {
        self.requireOwner();
        self.receiver_address = new_receiver_address;
    }

    fun _mint(mint_amount: Int) {
        let ctx: Context = context();
        let _init_code: StateInit = initOf JettonWallet(self.receiver_address, myAddress());
        self.total_supply = (self.total_supply + mint_amount);
        send(SendParameters{
                to: contractAddress(_init_code),
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
                code: _init_code.code,
                data: _init_code.data
            }
        );
    }

    fun _calculateMintAvailable(): Int {
        let _mint_available: Int = 0;
        let _daily_mint: Int = self.DAILY_MINT;
        let _days_left: Int = (now() - self.start_time) / self.ONE_DAY;
        let _last_halving: Int = self.start_time;
        let i: Int = 0;
        while (i < self.halvings_length) {
            if(now() >= self.halvings.get(i)!!) {
                let _days_in_halving: Int = ((self.halvings.get(i)!! - _last_halving) / self.ONE_DAY);
                _mint_available = (_mint_available + (_days_in_halving * _daily_mint));
                _last_halving = self.halvings.get(i)!!;
                _daily_mint = i == self.halvings_length - 1 ? 0 : _daily_mint / 2;
                _days_left = _days_left - _days_in_halving;
            }
            i = (i + 1);
        }
        _mint_available = (_mint_available + _days_left * _daily_mint);
        _mint_available = (_mint_available - self.currently_minted);
        return _mint_available;
    }

    fun _halvingsPush(_halving_timestamp_to_push: Int) {
        self.halvings.set(self.halvings_length, _halving_timestamp_to_push);
        self.halvings_length = (self.halvings_length + 1);
    }

    get fun available_mint(): Int {
        return self._calculateMintAvailable();
    }

    get fun halvings(): HalvingsData {
        return
            HalvingsData{
                start_time: self.start_time,
                first_halving_timestamp: self.halvings.get(0)!!,
                second_halving_timestamp: self.halvings.get(1)!!,
                third_halving_timestamp: self.halvings.get(2)!!,
                fourth_halving_timestamp: self.halvings.get(3)!!,
                end_of_emission_timestamp: self.halvings.get(4)!!
            };
    }

    get fun currently_minted(): Int {
        return self.currently_minted;
    }

    get fun receiver(): Address {
        return self.receiver_address;
    }

    get fun daily_mint(): Int {
        return self.DAILY_MINT;
    }
}