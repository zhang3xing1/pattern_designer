(function() {
  describe("A suite !!", function() {
    it("contains spec with an expectation", function() {
      return expect(true).toBe(true);
    });
    it("not示例", function() {
      return expect(false).not.toBe(true);
    });
    return it("toBe Matcher用来执行===对比", function() {
      var a, b;
      a = 12;
      b = a;
      expect(a).toBe(b);
      return expect(a).not.toBe(null);
    });
  });

  describe("toEqual判断两个对象是否相等：", function() {
    it("对比简单的值类型的变量", function() {
      var a;
      a = 12;
      return expect(a).toEqual(12);
    });
    it("对比对象", function() {
      var bar, foo;
      foo = {
        a: 12,
        b: 34
      };
      bar = {
        a: 12,
        b: 34
      };
      return expect(foo).toEqual(bar);
    });
    it("toMatch用来进行正则匹配", function() {
      var message;
      message = "foo bar baz";
      expect(message).toMatch(/bar/);
      expect(message).toMatch("bar");
      return expect(message).not.toMatch(/quux/);
    });
    it("toBeDefined判断是否非undefined", function() {
      var a;
      a = {
        foo: "foo"
      };
      expect(a.foo).toBeDefined();
      return expect(a.bar).not.toBeDefined();
    });
    it("toBeUndefined判断是否是undefined", function() {
      var a;
      a = {
        foo: "foo"
      };
      expect(a.foo).not.toBeUndefined();
      return expect(a.bar).toBeUndefined();
    });
    it("toBeNull用来判断是否为null", function() {
      var a, foo;
      a = null;
      foo = "foo";
      expect(null).toBeNull();
      expect(a).toBeNull();
      return expect(foo).not.toBeNull();
    });
    it("toBeTruthy执行布尔测试，判断值是否是，或者可以转换为true", function() {
      var a, foo;
      a = void 0;
      foo = "foo";
      expect(foo).toBeTruthy();
      return expect(a).not.toBeTruthy();
    });
    it("toBeFalsy和toBeTruthy相反", function() {
      var a, foo;
      a = void 0;
      foo = "foo";
      expect(a).toBeFalsy();
      return expect(foo).not.toBeFalsy();
    });
    it("toContain判断一个数组是否包含某个值", function() {
      var a;
      a = ["foo", "bar", "baz"];
      expect(a).toContain("bar");
      return expect(a).not.toContain("quux");
    });
    it("toBeLessThan执行数字大小比较", function() {
      var e, pi;
      pi = 3.1415926;
      e = 2.78;
      expect(e).toBeLessThan(pi);
      return expect(pi).not.toBeLessThan(e);
    });
    it("toBeGreaterThan和toBeLessThan相反", function() {
      var e, pi;
      pi = 3.1415926;
      e = 2.78;
      expect(pi).toBeGreaterThan(e);
      return expect(e).not.toBeGreaterThan(pi);
    });
    it("toBeCloseTo示例", function() {
      var e, pi;
      pi = 3.1415926;
      e = 2.78;
      expect(pi).not.toBeCloseTo(e, 2);
      return expect(pi).toBeCloseTo(e, 0);
    });
    return it("toThrow判断一个函数是否有抛出异常", function() {
      var bar, foo;
      foo = function() {
        return 1 + 2;
      };
      bar = function() {
        return a + 1;
      };
      expect(foo).not.toThrow();
      return expect(bar).toThrow();
    });
  });

  describe("Setup和Teardown示例", function() {
    var foo;
    foo = void 0;
    beforeEach(function() {
      foo = 0;
      return foo += 1;
    });
    afterEach(function() {
      return foo = 0;
    });
    it("测试1", function() {
      return expect(foo).toEqual(1);
    });
    return it("测试2", function() {
      expect(foo).toEqual(1);
      return expect(true).toEqual(true);
    });
  });

  describe("this用法示例", function() {
    beforeEach(function() {
      return this.foo = 0;
    });
    it("使用this共享状态", function() {
      expect(this.foo).toEqual(0);
      return this.bar = "test pollution?";
    });
    return it("下个Spec执行前this会被重置为空Object", function() {
      expect(this.foo).toEqual(0);
      return expect(this.bar).toBe(undefined);
    });
  });

  xdescribe("A spec", function() {
    var foo;
    foo = void 0;
    beforeEach(function() {
      foo = 0;
      return foo += 1;
    });
    return it("is just a function, so it can contain any code", function() {
      return expect(foo).toEqual(1);
    });
  });

  describe("Pending specs", function() {
    xit("can be declared 'xit'", function() {
      return expect(true).toBe(false);
    });
    it("can be declared with 'it' but without a function");
    return it("can be declared by calling 'pending' in the spec body", function() {
      expect(true).toBe(false);
      return pending();
    });
  });

  describe("jasmine.any", function() {
    it("matches any value", function() {
      expect({}).toEqual(jasmine.any(Object));
      return expect(12).toEqual(jasmine.any(Number));
    });
    return describe("when used with a spy", function() {
      return it("is useful for comparing arguments", function() {
        var foo;
        foo = jasmine.createSpy("foo");
        foo(12, function() {
          return true;
        });
        return expect(foo).toHaveBeenCalledWith(jasmine.any(Number), jasmine.any(Function));
      });
    });
  });

  describe("jasmine.objectContaining", function() {
    var foo;
    foo = void 0;
    beforeEach(function() {
      return foo = {
        a: 1,
        b: 2,
        bar: "baz"
      };
    });
    it("matches objects with the expect key/value pairs", function() {
      expect(foo).toEqual(jasmine.objectContaining({
        bar: "baz"
      }));
      return expect(foo).not.toEqual(jasmine.objectContaining({
        c: 37
      }));
    });
    return describe("when used with a spy", function() {
      return it("is useful for comparing arguments", function() {
        var callback;
        callback = jasmine.createSpy("callback");
        callback({
          bar: "baz"
        });
        expect(callback).toHaveBeenCalledWith(jasmine.objectContaining({
          bar: "baz"
        }));
        return expect(callback).not.toHaveBeenCalledWith(jasmine.objectContaining({
          c: 37
        }));
      });
    });
  });

  describe("A spy", function() {
    var bar, foo;
    foo = void 0;
    bar = null;
    beforeEach(function() {
      foo = {
        setBar: function(value) {
          return bar = value;
        }
      };
      spyOn(foo, "setBar");
      foo.setBar(123);
      return foo.setBar(456, "another param");
    });
    it("tracks that the spy was called", function() {
      return expect(foo.setBar).toHaveBeenCalled();
    });
    it("tracks all the arguments of its calls", function() {
      expect(foo.setBar).toHaveBeenCalledWith(123);
      return expect(foo.setBar).toHaveBeenCalledWith(456, "another param");
    });
    return it("stops all execution on a function", function() {
      console.log(foo);
      return expect(bar).toBeNull();
    });
  });

  describe("A spy, when configured to call through", function() {
    var bar, fetchedBar, foo;
    foo = void 0;
    bar = void 0;
    fetchedBar = void 0;
    beforeEach(function() {
      foo = {
        setBar: function(value) {
          return bar = value;
        },
        getBar: function() {
          return bar;
        }
      };
      spyOn(foo, "getBar").and.callThrough();
      foo.setBar(123);
      return fetchedBar = foo.getBar();
    });
    it("tracks that the spy was called", function() {
      return expect(foo.getBar).toHaveBeenCalled();
    });
    it("should not effect other functions", function() {
      return expect(bar).toEqual(123);
    });
    return it("when called returns the requested value", function() {
      return expect(fetchedBar).toEqual(123);
    });
  });

  describe("A spy, when configured to fake a return value", function() {
    var bar, fetchedBar, foo;
    foo = void 0;
    bar = void 0;
    fetchedBar = void 0;
    beforeEach(function() {
      foo = {
        setBar: function(value) {
          return bar = value;
        },
        getBar: function() {
          return bar;
        }
      };
      spyOn(foo, "getBar").and.returnValue(745);
      foo.setBar(123);
      return fetchedBar = foo.getBar();
    });
    it("tracks that the spy was called", function() {
      return expect(foo.getBar).toHaveBeenCalled();
    });
    it("should not effect other functions", function() {
      return expect(bar).toEqual(123);
    });
    return it("when called returns the requested value", function() {
      return expect(fetchedBar).toEqual(745);
    });
  });

  describe("A spy, when configured with an alternate implementation", function() {
    var bar, fetchedBar, foo;
    foo = void 0;
    bar = void 0;
    fetchedBar = void 0;
    beforeEach(function() {
      foo = {
        setBar: function(value) {
          return bar = value;
        },
        getBar: function() {
          return bar;
        }
      };
      spyOn(foo, "getBar").and.callFake(function() {
        return 1001;
      });
      foo.setBar(123);
      return fetchedBar = foo.getBar();
    });
    it("tracks that the spy was called", function() {
      return expect(foo.getBar).toHaveBeenCalled();
    });
    it("should not effect other functions", function() {
      return expect(bar).toEqual(123);
    });
    return it("when called returns the requested value", function() {
      return expect(fetchedBar).toEqual(1001);
    });
  });

  describe("A spy, when configured to throw an error", function() {
    var bar, foo;
    foo = void 0;
    bar = void 0;
    beforeEach(function() {
      foo = {
        setBar: function(value) {
          return bar = value;
        }
      };
      return spyOn(foo, "setBar").and.throwError("quux");
    });
    return it("throws the value", function() {
      return expect(function() {
        return foo.setBar(123);
      }).toThrowError("quux");
    });
  });

  describe("A spy", function() {
    var bar, foo;
    foo = void 0;
    bar = null;
    beforeEach(function() {
      foo = {
        setBar: function(value) {
          return bar = value;
        }
      };
      return spyOn(foo, "setBar").and.callThrough();
    });
    return it("can call through and then stub in the same spec", function() {
      foo.setBar(123);
      expect(bar).toEqual(123);
      foo.setBar.and.stub();
      bar = null;
      foo.setBar(123);
      return expect(bar).toBe(null);
    });
  });

  describe("Multiple spies, when created manually", function() {
    var tape;
    tape = void 0;
    beforeEach(function() {
      tape = jasmine.createSpyObj("tape", ["play", "pause", "stop", "rewind"]);
      tape.play();
      tape.pause();
      return tape.rewind(0);
    });
    it("creates spies for each requested function", function() {
      expect(tape.play).toBeDefined();
      expect(tape.pause).toBeDefined();
      expect(tape.stop).toBeDefined();
      return expect(tape.rewind).toBeDefined();
    });
    it("tracks that the spies were called", function() {
      expect(tape.play).toHaveBeenCalled();
      expect(tape.pause).toHaveBeenCalled();
      expect(tape.rewind).toHaveBeenCalled();
      return expect(tape.stop).not.toHaveBeenCalled();
    });
    return it("tracks all the arguments of its calls", function() {
      return expect(tape.rewind).toHaveBeenCalledWith(0);
    });
  });

  describe("Jasmine Spy的跟踪属性", function() {
    var bar, foo;
    foo = void 0;
    bar = null;
    beforeEach(function() {
      foo = {
        setBar: function(value) {
          return bar = value;
        }
      };
      return spyOn(foo, "setBar");
    });
    it(".calls.any()示例", function() {
      expect(foo.setBar.calls.any()).toEqual(false);
      foo.setBar();
      return expect(foo.setBar.calls.any()).toEqual(true);
    });
    it(".calls.count()示例", function() {
      expect(foo.setBar.calls.count()).toEqual(0);
      foo.setBar();
      foo.setBar();
      return expect(foo.setBar.calls.count()).toEqual(2);
    });
    it(".calls.argsFor(index)示例", function() {
      foo.setBar(123);
      foo.setBar(456, "baz");
      expect(foo.setBar.calls.argsFor(0)).toEqual([123]);
      return expect(foo.setBar.calls.argsFor(1)).toEqual([456, "baz"]);
    });
    it(".calls.allArgs()示例", function() {
      foo.setBar(123);
      foo.setBar(456, "baz");
      return expect(foo.setBar.calls.allArgs()).toEqual([[123], [456, "baz"]]);
    });
    it(".calls.all()示例", function() {
      foo.setBar(123);
      return expect(foo.setBar.calls.all()).toEqual([
        {
          object: foo,
          args: [123]
        }
      ]);
    });
    it(".calls.mostRecent()示例", function() {
      foo.setBar(123);
      foo.setBar(456, "baz");
      return expect(foo.setBar.calls.mostRecent()).toEqual({
        object: foo,
        args: [456, "baz"]
      });
    });
    it(".calls.first()示例", function() {
      foo.setBar(123);
      foo.setBar(456, "baz");
      return expect(foo.setBar.calls.first()).toEqual({
        object: foo,
        args: [123]
      });
    });
    return it(".calls.reset()示例", function() {
      foo.setBar(123);
      foo.setBar(456, "baz");
      expect(foo.setBar.calls.any()).toBe(true);
      foo.setBar.calls.reset();
      return expect(foo.setBar.calls.any()).toBe(false);
    });
  });

  describe("Jasmine Clock 测试", function() {
    var timerCallback;
    timerCallback = void 0;
    beforeEach(function() {
      timerCallback = jasmine.createSpy("timerCallback");
      return jasmine.clock().install();
    });
    afterEach(function() {
      return jasmine.clock().uninstall();
    });
    it("同步触发setTimeout", function() {
      setTimeout((function() {
        return timerCallback();
      }), 100);
      expect(timerCallback).not.toHaveBeenCalled();
      jasmine.clock().tick(101);
      return expect(timerCallback).toHaveBeenCalled();
    });
    return it("同步触发setInterval", function() {
      setInterval((function() {
        return timerCallback();
      }), 100);
      expect(timerCallback).not.toHaveBeenCalled();
      jasmine.clock().tick(101);
      expect(timerCallback.calls.count()).toEqual(1);
      jasmine.clock().tick(50);
      expect(timerCallback.calls.count()).toEqual(1);
      jasmine.clock().tick(50);
      return expect(timerCallback.calls.count()).toEqual(2);
    });
  });

  describe("Jasmine 异步测试演示", function() {
    var value;
    value = void 0;
    beforeEach(function(done) {
      return setTimeout((function() {
        value = 0;
        return done();
      }), 1);
    });
    it("should support async execution of test preparation and expectations", function(done) {
      value++;
      expect(value).toBeGreaterThan(0);
      return done();
    });
    return describe("5秒钟", function() {
      var originalTimeout;
      originalTimeout = void 0;
      beforeEach(function() {
        originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL;
        return jasmine.DEFAULT_TIMEOUT_INTERVAL = 600;
      });
      it("takes a long time", function(done) {
        return setTimeout((function() {
          return done();
        }), 500);
      });
      return afterEach(function() {
        return jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout;
      });
    });
  });

}).call(this);

/*
//@ sourceMappingURL=pdl_ajax.js.map
*/
