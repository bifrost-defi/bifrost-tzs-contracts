import { TezosToolkit } from "@taquito/taquito";
import { importKey } from "@taquito/signer";

require("dotenv").config();

const provider: string = process.env.RPC_URL || "";
const pk: string = process.env.PRIVATE_KEY || "";

const args = require("minimist")(process.argv.slice(2));

async function burn() {
  const tezos = new TezosToolkit(provider);
  await importKey(tezos, pk);

  const at: string = args["at"] || "";
  const amount: string = args["amount"] || "";
  const destination: string = args["dst"] || "";

  try {
    let contract = await tezos.contract.at(at);
    let op = await contract.methods.burn(amount, destination).send();

    console.log(`Waiting for ${op.hash} to be confirmed...`);

    await op.confirmation(1);

    console.log("Done");
  } catch (error) {
    console.error(error);
  }
}

burn();
