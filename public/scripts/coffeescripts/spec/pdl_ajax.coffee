describe "A suite !!", ->
	it "contains spec with an expectation", ->
	  expect(true).toBe true

	it "not示例", ->
	  expect(false).not.toBe true

	it "toBe Matcher用来执行===对比", ->
	  a = 12
	  b = a
	  expect(a).toBe b
	  expect(a).not.toBe null

describe "toEqual判断两个对象是否相等：", ->
	it "对比简单的值类型的变量", ->
	  a = 12
	  expect(a).toEqual 12

	it "对比对象", ->
	  foo =
	    a: 12
	    b: 34

	  bar =
	    a: 12
	    b: 34

	  expect(foo).toEqual bar

	it "toMatch用来进行正则匹配", ->
	  message = "foo bar baz"
	  expect(message).toMatch /bar/
	  expect(message).toMatch "bar"
	  expect(message).not.toMatch /quux/

	it "toBeDefined判断是否非undefined", ->
	  a = foo: "foo"
	  expect(a.foo).toBeDefined()
	  expect(a.bar).not.toBeDefined()

	it "toBeUndefined判断是否是undefined", ->
	  a = foo: "foo"
	  expect(a.foo).not.toBeUndefined()
	  expect(a.bar).toBeUndefined()

	it "toBeNull用来判断是否为null", ->
	  a = null
	  foo = "foo"
	  expect(null).toBeNull()
	  expect(a).toBeNull()
	  expect(foo).not.toBeNull()

	it "toBeTruthy执行布尔测试，判断值是否是，或者可以转换为true", ->
	  a = undefined
	  foo = "foo"
	  expect(foo).toBeTruthy()
	  expect(a).not.toBeTruthy()

	it "toBeFalsy和toBeTruthy相反", ->
	  a = undefined
	  foo = "foo"
	  expect(a).toBeFalsy()
	  expect(foo).not.toBeFalsy()

	it "toContain判断一个数组是否包含某个值", ->
	  a = [
	    "foo"
	    "bar"
	    "baz"
	  ]
	  expect(a).toContain "bar"
	  expect(a).not.toContain "quux"

	it "toBeLessThan执行数字大小比较", ->
	  pi = 3.1415926
	  e = 2.78
	  expect(e).toBeLessThan pi
	  expect(pi).not.toBeLessThan e

	it "toBeGreaterThan和toBeLessThan相反", ->
	  pi = 3.1415926
	  e = 2.78
	  expect(pi).toBeGreaterThan e
	  expect(e).not.toBeGreaterThan pi

	it "toBeCloseTo示例", ->
	  pi = 3.1415926
	  e = 2.78
	  expect(pi).not.toBeCloseTo e, 2
	  expect(pi).toBeCloseTo e, 0

	it "toThrow判断一个函数是否有抛出异常", ->
	  foo = ->
	    1 + 2

	  bar = ->
	    a + 1 #a不存在

	  expect(foo).not.toThrow()
	  expect(bar).toThrow()

describe "Setup和Teardown示例", ->
  foo = undefined
  beforeEach ->
    foo = 0
    foo += 1


  afterEach ->
    foo = 0


  it "测试1", ->
    expect(foo).toEqual 1


  it "测试2", ->
    expect(foo).toEqual 1
    expect(true).toEqual true

describe "this用法示例", ->
  beforeEach ->
    @foo = 0

  it "使用this共享状态", ->
    expect(@foo).toEqual 0
    @bar = "test pollution?"


  it "下个Spec执行前this会被重置为空Object", ->
    expect(@foo).toEqual 0
    expect(@bar).toBe `undefined`

# describe "测试嵌套describe：level1", ->
#   foo = undefined
#   beforeEach ->
#     alert "level1：Setup"

#   afterEach ->
#     alert "level1：Teardown"

#   it "level1：测试", ->
#     alert "level1：测试"

#   describe "测试嵌套describe:level2", ->
#     beforeEach ->
#       alert "level2：Setup"
 
#     afterEach ->
#       alert "level2：Teardown"
 
#     it "level2：测试", ->
#       alert "level2：测试"
 
