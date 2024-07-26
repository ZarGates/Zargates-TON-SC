<h1 align='center'>

ZARGATES TON

</h1>

## Project structure

-   `contracts` - source code of all the smart contracts of the project and their dependencies.
-   `wrappers` - wrapper classes (implementing `Contract` from ton-core) for the contracts, including any [de]serialization primitives and compilation functions.
-   `tests` - tests for the contracts.
-   `scripts` - scripts used by the project, mainly the deployment scripts.

## How to use

### Build

`yarn blueprint build`

### Test

`yarn blueprint test`

### Deploy or run another script

`yarn blueprint run`

