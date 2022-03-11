import { TezosToolkit, MichelsonMap } from "@taquito/taquito";
import { importKey } from "@taquito/signer";
import { Tzip12Module, tzip12 } from "@taquito/tzip12";

require("dotenv").config();

const provider: string = process.env.RPC_URL || "";
const pk: string = process.env.PRIVATE_KEY || "";

const args = require("minimist")(process.argv.slice(2));

async function burn() {
  const tezos = new TezosToolkit(provider);
  await importKey(tezos, pk);

  tezos.addExtension(new Tzip12Module());

  const at: string = args["at"] || "";

  try {
    let contract = await tezos.contract.at(at, tzip12);
    let metadata = await contract.tzip12().getTokenMetadata(1);

    console.log(JSON.stringify(metadata, null, 2));
  } catch (error) {
    console.error(error);
  }
}

burn();
