import { TezosToolkit } from '@taquito/taquito'
import { InMemorySigner } from '@taquito/signer'

const acc = require('./acc.json')

export class Tx {
    private tezos: TezosToolkit
    rpcUrl: string

    constructor(rpcUrl: string) {
        this.tezos = new TezosToolkit(rpcUrl)
        this.rpcUrl = rpcUrl

        this.tezos.setSignerProvider(InMemorySigner.fromFundraiser(acc.activation_code, acc.password, acc.mnemonic.join(' ')))
    }

    public async activateAccount() {
        const { pkh, activation_code} = acc
        try {
            const operation = await this.tezos.tz.activate(pkh, activation_code)
            await operation.confirmation()
        } catch(e) {
            console.log(e)
        }
    }

    public async main() {}
}

