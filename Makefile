LIGO = docker run --rm -v "$(shell pwd)":"$(shell pwd)" -w "$(shell pwd)" ligolang/ligo:0.37.0

compile.json:
	@$(LIGO) compile contract -o build/contract.json --michelson-format json ./src/contract.ligo

compile.tz:
	@$(LIGO) compile contract --o build/contract.tz ./src/contract.ligo

originate.wavax:
	@ts-node scripts/originate.ts --meta=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f737075746e696b2d646566692f626966726f73742d747a732d636f6e7472616374732f6d61696e2f77617661785f666131325f6d657461646174612e6a736f6e

originate.wusdc:
	@ts-node scripts/originate.ts --meta=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f737075746e696b2d
	
originate.lambda:
	@eval $(ts-node scripts/originateLambda.ts)
