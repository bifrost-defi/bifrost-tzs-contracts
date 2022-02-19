import { TezosToolkit } from '@taquito/taquito'
import { InMemorySigner } from '@taquito/signer'

const acc = require('./otherAcc.json')

export class Call {
    private tezos: TezosToolkit
    rpcUrl: string

    constructor(rpcUrl: string) {
        this.tezos = new TezosToolkit(rpcUrl)
        this.rpcUrl = rpcUrl

        this.tezos.setSignerProvider(InMemorySigner.fromFundraiser(acc.activation_code, acc.password, acc.mnemonic.join(' ')))
    }

    public add(addN: number, contract: string) {
        this.tezos.contract
            .at(contract)
            .then((contract) => {
                console.log(`Adding ${addN} to storage...`);

                return contract.methods.default(addN).send();
            })
            .then((op) => {
                console.log(`Awaiting for ${op.hash} to be confirmed...`);

                return op.confirmation(1).then(() => op.hash);
            })
            .then((hash) => console.log(`Call done}`))
            .catch((error) => console.log(`Error: ${JSON.stringify(error, null, 2)}`))
    }
}