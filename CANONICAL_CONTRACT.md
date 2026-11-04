# helios canonical contract

The Koralabs copy of the Helios compiler and transaction library: Helios source in, Plutus-Core scripts, script hashes and addresses out; it also builds, fees, signs and serializes Cardano transactions. It holds no keys and runs no service.

1. The same Helios source, compiler version and options always produce the same script bytes and script hash. A change that alters any hash for existing source is a contract change and needs a version bump and a changelog line.
2. Addresses, script hashes and policy ids are derived exactly: bech32 checksums are verified, header bytes map to the right network and credential type, and an invalid address throws.
3. A signature added to a transaction is verified against that transaction's body hash by default.
4. A built transaction's fee is never below the minimum for its serialized size and script budget under the given network parameters.
5. Coin selection conserves value: inputs equal outputs plus fee plus change, per asset, and no asset is dropped.
