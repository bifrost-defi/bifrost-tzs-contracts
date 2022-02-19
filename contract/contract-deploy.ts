import { TezosToolkit } from '@taquito/taquito';
import { importKey } from '@taquito/signer';

const fs = require('fs')
const { Tezos } = require('@taquito/taquito')

const provider = 'https://rpc.hangzhounet.teztnets.xyz'

async function deploy() {
    const tezos = new TezosToolkit(provider);

    await importKey(
        tezos,
        "gfzfxtie.mjdfvugb@teztnets.xyz",
        "neXAugwgg6",
        [
          "trumpet",
          "tissue",
          "inhale",
          "elephant",
          "cart",
          "arrange",
          "toy",
          "section",
          "hedgehog",
          "write",
          "shallow",
          "galaxy",
          "satisfy",
          "fork",
          "asthma"
        ].join(' '),
        "4bd66e7c7f23467acf15367ac4a1e45d184da13e",
    )

    try {
      const op = await tezos.contract.originate({
        code: JSON.parse(fs.readFileSync("./contract.json").toString()),
        init:
            '(Pair { Elt "tz1gDNe8ZTqSJvoJWRdMjKRPU5zMgyBJ6L9M" (Pair { Elt "tz1gDNe8ZTqSJvoJWRdMjKRPU5zMgyBJ6L9M" 0 } 0) } 0)',
      })

        console.log('Awaiting confirmation...')
        const contract = await op.contract()

        console.log('Gas Used', op.consumedGas)
        console.log('Storage', await contract.storage())

        console.log('Operation hash:', op.hash)
    } catch (ex) {
        console.error(ex)
      }
}

deploy();