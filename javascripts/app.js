(function() {
  "use strict";
  var Person, board, person,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Logger = (function() {
    var Horn, instance;

    function Logger() {}

    instance = null;

    Horn = (function() {
      function Horn() {}

      Horn.prototype.info = function(message) {
        return 'INFO:\t' + message;
      };

      Horn.prototype.debug = function(message) {
        return 'DEBUG:\t' + message;
      };

      return Horn;

    })();

    Logger.info = function(message) {
      if (instance == null) {
        instance = new Horn;
      }
      return console.log(instance.info(message));
    };

    Logger.debug = function(message) {
      if (instance == null) {
        instance = new Horn;
      }
      return console.log(instance.debug(message));
    };

    return Logger;

  })();

  this.Box = (function(_super) {
    __extends(Box, _super);

    function Box() {
      return Box.__super__.constructor.apply(this, arguments);
    }

    Box.prototype.defaults = {
      boxId: '9999'
    };

    Box.prototype.initialize = function() {
      this.on('change:rect', this.rectChanged);
      this.set({
        rect: new Kinetic.Rect({
          x: 0,
          y: 0,
          width: 100,
          height: 50,
          fill: "green"
        })
      });
      this.set({
        title: new Kinetic.Text({
          x: this.get('rect').x() + this.get('rect').width() / 2 - 5,
          y: this.get('rect').y() + this.get('rect').height() / 2 - 5,
          fontSize: 14,
          fontFamily: "Calibri",
          fill: "white",
          text: this.get('boxId')
        })
      });
      this.set({
        group: new Kinetic.Group({
          x: 4,
          y: 8,
          rotation: 0
        })
      });
      this.get('group').add(this.get('rect'));
      this.get('group').add(this.get('title'));
      Logger.debug('Box: Generate a new box.');
      return this.box().on("dblclick", (function(_this) {
        return function() {
          _this.box().rotation(45);
          return Logger.debug("@box().rotation(45)");
        };
      })(this));
    };

    Box.prototype.setTitleName = function(newTitle) {
      return this.get('title').setText(newTitle);
    };

    Box.prototype.getTitleName = function() {
      return this.get('title').text();
    };

    Box.prototype.setXPosition = function(x) {
      return this.get('group').setX(x);
    };

    Box.prototype.getXPosition = function() {
      return this.get('group').x();
    };

    Box.prototype.setYPosition = function(y) {
      return this.get('group').setY(y);
    };

    Box.prototype.getYPosition = function() {
      return this.get('group').y();
    };

    Box.prototype.setHeight = function(height) {
      return this.get('rect').setHeight(height);
    };

    Box.prototype.getHeight = function() {
      return this.get('rect').height();
    };

    Box.prototype.setWidth = function(width) {
      return this.get('rect').setWidth(width);
    };

    Box.prototype.getWidth = function() {
      return this.get('rect').width();
    };

    Box.prototype.getPointA = function() {
      var pointX;
      return pointX = {
        x: this.getXPosition(),
        y: this.getYPosition()
      };
    };

    Box.prototype.getPointB = function() {
      var pointB;
      return pointB = {
        x: this.getXPosition() + this.get('rect').getWidth(),
        y: this.getYPosition()
      };
    };

    Box.prototype.getPointC = function() {
      var pointC;
      return pointC = {
        x: this.getXPosition(),
        y: this.getYPosition() + this.get('rect').getHeight()
      };
    };

    Box.prototype.getPointD = function() {
      var pointC;
      return pointC = {
        x: this.getXPosition() + this.get('rect').getWidth(),
        y: this.getYPosition() + this.get('rect').getHeight()
      };
    };

    Box.prototype.rectChanged = function() {
      return Logger.debug('box model changed by rect.');
    };

    Box.prototype.box = function() {
      return this.get('group');
    };

    Box.prototype.printPoints = function() {
      return Logger.info(("PointA(x:" + (this.getPointA().x) + ",y:" + (this.getPointA().y) + ") ") + ("PointB(x:" + (this.getPointB().x) + ",y:" + (this.getPointB().y) + ") ") + ("PointC(x:" + (this.getPointC().x) + ",y:" + (this.getPointC().y) + ") ") + ("PointD(x:" + (this.getPointD().x) + ",y:" + (this.getPointD().y) + ") "));
    };

    return Box;

  })(Backbone.Model);

  this.Boxes = (function(_super) {
    __extends(Boxes, _super);

    function Boxes() {
      this.right = __bind(this.right, this);
      this.left = __bind(this.left, this);
      this.down = __bind(this.down, this);
      this.up = __bind(this.up, this);
      this.removeCurrentBox = __bind(this.removeCurrentBox, this);
      this.addNewBox = __bind(this.addNewBox, this);
      return Boxes.__super__.constructor.apply(this, arguments);
    }

    Boxes.prototype.model = Box;

    Boxes.prototype.initialize = function(layer, zone) {
      this.layer = layer;
      this.zone = zone;
      this.on('add', this.showCurrentBoxPanel);
      this.currentBox = new Box;
      this.availableNewBoxId = 1;
      return this.flash = "Initialized completed!";
    };

    Boxes.prototype.addNewBox = function() {
      var newBox;
      newBox = new Box;
      newBox.setXPosition(newBox.getXPosition() + this.availableNewBoxId * 4);
      newBox.setYPosition(newBox.getYPosition() + this.availableNewBoxId * 4);
      newBox.setTitleName(this.availableNewBoxId);
      newBox.set('boxId', this.availableNewBoxId);
      newBox.box().on("click", (function(_this) {
        return function() {
          Logger.debug("box" + (newBox.getTitleName()) + " clicked!");
          return _this.updateCurrentBox(newBox);
        };
      })(this));
      this.add(newBox);
      this.draw();
      this.updateCurrentBox(newBox);
      this.availableNewBoxId += 1;
      return Logger.debug("@availableNewBoxId:\t" + this.availableNewBoxId);
    };

    Boxes.prototype.removeCurrentBox = function() {
      if (this.length === 0) {
        this.flash = 'There is no box.';
      } else {
        this.currentBox.get('group').destroy();
        this.remove(this.currentBox);
        this.currentBox = this.last();
      }
      this.draw();
      if (this.length === 0) {
        this.flash = 'There is no box.';
      }
      this.showCurrentBoxPanel();
      return Logger.debug("remove button clicked!");
    };

    Boxes.prototype.testCollision = function() {
      var result;
      result = _.reduce(this.models, (function(status, box) {
        if (this.currentBox.getTitleName() !== box.getTitleName()) {
          Logger.debug("testCollision " + (this.currentBox.getTitleName()) + " " + (box.getTitleName()));
          return status || this.testBoxCollision(box, this.currentBox);
        } else {
          return status;
        }
      }), false, this);
      return Logger.debug("testCollision: " + result);
    };

    Boxes.prototype.draw = function() {
      var box, _i, _len, _ref;
      _ref = this.models;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        box = _ref[_i];
        this.layer.add(box.box());
      }
      return this.layer.draw();
    };

    Boxes.prototype.testBoxCollision = function(boxA, boxB) {
      var boxABottom, boxALeft, boxARight, boxATop, boxBBottom, boxBLeft, boxBRight, boxBTop, status;
      status = false;
      boxATop = boxA.getXPosition();
      boxABottom = boxA.getYPosition() + boxA.getHeight();
      boxALeft = boxA.getXPosition();
      boxARight = boxA.getXPosition() + boxA.getWidth();
      boxBTop = boxB.getYPosition();
      boxBBottom = boxB.getYPosition() + boxB.getHeight();
      boxBLeft = boxB.getXPosition();
      boxBRight = boxB.getXPosition() + boxB.getWidth();
      if (!(boxABottom < boxBTop || boxATop > boxBBottom || boxALeft > boxBRight || boxARight < boxBLeft)) {
        status = true;
      }
      return status;
    };

    Boxes.prototype.updateCurrentBox = function(newBox) {
      this.currentBox = newBox;
      return rivets.bind($('.box'), {
        box: newBox
      });
    };

    Boxes.prototype.showCurrentBoxPanel = function() {
      Logger.debug("showCurrentBoxPanel: " + this.length);
      if (this.length === 0) {
        return $('.direction').css('display', 'none');
      } else {
        return $('.direction').css('display', 'inline');
      }
    };

    Boxes.prototype.up = function() {
      Logger.debug("@currentBox:\t" + this.currentBox.getTitleName());
      this.currentBox.setYPosition(this.currentBox.getYPosition() - 4);
      if (this.validateZone(this.currentBox)) {
        this.draw();
      } else {
        this.currentBox.setYPosition(this.currentBox.getYPosition() + 4);
        this.flash = "Box" + (this.currentBox.getTitleName()) + " Y " + (this.currentBox.getYPosition()) + " cannot be moved UP!";
      }
      this.currentBox.printPoints();
      return this.testCollision();
    };

    Boxes.prototype.down = function() {
      Logger.debug("@currentBox:\t" + this.currentBox.getTitleName());
      this.currentBox.setYPosition(this.currentBox.getYPosition() + 4);
      if (this.validateZone(this.currentBox)) {
        this.draw();
      } else {
        this.currentBox.setYPosition(this.currentBox.getYPosition() - 4);
        this.flash = "Box" + (this.currentBox.getTitleName()) + " cannot be moved DOWN!";
      }
      this.currentBox.printPoints();
      return this.testCollision();
    };

    Boxes.prototype.left = function() {
      Logger.debug("@currentBox:\t" + this.currentBox.getTitleName());
      this.currentBox.setXPosition(this.currentBox.getXPosition() - 4);
      if (this.validateZone(this.currentBox)) {
        this.draw();
      } else {
        this.currentBox.setXPosition(this.currentBox.getXPosition() + 4);
        this.flash = "Box" + (this.currentBox.getTitleName()) + " cannot be moved LEFT!";
      }
      this.currentBox.printPoints();
      return this.testCollision();
    };

    Boxes.prototype.right = function() {
      Logger.debug("@currentBox:\t" + this.currentBox.getTitleName());
      this.currentBox.setXPosition(this.currentBox.getXPosition() + 4);
      if (this.validateZone(this.currentBox)) {
        this.draw();
      } else {
        this.currentBox.setXPosition(this.currentBox.getXPosition() - 4);
        this.flash = "Box" + (this.currentBox.getTitleName()) + " cannot be moved RIGHT!";
      }
      this.currentBox.printPoints();
      return this.testCollision();
    };

    Boxes.prototype.validateZone = function(box) {
      var result;
      result = _.reduce([box.getPointA(), box.getPointB(), box.getPointC(), box.getPointD()], (function(status, point) {
        return status && this.validateZoneX(point) && this.validateZoneY(point);
      }), true, this);
      Logger.debug("validresult:\t " + result);
      return result;
    };

    Boxes.prototype.validateZoneX = function(point) {
      var _ref;
      Logger.debug("validateZoneX: point.x " + point.x + ", @zone.x " + this.zone.x);
      return (0 <= (_ref = point.x) && _ref <= this.zone.x);
    };

    Boxes.prototype.validateZoneY = function(point) {
      var _ref;
      Logger.debug("validateZoneY: point.y " + point.y + ", @zone.x " + this.zone.y);
      return (0 <= (_ref = point.y) && _ref <= this.zone.y);
    };

    return Boxes;

  })(Backbone.Collection);

  this.StackBoard = (function() {
    function StackBoard() {
      this.stage = new Kinetic.Stage({
        container: "canvas_container",
        width: 400,
        height: 720
      });
      this.zone = {
        x: 298,
        y: 360
      };
      this.layer = new Kinetic.Layer();
      this.stage.add(this.layer);
      Logger.debug("StackBoard: Stage Initialized!");
      Logger.info("StackBoard: Initialized!");
      this.boxes = new Boxes(this.layer, this.zone);
      this.boxes.shift();
      rivets.bind($('.boxes'), {
        boxes: this.boxes
      });
    }

    return StackBoard;

  })();

  board = new StackBoard;

  rivets.config.handler = function(context, ev, binding) {
    if (binding.model instanceof binding.model.____) {
      return this.call(binding.model, ev, context);
    } else {
      return this.call(context, ev, binding.view.models);
    }
  };

  rivets.binders.input = {
    publishes: true,
    routine: rivets.binders.value.routine,
    bind: function(el) {
      el.addEventListener("input", this.publish);
    },
    unbind: function(el) {
      el.removeEventListener("input", this.publish);
    }
  };

  rivets.formatters.rupee = function(val) {
    return "$ " + val;
  };

  Person = function() {
    this.name = "Narendra";
    this.job = {};
    this.job.task = "Engineer";
    this.____ = Person;
  };

  Person.prototype = {
    show: function() {
      this.display();
    },
    change: function() {
      this.name = "Deepak";
      this.job.task = "Playing";
    },
    display: function() {
      alert(JSON.stringify(this));
    },
    total: function() {
      return window.parseInt(this.price) * window.parseInt(this.quantity);
    }
  };

  person = new Person();

  rivets.bind(document.querySelector("#asdasd"), {
    scope: person
  });

}).call(this);
