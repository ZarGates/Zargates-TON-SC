import { Address, toNano } from '@ton/core'
import { ZargatesJetton } from '../wrappers/ZargatesJetton'
import { NetworkProvider } from '@ton/blueprint'

export async function run(provider: NetworkProvider, args: string[]) {
    const ui = provider.ui()

    const address = Address.parse(args.length > 0 ? args[0] : await ui.input('ZargatesJetton address'))

    if (!(await provider.isContractDeployed(address))) {
        ui.write(`Error: Contract at address ${address} is not deployed!`)
        return
    }

    const zargatesJetton = provider.open(ZargatesJetton.fromAddress(address))

    await zargatesJetton.send(
        provider.sender(),
        {
            value: toNano('0.5'),
        },
        {
            $$type: 'InitMint',
            init_mint_data: {
                $$type: 'InitMintData',
                receiver_address: Address.parse(''),
                start_time: 1234n,
                first_halving_timestamp: 1234n,
                second_halving_timestamp: 1234n,
                third_halving_timestamp: 1234n,
                fourth_halving_timestamp: 1234n,
                end_of_emission_timestamp: 1234n,
            },
        },
    )

    ui.write('Waiting for initializing mint...')

    let halvings = await zargatesJetton.getHalvings()

    const receiverAddress = await zargatesJetton.getReceiver()

    ui.clearActionPrompt()
    ui.write('Mint initialized successfully!')
    ui.write(`Halvings set to: ${halvings}`)
    ui.write(`Receiver address set to: ${receiverAddress}`)
}
