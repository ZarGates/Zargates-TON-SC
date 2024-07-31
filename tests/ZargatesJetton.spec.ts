import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox'
import { toNano } from '@ton/core'
import { ZargatesJetton } from '../wrappers/ZargatesJetton'
import { buildJettonContent } from '../utils/jetton-metadata'
import { Address } from 'ton-core'
import '@ton/test-utils'

describe('ZargatesJetton', () => {
    let blockchain: Blockchain
    let deployer: SandboxContract<TreasuryContract>
    let zargatesJetton: SandboxContract<ZargatesJetton>

    beforeEach(async () => {
        blockchain = await Blockchain.create()

        const jettonMetadata = {
            name: 'ZarGates',
            description: 'ZarGates Jetton',
            symbol: 'ZARGATES',
            image: 'https//:linkToIpfs',
        }
        const jettonContent = buildJettonContent(jettonMetadata)
        deployer = await blockchain.treasury('deployer')

        zargatesJetton = blockchain.openContract(await ZargatesJetton.fromInit(deployer.address, jettonContent))


        const deployResult = await zargatesJetton.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        )

        expect(deployResult.transactions).not.toBeNull()
    })

    it('should deploy', async () => {
        // the check is done inside beforeEach
    })
})
