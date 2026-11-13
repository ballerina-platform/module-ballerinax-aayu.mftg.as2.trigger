# Examples

The `ballerinax/aayu.mftg.as2.trigger` connector provides practical examples illustrating usage in various scenarios.

1. [Received file logger](https://github.com/ballerina-platform/module-ballerinax-aayu.mftg.as2.trigger/tree/main/examples/received-file-logger) - Log each AS2 message a partner sends, with its files.
2. [Send failure alert](https://github.com/ballerina-platform/module-ballerinax-aayu.mftg.as2.trigger/tree/main/examples/send-failure-alert) - Alert when an outbound AS2 message fails or is never confirmed.
3. [AS2 audit trail](https://github.com/ballerina-platform/module-ballerinax-aayu.mftg.as2.trigger/tree/main/examples/as2-audit-trail) - One audit line per AS2 event, from all four service types on one listener.

## Prerequisites

Register an AS2 webhook in MFT Gateway with payload signing on and save it, then download the webhook public key, put it in a `Config.toml` in the example's directory (each example's README shows the key), and start the example, as described in the [Setup guide](../ballerina/README.md#setup-guide).

## Running an example

Execute the following commands from an example's directory (for example `cd as2-audit-trail`) to build it from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
