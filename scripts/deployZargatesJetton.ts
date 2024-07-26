import { toNano } from '@ton/core';
import { ZargatesJetton } from '../wrappers/ZargatesJetton';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const zargatesJetton = provider.open(await ZargatesJetton.fromInit());

    await zargatesJetton.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        },
    );

    const zargatesJettonAddress = zargatesJetton.address;

    await provider.waitForDeploy(zargatesJettonAddress);

    console.log(`Deployed to: ${zargatesJettonAddress}`);
}