xdescribe "A spec", ->
  foo = undefined
  beforeEach ->
    foo = 0
    foo += 1

  it "is just a function, so it can contain any code", ->
    expect(foo).toEqual 1

describe "Pending specs", ->
  xit "can be declared 'xit'", ->
    expect(true).toBe false

  it "can be declared with 'it' but without a function"
  it "can be declared by calling 'pending' in the spec body", ->
    expect(true).toBe false
    pending()

describe "jasmine.any", ->
  it "matches any value", ->
    expect({}).toEqual jasmine.any(Object)
    expect(12).toEqual jasmine.any(Number)

  describe "when used with a spy", ->
    it "is useful for comparing arguments", ->
      foo = jasmine.createSpy("foo")
      foo 12, ->
        true

      expect(foo).toHaveBeenCalledWith jasmine.any(Number), jasmine.any(Function)
 


describe "jasmine.objectContaining", ->
  foo = undefined
  beforeEach ->
    foo =
      a: 1
      b: 2
      bar: "baz"


  it "matches objects with the expect key/value pairs", ->
    expect(foo).toEqual jasmine.objectContaining(bar: "baz")
    expect(foo).not.toEqual jasmine.objectContaining(c: 37)

  describe "when used with a spy", ->
    it "is useful for comparing arguments", ->
      callback = jasmine.createSpy("callback")
      callback bar: "baz"
      expect(callback).toHaveBeenCalledWith jasmine.objectContaining(bar: "baz")
      expect(callback).not.toHaveBeenCalledWith jasmine.objectContaining(c: 37)
 


# customMatchers = toBeGoofy: (util, customEqualityTesters) ->
#   compare: (actual, expected) ->
#     expected = ""  if expected is `undefined`
#     result = {}
#     result.pass = util.equals(actual.hyuk, "gawrsh" + expected, customEqualityTesters)
#     if result.pass
#       result.message = "通过了，通过了，通过了..."
#     else
#       result.message = "没通过，没通过，没通过..."
#     result

# describe "测试自定义错误信息", ->
#   beforeEach ->
#     jasmine.addMatchers customMatchers

#   it "这是个失败的测试", ->
#     expect(hyuk: "gawrsh").toBeGoofy 123

# customMatchers = toBeGoofy: (util, customEqualityTesters) ->
#   compare: (actual, expected) ->
#     expected = ""  if expected is `undefined`
#     result = {}
#     result.pass = util.equals(actual.hyuk, "gawrsh" + expected, customEqualityTesters)
#     result

# describe "测试自动生成的错误信息", ->
#   beforeEach ->
#     jasmine.addMatchers customMatchers

#   it "这是个失败的测试", ->
#     expect(hyuk: "gawrsh").toBeGoofy 123


# spies
describe "A spy", ->
  foo = undefined
  bar = null
  beforeEach ->
    foo = setBar: (value) ->
      bar = value
 
    spyOn foo, "setBar"
    foo.setBar 123
    foo.setBar 456, "another param"

  it "tracks that the spy was called", ->
    expect(foo.setBar).toHaveBeenCalled()

  it "tracks all the arguments of its calls", ->
    expect(foo.setBar).toHaveBeenCalledWith 123
    expect(foo.setBar).toHaveBeenCalledWith 456, "another param"

  it "stops all execution on a function", ->
    console.log foo
    expect(bar).toBeNull()

describe "A spy, when configured to call through", ->
  foo = undefined
  bar = undefined
  fetchedBar = undefined
  beforeEach ->
    foo =
      setBar: (value) ->
        bar = value
  
      getBar: ->
        bar

    spyOn(foo, "getBar").and.callThrough()
    foo.setBar 123
    fetchedBar = foo.getBar()

  it "tracks that the spy was called", ->
    expect(foo.getBar).toHaveBeenCalled()

  it "should not effect other functions", ->
    expect(bar).toEqual 123

  it "when called returns the requested value", ->
    expect(fetchedBar).toEqual 123

