# Release Management

This repository is managed following the [Trunk Based Development workflow](https://trunkbaseddevelopment.com).

Every push in `master` will trigger a deployment in the staging environment.

Production releases will be cut from master when the core team deems it necessary. Releases will be published on dedicated, freezed feature branches prefixed with `release/<unix timestamp>` (e.g. `release/1571677021`).

For all intents and purposes, `master` is to be considered the mainline branch.