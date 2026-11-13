# AS2 audit trail

Write one audit line for every AS2 event, received, sent, failed or incomplete, so every exchange
with a trading partner can be traced. All four service types share one listener.

## Run

Put the public key downloaded from MFT Gateway in a `Config.toml` in this directory:

```toml
[ballerina_example.as2_audit_trail.config]
webhookSecret = """-----BEGIN PUBLIC KEY-----
...
-----END PUBLIC KEY-----"""
```

Then run:

```bash
bal run
```

Follow the [Setup guide](../../ballerina/README.md#setup-guide) in the package README to expose
this listener and register it as an AS2 webhook in MFT Gateway.
