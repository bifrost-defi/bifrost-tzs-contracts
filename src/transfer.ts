import { TezosToolkit } from '@taquito/taquito'
import { InMemorySigner } from '@taquito/signer'

const acc = require('./acc.json')

export class token_transfer {
  private tezos: TezosToolkit
  rpcUrl: string

  constructor(rpcUrl: string) {
    this.tezos = new TezosToolkit(rpcUrl)
    this.rpcUrl = rpcUrl

    this.tezos.setSignerProvider(InMemorySigner.fromFundraiser(acc.email, acc.password, acc.mnemonic.join(' ')))
  }

  public transfer(contract: string, sender: string, receiver: string, amount: number) {
    this.tezos.contract
      .at(contract)
      .then((contract) => {
        console.log(`Sending ${amount} from ${sender} to ${receiver}...`)
        
        return contract.methods.transfer(sender, receiver, amount).send()
      })
      .then((op) => {
        console.log(`Awaiting for ${op.hash} to be confirmed...`)
        return op.confirmation(1).then(() => op.hash)
      })
      .then((hash) => console.log(`Hash: ${hash}`)) 
      .catch((error) => console.log(`Error: ${JSON.stringify(error, null, 2)}`))
  }
}