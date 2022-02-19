import { App } from './get_balance'
import { token_transfer } from './transfer'

const RPC_URL = 'https://rpc.hangzhounet.teztnets.xyz'

const ADDRESS = 'tz1XSbGCvBmVLSE3rMZcTbHubCSamUQZzkK1'
// new App(RPC_URL).getBalance(ADDRESS)

const CONTRACT = 'KT1BYsJhsinY1pmBW7pPZWeWEHy3CwP8vrZc' // contract address
const SENDER = 'tz1gDNe8ZTqSJvoJWRdMjKRPU5zMgyBJ6L9M'
const RECEIVER = 'tz1PgvXsXe96YdqGQRDdoWEeUVhT7V7nrhtg'
const AMOUNT = 3 
new token_transfer(RPC_URL).transfer(CONTRACT, SENDER, RECEIVER, AMOUNT)