(function() {
  var board,
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
          x: 10,
          y: 20,
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
          x: 10,
          y: 20,
          rotation: 0
        })
      });
      this.get('group').add(this.get('rect'));
      this.get('group').add(this.get('title'));
      Logger.debug('Box: Generate a new box.');
      return this.get('group').on("click", function() {
        return Logger.debug(this.getX());
      });
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

    Box.prototype.rectChanged = function() {
      return Logger.debug('box model changed by rect.');
    };

    Box.prototype.box = function() {
      return this.get('group');
    };

    return Box;

  })(Backbone.Model);

  this.Boxes = (function(_super) {
    __extends(Boxes, _super);

    function Boxes() {
      this.showCurrentBox = __bind(this.showCurrentBox, this);
      this.addNewBox = __bind(this.addNewBox, this);
      return Boxes.__super__.constructor.apply(this, arguments);
    }

    Boxes.prototype.model = Box;

    Boxes.prototype.initialize = function(layer) {
      this.layer = layer;
      this.on('add', this.showCurrentBox);
      this.currentBox = new Box;
      this.currentNewBoxId = 1;
      this.flash = "Initialized completed!";
      return this.flash = 'test:\t' + this.currentBox.get('boxId');
    };

    Boxes.prototype.addNewBox = function() {
      var newBox;
      Logger.debug('show currentbox x:\t' + this.currentBox.getXPosition());
      newBox = new Box;
      newBox.setXPosition(newBox.getXPosition() + this.currentNewBoxId * 10);
      newBox.setYPosition(newBox.getYPosition() + this.currentNewBoxId * 10);
      newBox.setTitleName(this.currentNewBoxId);
      newBox.set('boxId', this.currentNewBoxId);
      this.currentBox = newBox;
      this.add(newBox);
      this.draw();
      this.currentBox = new Box;
      return this.currentNewBoxId += 1;
    };

    Boxes.prototype.testCollision = function() {};

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

    Boxes.prototype.showCurrentBox = function() {
      rivets.bind($('.box'), {
        box: this.currentBox
      });
      Logger.debug('show currentbox x:\t' + this.currentBox.getXPosition());
      if (_.isEmpty(this.models)) {
        return $('.box').css('display', 'none');
      } else {
        return $('.box').css('display', 'block');
      }
    };

    return Boxes;

  })(Backbone.Collection);

  this.StackBoard = (function() {
    function StackBoard() {
      this.stage = new Kinetic.Stage({
        container: "canvas_container",
        width: 300,
        height: 360
      });
      this.layer = new Kinetic.Layer();
      this.stage.add(this.layer);
      Logger.debug("StackBoard: Stage Initialized!");
      Logger.info("StackBoard: Initialized!");
      this.boxes = new Boxes(this.layer);
      this.boxes.shift();
      rivets.bind($('.boxes'), {
        boxes: this.boxes
      });
    }

    return StackBoard;

  })();

  board = new StackBoard;

}).call(this);
