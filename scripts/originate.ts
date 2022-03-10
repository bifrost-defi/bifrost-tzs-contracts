import { TezosToolkit, MichelsonMap } from "@taquito/taquito";
import { importKey } from "@taquito/signer";
import fs from "fs";

require("dotenv").config();

const provider: string = process.env.RPC_URL || "";
const owner: string = process.env.OWNER || "";
const pk: string = process.env.PRIVATE_KEY || "";

const args = require("minimist")(process.argv.slice(2));

async function deploy() {
  const tezos = new TezosToolkit(provider);

  await importKey(tezos, pk);

  if (!args["meta"] || args["meta"] === "") {
    console.error("invalid metadata link bytes");
    return;
  }

  const metadata = new MichelsonMap();
  metadata.set("", args["meta"]);

  try {
    const op = await tezos.contract.originate({
      code: fs.readFileSync("../build/contract.tz").toString(),
      storage: {
        owner: owner,
        totalSupply: "0",
        ledger: new MichelsonMap(),
        metadata: metadata,
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
