import { TezosToolkit, MichelsonMap } from "@taquito/taquito";
import { importKey } from "@taquito/signer";

require("dotenv").config();

import contractJSON from "../build/contract.json";

const provider = "http://127.0.0.1:20000";

async function deploy() {
  const tezos = new TezosToolkit(provider);

  await importKey(tezos, process.env.PRIVATE_KEY);

  try {
    const op = await tezos.contract.originate({
      code: contractJSON,
      storage: {
        owner: process.env.OWNER,
        supply: 0,
        ledger: new MichelsonMap(),
        metadata: new MichelsonMap(),
        burnings: new MichelsonMap(),
      },
    });

    console.log("Awaiting confirmation...");
    const contract = await op.contract();

    console.log("Gas Used", op.consumedGas);
    console.log("Storage", await contract.storage());

    console.log("Operation hash:", op.hash);
  } catch (ex) {
    console.error(ex);
  }
}

deploy();
