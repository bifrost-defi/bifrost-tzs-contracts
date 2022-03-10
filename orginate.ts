import { TezosToolkit, MichelsonMap } from "@taquito/taquito";
import { importKey } from "@taquito/signer";
import fs from "fs";

require("dotenv").config();

const provider: string = process.env.RPC_URL || "";
const pk: string = process.env.PRIVATE_KEY || "";

async function deploy() {
  const tezos = new TezosToolkit(provider);

  await importKey(tezos, pk);

  try {
    const op = await tezos.contract.originate({
      code: fs.readFileSync("./build/contract.tz").toString(),
      storage: {
        owner: process.env.OWNER,
        totalSupply: "0",
        ledger: new MichelsonMap(),
        metadata: new MichelsonMap(),
        burnings: new MichelsonMap(),
      },
    });

    console.log("Awaiting confirmation...");
    const contract = await op.contract();

    console.log("Address", contract.address);
    console.log("Gas Used", op.consumedGas);
    console.log("Storage", await contract.storage());

    console.log("Operation hash:", op.hash);
  } catch (ex) {
    console.error(ex);
  }
}

deploy();
