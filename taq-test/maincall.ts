import { Call } from './call'

const RPC_URL = 'https://rpc.hangzhounet.teztnets.xyz'

const CONTRACT = 'KT1F1aDsA6AoeW1zCaV2taEDzNVPuPHFYdsn' 

const ADD = 5

new Call(RPC_URL).add(ADD, CONTRACT)