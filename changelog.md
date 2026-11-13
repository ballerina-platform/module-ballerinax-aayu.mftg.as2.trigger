# Changelog
This file contains all the notable changes done to the Ballerina Aayu MFT Gateway AS2 trigger through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0]

### Added
- The `aayu.mftg.as2.trigger` package, replacing `trigger.aayu.mftg.as2` from the `asyncapi-triggers` monorepo. It is generated from the AsyncAPI definition in `docs/spec` with the Ballerina AsyncAPI tool. See the [migration notes](docs/migration-notes.md) for what changed from `trigger.aayu.mftg.as2`.
- Signature verification of every delivery (`mftg-wh-signature`, RSA with SHA-256 over the payload with its keys sorted) with the public key downloaded from MFT Gateway. `trigger.aayu.mftg.as2` accepted unsigned requests.
- The `MESSAGE.SEND.INCOMPLETE` event, through `IncompleteMessageService`.
- Payload records that match MFT Gateway's documented payloads, so sent, failed and incomplete events bind.
- Services on the trigger listener are listed by `bal build --export-endpoints`, through a compiler plugin packaged with the trigger. Endpoint export needs Ballerina 2201.13.6 or later.
- Trigger metadata and icons under `metadata/` for low-code tooling.
- The listener a trigger creates from a port caps request bodies at 25 MB, as each body is read before its signature is checked.
