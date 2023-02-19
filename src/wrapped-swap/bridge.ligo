type amt is nat;
type coinId is int;

type lockEvent is record [
  user : address;
  amount : tez;
  destAddress : string;
  destCoinId : coinId;
  ts : timestamp;
]

type burnEvent is record [
  user : address;
  amount : amt;
  destAddress : string;
  destCoinId : coinId;
  ts : timestamp;
]

type storage is record [
  owner : address;
  oracles : map (address, bool);
  tokens : map (coinId, address); 
]

type event is
  | LockEvent of lockEvent
  | BurnEvent of burnEvent

type return is list (operation) * storage

const noOperations : list (operation) = nil;

type lockParams is michelson_pair (coinId, "destCoinId", string, "destAddress")
type unlockParams is michelson_pair (address, "to_", nat, "value")
type mintParams is michelson_pair (coinId, "destCoinId", michelson_pair (address, "to_", nat, "value"), "")
type burnParams is michelson_pair (coinId, "destCoinId", michelson_pair (string, "destAddress", nat, "value"), "")
type addTokenParams is michelson_pair (coinId, "coinId", address, "tokenAddress")

type entryAction is
  | Lock of lockParams
  | Unlock of unlockParams
  | Mint of mintParams
  | Burn of burnParams
  | AddToken of addTokenParams

type tokenMintParams is michelson_pair(address, "to_", amt, "value")
type tokenBurnParams is michelson_pair(address, "from_", amt, "value")

type tokenAction is 
  | Mint of tokenMintParams
  | Burn of tokenBurnParams

(* `sentByOracle` returns true if sender is oracle, false otherwise *)
[@inline] function sentByOracle (const s : storage) : bool is case s.oracles[Tezos.get_sender ()] of [
      Some (is_oracle) -> is_oracle
    | None -> False
  ];

(* `lock` locks sent amount of tzs and emits event with information for the oracle. 
It starts the process of swapping and can be called by any user. *)
function lock (const destCoinId : coinId; const destAddress : string; var s : storage) : return is {
  if Tezos.get_amount () = 0tez then
    failwith ("Amount must be greater than 0");

  const op : operation = Tezos.emit ("%lock", LockEvent(record [
    user = Tezos.get_sender ();
    amount = Tezos.get_amount ();
    destAddress = destAddress;
    destCoinId = destCoinId;
    ts = Tezos.get_now ();
  ]));
} with (list [op], s)

(* `unlock` transfers amount of tzs to the specified `to_` address.
It can be called only by an oracle. *)
function unlock (const to_ : address; const value : nat; var s : storage) : return is {
  if not sentByOracle(s) then 
    failwith ("Only oracle can unlock");

  const destination : contract (unit) =
      case (Tezos.get_contract_opt (to_) : option (contract (unit))) of [
        Some (contract) -> contract
      | None -> (failwith ("Wallet not found") : contract (unit))
  ];

  const op : operation = Tezos.transaction (unit, value * 1mutez, destination);
} with (list [op], s)

(* `mint` calls minting operation on the token contract associated with `destCoinId` coin. 
It can be called only by an oracle. *)
function mint (const destCoinId : coinId; const to_ : address; const value : nat; var s : storage) : return is {
  if not sentByOracle(s) then 
    failwith ("Only oracle can mint");

  const tokenAddress = case s.tokens[destCoinId] of [
    Some (address) -> address
    | None -> failwith("Coin ID not found")
  ];

  const token : contract (tokenAction) = 
  case (Tezos.get_contract_opt(tokenAddress) : option (contract (tokenAction))) of [
    Some (contract) -> contract
    | None -> failwith("Token contract not found")
  ];
  const params : tokenMintParams = (to_, value);

  // Send transaction to the token contract
  const op : operation = Tezos.transaction (Mint(params), 0tz, token);
} with (list [op], s)

(* `burn` calls burning operation on the token contract associated with `destCoinId` coin
and emits event with burning inforamtion for the oracle.
It starts the process of swapping and can be called by any user. *)
function burn (const destCoinId : coinId; const destAddress : string; const value : nat; var s : storage) : return is {
  const tokenAddress = case s.tokens[destCoinId] of [
    Some (address) -> address
    | None -> failwith("Coin ID not found")
  ];

  const token : contract (tokenAction) = 
  case (Tezos.get_contract_opt(tokenAddress) : option (contract (tokenAction))) of [
    Some (contract) -> contract
    | None -> failwith("Token contract not found")
  ];
  const params : tokenBurnParams = (Tezos.get_sender (), value);

  const ops : list (operation) = list [
    // Send transaction to the token contract
    Tezos.transaction (Burn(params), 0tz, token);
    // Emit event with burning information
    Tezos.emit ("%burn", BurnEvent (record [
      user = Tezos.get_sender ();
      amount = value;
      destAddress = destAddress;
      destCoinId = destCoinId;
      ts = Tezos.get_now ();
    ]))
  ]
} with (ops, s)

(* `addToken` associates `coinId` address with token address.
It does not originate a token contract on its own due to limitations in Michelson.
So token contract needs to be created independently before being added to the bridge.
Only owner can call it. *)
function addToken (const coinId : coinId; const tokenAddress : address; var s : storage) : return is {
  if Tezos.get_sender () =/= s.owner then
    failwith("Sender not an owner");

  const token_exists : bool = case s.tokens[coinId] of [
      Some (_) -> True
    | None -> False
  ];

  if token_exists then 
    failwith ("Token already exists");

  s.tokens[coinId] := tokenAddress;
} with (noOperations, s)

(* entrypoint *)
function main (const action : entryAction; var s : storage) : return is
  case action of [
    | Lock (params) -> lock (params.0, params.1, s)
    | Unlock (params) -> unlock (params.0, params.1, s)
    | Mint (params) -> mint (params.0, params.1.0, params.1.1, s)
    | Burn (params) -> burn (params.0, params.1.0, params.1.1, s)
    | AddToken (params) -> addToken (params.0, params.1, s)
  ]