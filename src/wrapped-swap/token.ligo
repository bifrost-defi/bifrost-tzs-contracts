type trusted is address;
type amt is nat;

type account is record [
  balance : amt;
  allowances : map (trusted, amt);
]

type tokenMetadata is michelson_pair (nat, "token_id", map(string, bytes), "token_info")

type storage is record [
  owner : address;
  bridge : address;
  totalSupply : amt;
  ledger : big_map (address, account);
  token_metadata : big_map (nat, tokenMetadata);
]

type return is list (operation) * storage

const noOperations : list (operation) = nil;

type transferParams is michelson_pair(address, "from", michelson_pair(address, "to", amt, "value"), "")
type approveParams is michelson_pair(trusted, "spender", amt, "value")
type balanceParams is michelson_pair(address, "owner", contract(amt), "")
type allowanceParams is michelson_pair(michelson_pair(address, "owner", trusted, "spender"), "", contract(amt), "")
type totalSupplyParams is (unit * contract(amt))
type mintParams is michelson_pair(address, "to", amt, "value")
type burnParams is michelson_pair(amt, "value", string, "destination")

type entryAction is
| Transfer of transferParams
| Approve of approveParams
| GetBalance of balanceParams
| GetAllowance of allowanceParams
| GetTotalSupply of totalSupplyParams
| Mint of mintParams
| Burn of burnParams

type notifyBurnParams is michelson_pair(address, "user", michelson_pair(amt, "coinAmount", string, "destAddress"), "")

type bridgeAction is
  | NotifyBurn of notifyBurnParams

function getAccount (const addr : address; const s : storage) : account is {
  var acct : account :=
    record [
      balance = 0n;
      allowances = (map [] : map (address, amt));
    ];
  case s.ledger[addr] of [
    None -> skip
    | Some(instance) -> acct := instance
  ]
} with acct

function getAllowance (const ownerAccount : account; const spender : address; const _s : storage) : amt is
  case ownerAccount.allowances[spender] of [
    Some (amt) -> amt
    | None -> 0n
  ]

function transfer (const from_ : address; const to_ : address; const value : amt; var s : storage) : return is {
  var senderAccount : account := getAccount(from_, s);

  if senderAccount.balance < value then
    failwith("Source balance is too low");

  if from_ =/= Tezos.sender then block {
    const spenderAllowance : amt = getAllowance(senderAccount, Tezos.sender, s);

    if spenderAllowance < value then
      failwith("NotEnoughAllowance");

    senderAccount.allowances[Tezos.sender] := abs(spenderAllowance - value);
  } else skip;

  senderAccount.balance := abs(senderAccount.balance - value);

  s.ledger[from_] := senderAccount;

  var destAccount : account := getAccount(to_, s);
  destAccount.balance := destAccount.balance + value;
  s.ledger[to_] := destAccount;
} with (noOperations, s)

function mint (const to_ : address; const value : amt; var s : storage) : return is
   // If the sender is not the bridge fail
  if Tezos.sender =/= s.bridge then 
    failwith("Only the bridge can mint tokens")
  else {
    var dst: account := getAccount(to_, s);

    // Update user balance
    dst.balance := dst.balance + value;
    s.ledger[to_] := dst;
    s.totalSupply := s.totalSupply + value;
  } with (noOperations, s)

function burn (const value : amt; const destination : string; var s : storage) : return is {
  var senderAccount: account := getAccount(Tezos.sender, s);

  // Check that the owner can spend that much
  if value > senderAccount.balance then 
    failwith("Balance is too low");

  // Update the sender balance
  // Using the abs function to convert int to nat
  senderAccount.balance := abs(senderAccount.balance - value);
  s.ledger[Tezos.sender] := senderAccount;
  s.totalSupply := abs(s.totalSupply - value);

  // Send notification to the bridge contract
  const bridge : contract (bridgeAction) = 
    case (Tezos.get_contract_opt(s.bridge) : option (contract (bridgeAction))) of [
      Some (contract) -> contract
      | None -> failwith("Bridge contract not found")
    ];
  const params : notifyBurnParams = (Tezos.sender, (value, destination));
  const op : operation = Tezos.transaction (NotifyBurn(params), 0tz, bridge);
} with (list [op], s)

function approve (const spender : address; const value : amt; var s : storage) : return is {
  var senderAccount : account := getAccount(Tezos.sender, s);
  const spenderAllowance : amt = getAllowance(senderAccount, spender, s);

  if spenderAllowance > 0n and value > 0n then
    failwith("UnsafeAllowanceChange");

  senderAccount.allowances[spender] := value;

  s.ledger[Tezos.sender] := senderAccount;
} with (noOperations, s)

function getBalance (const owner : address; const contr : contract(amt); var s : storage) : return is {
  const ownerAccount : account = getAccount(owner, s);
} with (list [transaction(ownerAccount.balance, 0tz, contr)], s)

function getAllowance (const owner : address; const spender : address; const contr : contract(amt); var s : storage) : return is {
  const ownerAccount : account = getAccount(owner, s);
  const spenderAllowance : amt = getAllowance(ownerAccount, spender, s);
} with (list [transaction(spenderAllowance, 0tz, contr)], s)

function getTotalSupply (const contr : contract(amt); var s : storage) : return is
  (list [transaction(s.totalSupply, 0tz, contr)], s)

function main (const action : entryAction; var s : storage) : return is
  case action of [
      | Transfer(params) -> transfer(params.0, params.1.0, params.1.1, s)
      | Approve(params) -> approve(params.0, params.1, s)
      | GetBalance(params) -> getBalance(params.0, params.1, s)
      | GetAllowance(params) -> getAllowance(params.0.0, params.0.1, params.1, s)
      | GetTotalSupply(params) -> getTotalSupply(params.1, s)
      | Mint(params) -> mint(params.0, params.1, s)
      | Burn(params) -> burn(params.0, params.1, s)
  ]