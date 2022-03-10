compile.json:
	ligo compile contract -o build/contract.json --michelson-format json ./contract/contract.ligo

comile.tz:
	ligo compile contract --o build/contract.tz ./contract/contract.ligo