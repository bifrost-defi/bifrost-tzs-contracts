# The Bifrost ligo contracts

_WARNING: Bridge is still under development. Do not send your assets to any of the addresses_

The Bifrost bridge allows you to swap assets across blockchains. In the first phase, the swap is based on the wrapped assets.

## Contracts for other networks:

- [EVM-based](https://github.com/bifrost-defi/bifrost-solidity-contracts)
- [TON](https://github.com/bifrost-defi/bifrost-ton-contracts)

## Deploy to sandbox

Run sandbox:

```
$ docker run --rm --name my-sandbox --detach -p 20000:20000 \
       tqtezos/flextesa:20210930 granabox start
```

Install dependencies:

```
$ npm i
```

Fill environment variables inside `.env`:

```
RPC_URL=
PRIVATE_KEY=
```

Originate lambda view contract:

```
$ make originate.lambda
```

Compile:

```
$ make compile.tz
```

Originate tokens:

```
$ make originate.beth
$ make originate.bton
```

Run scripts:

```
$ ts-node scripts/<SCRIPT_NAME>.ts --at=<CONTRACT_ADDRESS> [--meta, --amount, --dst]
```

### Available scripts for playing around:

burn (burns tokens and stores information about burning).

```
$ ts-node scripts/burn.ts --at=<CONTRACT_ADDRESS> --amount=<AMOUNT> --dst=<AVALANCHE_ADDRESS>
```

getBalance (shows token balance).

```
$ ts-node scripts/getBalance.ts --at=<CONTRACT_ADDRESS>
```

getMetadata (shows token metadata).

```
$ ts-node scripts/getMetadata.ts --at=<CONTRACT_ADDRESS>
```

mint (mints token).

```
$ ts-node scripts/mint.ts --at=<CONTRACT_ADDRESS> --amount=<AMOUNT>
```

originate token (originates token contract with metadata).

```
$ ts-node scripts/originateToken.ts --meta=<METADATA_URL_BYTES>
```

originateLambda (originate lambda view contract and outputs its address).

```
$ ts-node scripts/originateLambda.ts
```
