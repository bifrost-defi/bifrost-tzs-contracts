const add_num : int = 1

function main (const number : int; const _storage : int) : 
list (operation) * int is ((nil : list (operation)), number + add_num)

type storage is int

type cube is int * int * int

function main (const side: cube; const _store : storage) :
    (list(operation) * int) is block {
        const result : int = side.0 * side.1 * side.2
    } with ((nil : list(operation)), result)

type user is 
    record [
        id : nat;
        is_admin : bool;
        name : string;
    ]

const alice : user = 
    record [
        id = 1n;
        is_admin = True;
        name = "Alice";
    ]

type dims is int * int * int
type cube_dimension is map (string, dims)

const cubes : cube_dimension = 
    map [
        "big cube" -> (12343, 123, 8123);
        "small cube" -> (3, 3, 7);
    ]

const big : option(dims) = cubes["big cube"]

type speach is 
    Labeof of unit
    | Nike of unit 
    | Yoda of unit 

type return is (list(operation) * string)

function main (const word: speach; const _store: string): return is
    ((nil : list (operation)),
    
    case word of 
    Labeof (_n) -> "Do IT!"
    | Nike (_n) -> "Just do it"
    | Yoda (_n) -> "Do it you can"
    end
    )