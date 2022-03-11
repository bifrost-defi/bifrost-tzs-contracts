import { TezosToolkit, MichelsonMap } from "@taquito/taquito";
import { importKey } from "@taquito/signer";
import { Tzip16Module, tzip16 } from "@taquito/tzip16";

require("dotenv").config();

const provider: string = process.env.RPC_URL || "";
const pk: string = process.env.PRIVATE_KEY || "";

const args = require("minimist")(process.argv.slice(2));

async function burn() {
  const tezos = new TezosToolkit(provider);
  await importKey(tezos, pk);

  tezos.addExtension(new Tzip16Module());

  const at: string = args["at"] || "";

  try {
    let contract = await tezos.contract.at(at, tzip16);
    let metadata = await contract.tzip16().getMetadata();

    console.log(JSON.stringify(metadata, null, 2));
  } catch (error) {
    console.error(error);
  }
}

burn();
