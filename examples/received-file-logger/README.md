# Received file logger

The minimal, canonical `aayu.mftg.as2.trigger` use case: log each AS2 message a trading partner
sends you, with its subject, partner, station and the files it carried.

## Run

Put the public key downloaded from MFT Gateway in a `Config.toml` in this directory:

```toml
[ballerina_example.received_file_logger.config]
webhookSecret = """-----BEGIN PUBLIC KEY-----
...
-----END PUBLIC KEY-----"""
```

Then run:

```bash
bal run
```

Follow the [Setup guide](../../ballerina/README.md#setup-guide) in the package README to expose
this listener and register it as an AS2 webhook in MFT Gateway, then have a partner send a message
to your station.
