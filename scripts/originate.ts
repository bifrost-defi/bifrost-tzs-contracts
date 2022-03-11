import { TezosToolkit, MichelsonMap } from "@taquito/taquito";
import { importKey } from "@taquito/signer";
import fs from "fs";

require("dotenv").config();

const provider: string = process.env.RPC_URL || "";
const pk: string = process.env.PRIVATE_KEY || "";

const args = require("minimist")(process.argv.slice(2));

async function deploy() {
  const tezos = new TezosToolkit(provider);

  await importKey(tezos, pk);
  const owner = await tezos.signer.publicKeyHash();

  if (!args["meta"] || args["meta"] === "") {
    console.error("invalid metadata link bytes");
    return;
  }

  const token_id = 1;
  const token_info = new MichelsonMap();
  token_info.set("", args["meta"]);

  const metadata = new MichelsonMap();
  metadata.set("1", {
    token_id,
    token_info,
  });

  try {
    const op = await tezos.contract.originate({
      code: fs.readFileSync("./build/contract.tz").toString(),
      storage: {
        owner: owner,
        totalSupply: "0",
        ledger: new MichelsonMap(),
        burnings: new MichelsonMap(),
        token_metadata: metadata,
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
