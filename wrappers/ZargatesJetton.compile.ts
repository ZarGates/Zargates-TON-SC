import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/zargates_jetton.tact',
    options: {
        debug: true,
    },
};
