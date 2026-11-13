# Send failure alert

Raise an alert when an outbound AS2 message fails to send, with MFT Gateway's failure reason and
attempt count, or when it is sent but the partner never confirms delivery.

## Run

Put the public key downloaded from MFT Gateway in a `Config.toml` in this directory:

```toml
[ballerina_example.send_failure_alert.config]
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
