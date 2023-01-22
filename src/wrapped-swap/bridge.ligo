type amt is nat;

type lockEvent is record [
  user : address;
  amount : tez;
  destAddress : string;
  destCoinId : int;
  ts : timestamp;
]

type burnEvent is record [
  user : address;
  amount : amt;
  destAddress : string;
  destCoinId : int;
  ts : timestamp;
]

type storage is record [
  owner : address;
  oracles : big_map (address, bool);
  lockEvents : big_map (address, lockEvent);
  burnEvents : big_map (address, burnEvent);
]

type return is list (operation) * storage

const noOperations : list (operation) = nil;

type lockParams is michelson_pair (string, "destAddress", int, "destCoinId")
type unlockParams is michelson_pair (address, "user", nat, "amount")

type entryAction is
  | Lock of lockParams
  | Unlock of unlockParams

function lock (const destAddress : string; const destCoinId : int; var s : storage) : return is {
  s.lockEvents[Tezos.sender] := record [
    user = Tezos.sender;
    amount = Tezos.amount;
    destAddress = destAddress;
    destCoinId = destCoinId;
    ts = Tezos.now;
  ];
} with (noOperations, s)

function unlock (const user : address; const amount : nat; var s : storage) : return is {
  const is_oracle : bool = case s.oracles[Tezos.sender] of [
      Some (is_oracle) -> is_oracle
    | None -> False
  ];

  if not is_oracle then 
    failwith ("Only oracle can unlock");

  const destination : contract (unit) =
      case (Tezos.get_contract_opt (user) : option (contract (unit))) of [
        Some (contract) -> contract
      | None -> (failwith ("Wallet not found") : contract (unit))
  ];

  const op : operation = Tezos.transaction (unit, amount, destination);
} with (list [op], s)

function main (const action : entryAction; var s : storage) : return is
  case action of [
    | Lock (params) -> lock (params.0, params.1, s)
    | Unlock (params) -> unlock (params.0, params.1, s)
  ]