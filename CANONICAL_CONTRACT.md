# helios canonical contract

## Purpose and authority

I am the Koralabs copy of the Helios compiler and transaction library: Helios source goes in, Plutus-Core scripts, script hashes and addresses come out, and the same library builds, fees, signs and serializes Cardano transactions. I carry no keys and run no service. But a Handle contract's on-chain address is the hash of what I compile, and settings datums reference those hashes, so a change in my output moves real contracts. I am the source of the Helios packages the contract repos consume (`@hyperionbt/helios` 0.16.7 from this `main`; `@koralabs/helios` 0.16.8-x from the 0.16.8 line; I have not verified which branch publishes which). Ecosystem rules: `../AGENTS.md` (Critical Correctness, Merging: contract and settings changes need operator approval). Paths in [`.enclave`](./.enclave) need operator approval to merge.

## Invariants (must never be violated)

1. The same Helios source, compiler version and compile options always produce the same script bytes and the same script hash. A change to the compiler, optimizer, tokenizer or evaluator that changes any hash for existing source is a contract change and needs operator approval, plus a version bump and a changelog line (the 2023-09-12 entry already warns once that IR cleanup "might change some script hashes"). (Not enforced by a test; see limits.)
2. Addresses, script hashes and policy ids are derived exactly: bech32 checksums are verified, header bytes map to the right network and credential type, and an invalid address throws rather than decoding to something else. (`src/crypto.js`, `src/tx-builder.js`; tests `test/addresses.test.js`, bech32 verification in `crypto.js` asserts `invalid bech32 addr`.)
3. A signature added to a transaction is verified against that transaction's body hash by default; a witness for a different body is rejected. (`Tx.addSignature` verifies unless explicitly told not to; `test/tx-building.test.js` covers building and signing but I did not find a test that a mismatched signature is rejected.)
4. Fee, collateral and execution-budget calculations never under-pay: a built transaction's fee is at least the minimum for its serialized size and script budget under the given network parameters. (`src/tx-builder.js`, `src/uplc-costmodels.js`; tests `test/tx-building.test.js`, `test/exbudget.test.js`.)
5. Coin selection never spends more than the inputs hold and never drops assets: inputs equal outputs plus fee plus change, per asset. (`src/coinselection.js`; covered indirectly by `test/tx-building.test.js`.)
6. Only reviewed source is published: `package.json`, the built `helios.js`/`helios.d.ts` and the workflow change only with operator approval, because every contract repo compiles with whatever version it installs.
7. No secrets in git.

## Boundaries and known limits

- Invariant 1 is the most important and has no direct test here. The tests check language behavior (evaluating programs, simplification, example scripts) and never pin the compiled hash of a fixed reference script, so a hash-changing edit can pass every test.
- `helios.js` is a generated bundle of `src/` (`prebuild` runs `node ./src/index.js`), so a source change and the bundle must change together; nothing checks they agree besides the build.
- CI runs on Node 18 only and `npm run build`, which is `npm test` and the type declaration build.
- This is a fork of an upstream project under BSD-3-Clause; most history is the upstream author's. Review upstream merges as compiler changes.
- `pub` uploads to an S3 bucket and publishes to npm from a developer machine; the CI workflow does not publish.

## Refactors needed to enforce this

- Add a golden test: compile a fixed set of real Handle scripts (and a few synthetic ones) and assert exact script hashes and CBOR, so any hash change fails loudly.
- Add a test that `addSignature` rejects a signature over a different body and that unverified adds require the explicit flag.
- Add a conservation test for coin selection (inputs equal outputs plus fee, per asset) with property-style cases.
- Add a check that `helios.js` equals the build output of `src/`.
- Move publishing into a GitHub Actions job with provenance, or document that only an operator publishes.
