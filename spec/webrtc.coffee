noflo = require 'noflo'

EventEmitter = require('events').EventEmitter
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  client = require '../index'
  utils = require './utils'
else
  client = require 'fbp-protocol-client'

Base = client.getTransport 'base'
WebRtcRuntime = client.getTransport 'webrtc'
connection = client.connection

describeIfBrowser = if noflo.isBrowser() then describe else describe.skip

class FakeRuntime extends EventEmitter
  constructor: (address) ->
    super()
    if (address.indexOf('#') != -1)
      @signaller = address.split('#')[0]
      @id = address.split('#')[1]
    else
      @signaller = 'https://api.flowhub.io'
      @id = address

    console.log @signaller, @id

    @channel = null
    options =
      room: @id
      debug: true
      channels:
        chat: true
      signaller: @signaller
      capture: false
      constraints: false
      expectedLocalStreams: 0
    peer = RTC options
    peer.on 'channel:opened:chat', (id, dc) =>
      console.log 'fakeruntime opened'
      @channel = dc
      dc.onmessage = (data) =>
        msg = JSON.parse data.data
        @emit 'message', msg
        if msg.protocol == 'runtime' && msg.command == 'getruntime'
          # reply so we are considered to be connected
          @send 'runtime', 'runtime',
            type: 'noflo-browser'
            version: '0.4'
            capabilities: ["protocol:graph"]

  send: (protocol, topic, payload, context) ->
    msg =
      protocol: protocol
      command: topic
      payload: payload
    m = JSON.stringify msg
    @channel.send m


describeIfBrowser 'WebRTC', ->

  describeIfBrowser 'transport', ->
    runtime = null
    id = "2ef763ff-1f28-49b8-b58f-5c9a5c23af2f"
    def =
      label: "NoFlo over WebRTC"
      description: "Open any client-side NoFlo app in Flowhub"
      type: "noflo-browser"
      protocol: "webrtc"
      address: id
      secret: "my-super-secret"
      id: id
      user: "3f3a8187-0931-4611-8963-239c0dff1931"
      seenHoursAgo: 11

    before (done) ->
      target = new FakeRuntime def.address
      done()
    after (done) ->
      target = null
      done()

    it 'should be instantiable', () ->
      runtime = new WebRtcRuntime def
      chai.expect(runtime).to.be.an.instanceof Base
    it 'should not be connected initially', () ->
      chai.expect(runtime.isConnected()).to.equal false
    it 'should emit "connected" on connect()', (done) ->
      return @skip() if window._phantom
      @timeout 10000
      console.log 'running connect()'
      runtime.once 'connected', () ->
        connected = runtime.isConnected()
        console.log 'connected', connected
        chai.expect(connected).to.equal true
        done()
      runtime.connect()
      console.log 'connect() done'
    it 'should emit "disconnected" on disconnect()', (done) ->
      return @skip() if window._phantom
      @timeout 10000
      runtime.once 'disconnected', () ->
        chai.expect(runtime.isConnected()).to.equal false
        done()
      runtime.disconnect()


