import { Address, toNano } from '@ton/core'
import { ZargatesJetton } from '../wrappers/ZargatesJetton'
import { NetworkProvider } from '@ton/blueprint'
import { buildJettonContent } from '../utils/jetton-metadata'

export async function run(provider: NetworkProvider) {
    const jettonMetadata = {
        name: 'ZarGates',
        description: 'ZarGates Jetton',
        symbol: 'ZARGATES',
        image: 'https//:linkToIpfs',
    }
    // const jettonContent = buildJettonContent(jettonMetadata)
    // const ownerAddress = '0QDgP6gx7nT80SCQiLf6FWjn_XA0caN9uXrPhpu58frLsPtc'
    // const zargatesJetton = provider.open(await ZargatesJetton.fromInit(Address.parse(ownerAddress), jettonContent))

    // await zargatesJetton.send(
    //     provider.sender(),
    //     {
    //         value: toNano('0.05'),
    //     },
    //     {
    //         $$type: 'Deploy',
    //         queryId: 0n,
    //     },
    // )

    // const zargatesJettonAddress = zargatesJetton.address

    // await provider.waitForDeploy(zargatesJettonAddress)

    // console.log(`Deployed to: ${zargatesJettonAddress}`)
}
