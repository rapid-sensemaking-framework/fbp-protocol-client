noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  client = require '../index'
  utils = require './utils'
else
  client = require 'fbp-protocol-client'

Base = client.getTransport 'base'
Runtime = client.getTransport 'microflo'
connection = client.connection
  
blinky = """
timer(Timer) OUT -> IN toggle(ToggleBoolean) OUT -> IN write(DigitalWrite)
'13' -> PIN write
'100' -> INTERVAL timer
"""

describe 'MicroFlo', ->
  Runtime = null

  before (done) ->
    done()
  after (done) ->
    done()

  describe 'Address parsing', ->
    cases =
      'simulator://': { type: 'simulator', baudrate: '9600', device: null,  },
      'serial:///dev/foo': { type: 'serial', baudrate: '9600', device: '/dev/foo' },
      'serial:///dev/foo?baudrate=115200': { type: 'serial', baudrate: '115200', device: '/dev/foo' },
    Object.keys(cases).forEach (name) ->
      expect = cases[name]
      describe name, ->
        it 'should equal expected', () ->
          return @skip() unless Runtime
          out = Runtime.parseAddress name
          chai.expect(out).to.eql expect

  describe 'Runtime', ->
    before ->
      @skip() unless Runtime
    runtime = null
    def =
      label: "MicroFlo Simulator"
      description: "The first remote component in the world"
      type: "microflo"
      protocol: "microflo"
      address: "simulator://"
      secret: "my-super-secret"
      id: "2ef763ff-1f28-49b8-b58f-5c6a5c23af2d"
      user: "3f3a8187-0931-4611-8963-239c0dff1931"
      seenHoursAgo: 11

    it 'should be instantiable', () ->
      runtime = new Runtime def
      chai.expect(runtime).to.be.an.instanceof Base
    it 'should not be connected initially', () ->
      chai.expect(runtime.isConnected()).to.equal false
    it 'should emit "connected" on connect()', (done) ->
      runtime.once 'connected', () ->
        chai.expect(runtime.isConnected()).to.equal true
        done()
      runtime.connect()
    it 'should emit "disconnected" on disconnect()', (done) ->
      runtime.once 'disconnected', () ->
        chai.expect(runtime.isConnected()).to.equal false
        done()
      runtime.disconnect()

    describe 'Sending a Blink program', () ->
      before ->
        @skip() unless Runtime
      graph = null
      it 'should start executing', (done) ->
        runtime = new Runtime def
        checkRunning = (status) ->
          if status.running
            runtime.removeListener 'execution', checkRunning
            return done()
        runtime.on 'execution', checkRunning

        noflo.graph.loadFBP blinky, (err, g) ->
          return done err if err
          graph = g
          runtime.setMain graph 
          runtime.connect()
          connection.sendGraph graph, runtime, () ->
            runtime.start() # does upload

    # TODO: in browser, test simulator UI able to blink an LED
    # TODO: test exported ports and sending data through

