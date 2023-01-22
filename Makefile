LIGO = docker run --rm -v "$(shell pwd)":"$(shell pwd)" -w "$(shell pwd)" ligolang/ligo:0.37.0

# Metadata links encoded in hex
bETH_METADATA_HEX_LINK = 68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f626966726f73742d646566692f626966726f73742d747a732d636f6e7472616374732f6d61696e2f6d657461646174612f6574685f666131325f6d657461646174612e6a736f6e
bTON_METADATA_HEX_LINK = 68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f626966726f73742d646566692f626966726f73742d747a732d636f6e7472616374732f6d61696e2f6d657461646174612f746f6e5f666131325f6d657461646174612e6a736f6e

compile.prepare:
	@mkdir -p build/wrapped-swap

compile.json: compile.prepare
	@$(LIGO) compile contract -o build/wrapped-swap/token.json --michelson-format json ./src/wrapped-swap/token.ligo
	@$(LIGO) compile contract -o build/wrapped-swap/bridge.json --michelson-format json ./src/wrapped-swap/bridge.ligo

compile.tz: compile.prepare
	@$(LIGO) compile contract --o build/wrapped-swap/token.tz ./src/wrapped-swap/token.ligo
	@$(LIGO) compile contract --o build/wrapped-swap/bridge.tz ./src/wrapped-swap/bridge.ligo

originate.beth:
	@ts-node scripts/originateToken.ts --meta=$(bETH_METADATA_HEX_LINK)

originate.bton:
	@ts-node scripts/originateToken.ts --meta=$(bTON_METADATA_HEX_LINK)
	
originate.lambda:
	@eval $(ts-node scripts/originateLambda.ts)
