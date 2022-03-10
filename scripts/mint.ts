import { TezosToolkit, MichelsonMap } from "@taquito/taquito";
import { importKey } from "@taquito/signer";

require("dotenv").config();

const provider: string = process.env.RPC_URL || "";
const owner: string = process.env.OWNER || "";
const pk: string = process.env.PRIVATE_KEY || "";

const args = require("minimist")(process.argv.slice(2));

async function mint() {
  const tezos = new TezosToolkit(provider);
  await importKey(tezos, pk);

  const at: string = args["at"] || "";
  const amount: string = args["amount"] || "";

  try {
    let contract = await tezos.contract.at(at);
    let op = await contract.methods.mint(amount).send();

    console.log(`Waiting for ${op.hash} to be confirmed...`);

    await op.confirmation(1);

    console.log("Done");
  } catch (error) {
    console.error(error);
  }
}

mint();
