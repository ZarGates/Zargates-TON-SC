import { Address, toNano } from '@ton/core'
import { ZargatesJetton } from '../wrappers/ZargatesJetton'
import { NetworkProvider } from '@ton/blueprint'
import { buildJettonContent } from '../utils/jetton-metadata'

export async function run(provider: NetworkProvider) {
    const deployer = provider.sender()

    const jettonMetadata = {
        name: 'ZarGates Jetton',
        description: 'Description of ZarGates Jetton',
        symbol: 'ZARGATES',
        image: 'https://linkToIpfsWithCID',
    }
    const jettonContent = buildJettonContent(jettonMetadata)
    const zargatesJetton = provider.open(await ZargatesJetton.fromInit(deployer.address!, jettonContent))

    await zargatesJetton.send(
        provider.sender(),
        {
            value: toNano('0.5'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        },
    )

    const zargatesJettonAddress = zargatesJetton.address

    await provider.waitForDeploy(zargatesJettonAddress)

    console.log(`ZarGates Jetton deployed to: ${zargatesJettonAddress}`)

    await zargatesJetton.send(
        provider.sender(),
        {
            value: toNano('0.5'),
        },
        {
            $$type: 'InitMint',
            init_mint_data: {
                $$type: 'InitMintData',
                receiver_address: deployer.address!,
                start_time: 1234n,
                first_halving_timestamp: 1234n,
                second_halving_timestamp: 1234n,
                third_halving_timestamp: 1234n,
                fourth_halving_timestamp: 1234n,
                end_of_emission_timestamp: 1234n,
            },
        },
    )

    const halvings = await zargatesJetton.getHalvings()
    const receiverAddress = await zargatesJetton.getReceiver()

    console.log('Mint intialized!')
    console.log(`Halvings set to: ${halvings}`)
    console.log(`Receiver address set to: ${receiverAddress}`)
}