describe "A spy, when configured to fake a return value", ->
  foo = undefined
  bar = undefined
  fetchedBar = undefined
  beforeEach ->
    foo =
      setBar: (value) ->
        bar = value

      getBar: ->
        bar

    spyOn(foo, "getBar").and.returnValue 745
    foo.setBar 123
    fetchedBar = foo.getBar()

  it "tracks that the spy was called", ->
    expect(foo.getBar).toHaveBeenCalled()

  it "should not effect other functions", ->
    expect(bar).toEqual 123

  it "when called returns the requested value", ->
    expect(fetchedBar).toEqual 745

describe "A spy, when configured with an alternate implementation", ->
  foo = undefined
  bar = undefined
  fetchedBar = undefined
  beforeEach ->
    foo =
      setBar: (value) ->
        bar = value
   

      getBar: ->
        bar

    spyOn(foo, "getBar").and.callFake ->
      1001

    foo.setBar 123
    fetchedBar = foo.getBar()

  it "tracks that the spy was called", ->
    expect(foo.getBar).toHaveBeenCalled()

  it "should not effect other functions", ->
    expect(bar).toEqual 123

  it "when called returns the requested value", ->
    expect(fetchedBar).toEqual 1001

describe "A spy, when configured to throw an error", ->
  foo = undefined
  bar = undefined
  beforeEach ->
    foo = setBar: (value) ->
      bar = value

    spyOn(foo, "setBar").and.throwError "quux"
   

  it "throws the value", ->
    expect(->
      foo.setBar 123
     
    ).toThrowError "quux"
   
describe "A spy", ->
  foo = undefined
  bar = null
  beforeEach ->
    foo = setBar: (value) ->
      bar = value

    spyOn(foo, "setBar").and.callThrough()

  it "can call through and then stub in the same spec", ->
    foo.setBar 123
    expect(bar).toEqual 123
    foo.setBar.and.stub()
    bar = null
    foo.setBar 123
    expect(bar).toBe null

describe "Multiple spies, when created manually", ->
  tape = undefined
  beforeEach ->
    tape = jasmine.createSpyObj("tape", [
      "play"
      "pause"
      "stop"
      "rewind"
    ])
    tape.play()
    tape.pause()
    tape.rewind 0

  it "creates spies for each requested function", ->
    expect(tape.play).toBeDefined()
    expect(tape.pause).toBeDefined()
    expect(tape.stop).toBeDefined()
    expect(tape.rewind).toBeDefined()

  it "tracks that the spies were called", ->
    expect(tape.play).toHaveBeenCalled()
    expect(tape.pause).toHaveBeenCalled()
    expect(tape.rewind).toHaveBeenCalled()
    expect(tape.stop).not.toHaveBeenCalled()

  it "tracks all the arguments of its calls", ->
    expect(tape.rewind).toHaveBeenCalledWith 0
 
describe "Jasmine Spy的跟踪属性", ->
  foo = undefined
  bar = null
  beforeEach ->
    foo = setBar: (value) ->
      bar = value

    spyOn foo, "setBar"

  it ".calls.any()示例", ->
    expect(foo.setBar.calls.any()).toEqual false
    foo.setBar()
    expect(foo.setBar.calls.any()).toEqual true

  it ".calls.count()示例", ->
    expect(foo.setBar.calls.count()).toEqual 0
    foo.setBar()
    foo.setBar()
    expect(foo.setBar.calls.count()).toEqual 2

  it ".calls.argsFor(index)示例", ->
    foo.setBar 123
    foo.setBar 456, "baz"
    expect(foo.setBar.calls.argsFor(0)).toEqual [123]
    expect(foo.setBar.calls.argsFor(1)).toEqual [
      456
      "baz"
    ]

  it ".calls.allArgs()示例", ->
    foo.setBar 123
    foo.setBar 456, "baz"
    expect(foo.setBar.calls.allArgs()).toEqual [
      [123]
      [
        456
        "baz"
      ]
    ]

  it ".calls.all()示例", ->
    foo.setBar 123
    expect(foo.setBar.calls.all()).toEqual [
      object: foo
      args: [123]
    ]

  it ".calls.mostRecent()示例", ->
    foo.setBar 123
    foo.setBar 456, "baz"
    expect(foo.setBar.calls.mostRecent()).toEqual
      object: foo
      args: [
        456
        "baz"
      ]


  it ".calls.first()示例", ->
    foo.setBar 123
    foo.setBar 456, "baz"
    expect(foo.setBar.calls.first()).toEqual
      object: foo
      args: [123]


  it ".calls.reset()示例", ->
    foo.setBar 123
    foo.setBar 456, "baz"
    expect(foo.setBar.calls.any()).toBe true
    foo.setBar.calls.reset()
    expect(foo.setBar.calls.any()).toBe false

