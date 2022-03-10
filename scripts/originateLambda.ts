import { importKey } from "@taquito/signer";
import { TezosToolkit, VIEW_LAMBDA } from "@taquito/taquito";

require("dotenv").config();

const provider: string = process.env.RPC_URL || "";
const pk: string = process.env.PRIVATE_KEY || "";

async function deploy() {
  const tezos = new TezosToolkit(provider);
  await importKey(tezos, pk);

  const op = await tezos.contract.originate({
    code: VIEW_LAMBDA.code,
    storage: VIEW_LAMBDA.storage,
  });

  const lambdaContract = await op.contract();
  console.log(`LAMBDA_VIEW=${lambdaContract.address}`);
}

deploy();
