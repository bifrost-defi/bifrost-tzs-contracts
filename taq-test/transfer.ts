import { token_transfer } from './token-transfer'

const RPC_URL = 'https://rpc.hangzhounet.teztnets.xyz'
const CONTRACT = 'KT1BYsJhsinY1pmBW7pPZWeWEHy3CwP8vrZc' //адрес опубликованного контракта
const SENDER = 'tz1gDNe8ZTqSJvoJWRdMjKRPU5zMgyBJ6L9M' //публичный адрес отправителя — возьмите его из acc.json
const RECEIVER = 'tz1PgvXsXe96YdqGQRDdoWEeUVhT7V7nrhtg' //публичный адрес получателя — возьмите его из кошелька Tezos, который вы создали
const AMOUNT = 3 //количество токенов для отправки. Можете ввести другое число
new token_transfer(RPC_URL).transfer(CONTRACT, SENDER, RECEIVER, AMOUNT)