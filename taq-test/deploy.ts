import { TezosToolkit } from '@taquito/taquito';
import { importKey } from '@taquito/signer';

const provider = 'https://rpc.hangzhounet.teztnets.xyz'

async function deploy() {
    const tezos = new TezosToolkit(provider);

    await importKey(
        tezos,
        "rrnesnob.ihhvbfrl@teztnets.xyz",
        "DBZQStpcfn",
        [
            "attend",
            "must",
            "senior",
            "usage",
            "screen",
            "pelican",
            "defy",
            "slush",
            "behave",
            "dad",
            "fault",
            "rule",
            "village",
            "blue",
            "junior"
        ].join(' '),
        "5718543ca3ccbdcfa0d1a0d5e4eabea4c7ef8cf5",
    )

    try {
        const op = await tezos.contract.originate({
            code: `{ parameter (or (int %decrement) (int %increment)) ;
                storage int ;
                code { UNPAIR ; IF_LEFT { SWAP ; SUB } { ADD } ; NIL operation ; PAIR } }`,
            init: `0`,
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