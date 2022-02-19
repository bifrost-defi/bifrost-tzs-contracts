import { App } from './app'
import { Tx } from './tx'

const RPC_URL = 'https://rpc.hangzhounet.teztnets.xyz'

const ADDRESS = 'tz1XSbGCvBmVLSE3rMZcTbHubCSamUQZzkK1'

// new App(RPC_URL).getBalance(ADDRESS)

new Tx(RPC_URL).activateAccount()