describe "Jasmine Clock 测试", ->
  timerCallback = undefined
  beforeEach ->
    timerCallback = jasmine.createSpy("timerCallback")
    jasmine.clock().install()

  afterEach ->
    jasmine.clock().uninstall()

  it "同步触发setTimeout", ->
    setTimeout (->
      timerCallback()
 
    ), 100
    expect(timerCallback).not.toHaveBeenCalled()
    jasmine.clock().tick 101
    expect(timerCallback).toHaveBeenCalled()

  it "同步触发setInterval", ->
    setInterval (->
      timerCallback()
 
    ), 100
    expect(timerCallback).not.toHaveBeenCalled()
    jasmine.clock().tick 101
    expect(timerCallback.calls.count()).toEqual 1
    jasmine.clock().tick 50
    expect(timerCallback.calls.count()).toEqual 1
    jasmine.clock().tick 50
    expect(timerCallback.calls.count()).toEqual 2

describe "Jasmine 异步测试演示", ->
  value = undefined
  beforeEach (done) ->
    setTimeout (->
      value = 0
      done()
 
    ), 1

  it "should support async execution of test preparation and expectations", (done) ->
    value++
    expect(value).toBeGreaterThan 0
    done()

  describe "5秒钟", ->
    originalTimeout = undefined
    beforeEach ->
      originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL
      jasmine.DEFAULT_TIMEOUT_INTERVAL = 600
 

    it "takes a long time", (done) ->
      setTimeout (->
        done()
   
      ), 500
 

    afterEach ->
      jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout
 
# describe "mocking ajax", ->
#   describe "suite wide usage", ->
#     beforeEach ->
#       jasmine.Ajax.install()
      

#     afterEach ->
#       jasmine.Ajax.uninstall()
      

#     it "specifying response when you need it", ->
#       doneFn = jasmine.createSpy("success")
#       xhr = new XMLHttpRequest()
#       xhr.onreadystatechange = (arguments_) ->
#         doneFn @responseText  if @readyState is @DONE
        

#       xhr.open "GET", "/some/cool/url"
#       xhr.send()
#       expect(jasmine.Ajax.requests.mostRecent().url).toBe "/some/cool/url"
#       expect(doneFn).not.toHaveBeenCalled()
#       jasmine.Ajax.requests.mostRecent().response
#         status: 200
#         contentType: "text/plain"
#         responseText: "awesome response"

#       expect(doneFn).toHaveBeenCalledWith "awesome response"
      

#     it "allows responses to be setup ahead of time", ->
#       doneFn = jasmine.createSpy("success")
#       jasmine.Ajax.stubRequest("/another/url").and responseText: "immediate response"
#       xhr = new XMLHttpRequest()
#       xhr.onreadystatechange = (arguments_) ->
#         doneFn @responseText  if @readyState is @DONE
        

#       xhr.open "GET", "/another/url"
#       xhr.send()
#       expect(doneFn).toHaveBeenCalledWith "immediate response"
    

#   it "allows use in a single spec", ->
#     doneFn = jasmine.createSpy("success")
#     jasmine.Ajax.withMock ->
#       xhr = new XMLHttpRequest()
#       xhr.onreadystatechange = (arguments_) ->
#         doneFn @responseText  if @readyState is @DONE
        

#       xhr.open "GET", "/some/cool/url"
#       xhr.send()
#       expect(doneFn).not.toHaveBeenCalled()
#       jasmine.Ajax.requests.mostRecent().response
#         status: 200
#         responseText: "in spec response"

#       expect(doneFn).toHaveBeenCalledWith "in spec response"
      

    

  


