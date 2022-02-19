type unwrap_param = {
    token_id: eth_address;
    amount: nat;
    fees: nat;
    destination: eth_address;
}

type entry_points = 
    | Minter of signer_entrypoints
    | Unwrap of unwrap_param
    | Contract_admin of contract_admin_entrypoints
    | Assets_admin of assets_admin_entrypoints

let unwrap ((p, s) : (unwrap_param * assets_storage)) : (operation list * assets_storage) = 
    let (contract_address, token_id) = get_fa2_token_id(p.token_id, s.tokens) in
    let mint_burn_entrypoint = token_tokens_entry_point(contract_address) in
    let min_fees:nat = p.amount * g.unwrapping_fees / 10_000n in
    let ignore = check_amount_large_enough(min_fees) in
    let ignore = check_fees_high_enough(p.fees, min_fees) in
    let burn = Tezos.transaction (Burn_tokens [{owner =Tezos.sender; token_id = token_id; amount = p.amount+p.fees}]) 0mutez mint_burn_entrypoint in
    let mint = Tezos.transaction (Mint_tokens [{owner = g.fees_contract ; token_id = token_id ; amount = p.fees}]) 0mutez mint_burn_entrypoint in (([burn; mint]), s)