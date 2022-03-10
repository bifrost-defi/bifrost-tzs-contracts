import { TezosToolkit, MichelsonMap } from "@taquito/taquito";
import { importKey } from "@taquito/signer";

require("dotenv").config();

const provider: string = process.env.RPC_URL || "";
const owner: string = process.env.OWNER || "";
const pk: string = process.env.PRIVATE_KEY || "";
const lambda = process.env.LAMBDA_VIEW || undefined;

const args = require("minimist")(process.argv.slice(2));

async function mint() {
  const tezos = new TezosToolkit(provider);
  await importKey(tezos, pk);

  const at: string = args["at"] || "";

  try {
    let contract = await tezos.contract.at(at);
    let balance = await contract.views.getBalance(owner).read(lambda);

    console.log(`Balance: ${balance}`);
  } catch (error) {
    console.error(error);
  }
}

mint();
