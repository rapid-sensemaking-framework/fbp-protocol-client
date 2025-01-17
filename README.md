# fbp-protocol-client [![Build Status](https://travis-ci.org/flowbased/fbp-protocol-client.svg?branch=master)](https://travis-ci.org/flowbased/fbp-protocol-client) [![Greenkeeper badge](https://badges.greenkeeper.io/flowbased/fbp-protocol-client.svg)](https://greenkeeper.io/)

Implementation of [FBP runtime protocol](https://flowbased.github.io/fbp-protocol/)
for JavaScript (node.js + browser).

Changes
-------

* 0.2.5 (March 28 2018)
  - Fixed `iframe` transport updating iframe contents after main graph is set
  - Added support for setting main graph to `NULL`
* 0.2.4 (March 22 2018)
  - Made `iframe` and `opener` transports filter out messages coming from elsewhere than the runtime. Fixes compatibility with es6-shim
* 0.2.3 (March 21 2018)
  - Added `sendTrace` method for sending trace subprotocol messages
  - Added `trace` event for incoming trace subprotocol messages
  - Added `message` event for all incoming protocol messages



pending fix for electron circumstances

```
isBrowser = function isBrowser() {
  return !(typeof process !== 'undefined' && process.execPath && (process.execPath.indexOf('.app') !== -1 || process.execPath.indexOf('node') !== -1));
};
```
