struct InitMintData {
    receiver_address: Address;
    start_time: Int;
    first_halving_timestamp: Int;
    second_halving_timestamp: Int;
    third_halving_timestamp: Int;
    fourth_halving_timestamp: Int;
    end_of_emission_timestamp: Int;
}
struct HalvingsData {
    start_time: Int;
    first_halving_timestamp: Int;
    second_halving_timestamp: Int;
    third_halving_timestamp: Int;
    fourth_halving_timestamp: Int;
    end_of_emission_timestamp: Int;
}
message Mint {
}
message InitMint {
    init_mint_data: InitMintData;
}
message SetReceiverAddress {
    new_receiver_address: Address;
}