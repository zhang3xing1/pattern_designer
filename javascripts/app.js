(function() {
  var CollisionPair, CollisionUtil, box, canvasZone, pallet, params,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  rivets.adapters[":"] = {
    subscribe: function(obj, keypath, callback) {
      obj.on("change:" + keypath, callback);
    },
    unsubscribe: function(obj, keypath, callback) {
      obj.off("change:" + keypath, callback);
    },
    read: function(obj, keypath) {
      return obj.get(keypath);
    },
    publish: function(obj, keypath, value) {
      obj.set(keypath, value);
    }
  };

  this.Logger = (function() {
    var Horn, instance, statuses;

    function Logger() {}

    instance = null;

    statuses = ['info', 'debug', "dev"];

    statuses = [];

    Horn = (function() {
      function Horn() {}

      Horn.prototype.info = function(message) {
        return 'INFO:\t' + message;
      };

      Horn.prototype.debug = function(message) {
        return 'DEBUG:\t' + message;
      };

      Horn.prototype.dev = function(message) {
        return 'Dev:\t' + message;
      };

      return Horn;

    })();

    Logger.info = function(message) {
      if (_.contains(statuses, 'info')) {
        if (instance == null) {
          instance = new Horn;
        }
        return console.log(instance.info(message));
      }
    };

    Logger.debug = function(message) {
      if (_.contains(statuses, 'debug')) {
        if (instance == null) {
          instance = new Horn;
        }
        return console.log(instance.debug(message));
      }
    };

    Logger.dev = function(message) {
      if (_.contains(statuses, 'dev')) {
        if (instance == null) {
          instance = new Horn;
        }
        return console.log(instance.dev(message));
      }
    };

    return Logger;

  })();

  this.Box = (function(_super) {
    __extends(Box, _super);

    function Box() {
      return Box.__super__.constructor.apply(this, arguments);
    }

    Box.prototype.defaults = {
      boxId: 'nullID',
      collisionStatus: false,
      moveOffset: 4,
      rotate: 0
    };

    Box.prototype.initialize = function(params) {
      this.on('change:rect', this.rectChanged);
      this.set({
        innerBox: {
          x: params.x,
          y: params.y,
          width: params.width,
          height: params.height
        }
      });
      this.set({
        rect: new Kinetic.Rect({
          x: 0,
          y: 0,
          width: this.get('innerBox').width,
          height: this.get('innerBox').height
        })
      });
      this.set({
        title: new Kinetic.Text({
          x: this.get('rect').x() + this.get('rect').width() / 2 - 5,
          y: this.get('rect').y() + this.get('rect').height() / 2 + 5,
          fontSize: 14,
          fontFamily: "Calibri",
          fill: "white",
          text: this.get('boxId'),
          scaleY: -1
        })
      });
      this.set({
        group: new Kinetic.Group({
          x: 0,
          y: 0
        })
      });
      this.get('group').add(this.get('rect'));
      this.get('group').add(this.get('title'));
      params.minDistance = $("#minDistance").val();
      if (params.minDistance > 0) {
        this.set({
          minDistance: params.minDistance
        });
        this.set({
          outerBox: {
            x: this.get('innerBox').x - params.minDistance,
            y: this.get('innerBox').y - params.minDistance,
            width: this.get('innerBox').width + 2 * params.minDistance,
            height: this.get('innerBox').height + 2 * params.minDistance
          }
        });
        this.set({
          outerRect: new Kinetic.Rect({
            x: this.get('outerBox').x,
            y: this.get('outerBox').y,
            width: this.get('outerBox').width,
            height: this.get('outerBox').height,
            strokeRed: 38,
            strokeGreen: 49,
            strokeBlue: 9,
            strokeAlpha: 0.5
          })
        });
        this.get('outerRect').dash([4, 5]);
        this.get('group').add(this.get('outerRect'));
      }
      return Logger.debug('Box: Generate a new box.');
    };

    Box.prototype.hasOuterRect = function() {
      return this.get('minDistance') > 0;
    };

    Box.prototype.getBoxId = function() {
      return this.get('boxId');
    };

    Box.prototype.getMoveOffset = function() {
      var offset;
      offset = Number($("#ex8").val()) % 99;
      if (offset % 99 > 0) {
        this.set('moveOffset', offset % 99);
        return offset % 99;
      } else {
        return 4;
      }
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

    Box.prototype.getXPosition = function(options) {
      if (options == null) {
        options = {
          innerOrOuter: 'inner'
        };
      }
      if (options.innerOrOuter === 'outer' && this.hasOuterRect()) {
        return this.get('group').x() - this.get('minDistance');
      } else {
        return this.get('group').x();
      }
    };

    Box.prototype.setYPosition = function(y) {
      return this.get('group').setY(y);
    };

    Box.prototype.getYPosition = function(options) {
      if (options == null) {
        options = {
          innerOrOuter: 'inner'
        };
      }
      if (options.innerOrOuter === 'outer' && this.hasOuterRect()) {
        return this.get('group').y() - this.get('minDistance');
      } else {
        return this.get('group').y();
      }
    };

    Box.prototype.setHeight = function(height) {
      return this.get('rect').setHeight(height);
    };

    Box.prototype.getHeight = function(options) {
      if (options == null) {
        options = {
          innerOrOuter: 'inner'
        };
      }
      if (options.innerOrOuter === 'outer' && this.hasOuterRect()) {
        return this.get('rect').height() + this.get('minDistance') * 2;
      } else {
        return this.get('rect').height();
      }
    };

    Box.prototype.setWidth = function(width) {
      return this.get('rect').setWidth(width);
    };

    Box.prototype.getWidth = function(options) {
      if (options == null) {
        options = {
          innerOrOuter: 'inner'
        };
      }
      if (options.innerOrOuter === 'outer' && this.hasOuterRect()) {
        return this.get('rect').width() + this.get('minDistance') * 2;
      } else {
        return this.get('rect').width();
      }
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

    Box.prototype.updateTitle = function(newTitle) {
      return this.get('title').setText(newTitle);
    };

    Box.prototype.rectChanged = function() {
      return Logger.debug('box model changed by rect.');
    };

    Box.prototype.box = function() {
      return this.get('group');
    };

    Box.prototype.makeCollisionStatus = function() {
      Logger.dev("box" + (this.getTitleName()) + ": makeCollisionStatus");
      return this.set('collisionStatus', true);
    };

    Box.prototype.makeUnCollisionStatus = function() {
      Logger.dev("box" + (this.getTitleName()) + ": makeUnCollisionStatus");
      return this.set('collisionStatus', false);
    };

    Box.prototype.changeFillColor = function() {
      if (this.get('collisionStatus')) {
        this.get('rect').fillRed(82);
        this.get('rect').fillGreen(1);
        return this.get('rect').fillBlue(246);
      } else {
        this.get('rect').fillRed(82);
        this.get('rect').fillGreen(221);
        return this.get('rect').fillBlue(246);
      }
    };

    Box.prototype.printPoints = function() {
      return Logger.debug(("PointA(x:" + (this.getPointA().x) + ",y:" + (this.getPointA().y) + ") ") + ("PointB(x:" + (this.getPointB().x) + ",y:" + (this.getPointB().y) + ") ") + ("PointC(x:" + (this.getPointC().x) + ",y:" + (this.getPointC().y) + ") ") + ("PointD(x:" + (this.getPointD().x) + ",y:" + (this.getPointD().y) + ") "));
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

    Boxes.prototype.initialize = function(params) {
      this.layer = params.layer;
      this.zone = params.zone;
      this.box_params = params.box;
      this.on('add', this.showCurrentBoxPanel);
      this.on('all', this.draw);
      this.collisionUtil = new CollisionUtil;
      this.currentBox = new Box(this.box_params);
      this.availableNewBoxId = 1;
      return this.flash = "Initialized completed!";
    };

    Boxes.prototype.pprint = function() {
      return _.reduce(this.models, (function(str, box) {
        return "" + str + " box" + (box.getBoxId());
      }), "");
    };

    Boxes.prototype.updateCollisionStatus = function(options) {
      return this.collisionUtil.updateRelation(options);
    };

    Boxes.prototype.deleteCollisionWith = function(box) {
      if (box == null) {
        box = this.currentBox;
      }
      return this.collisionUtil.deleteCollisionWith(box, this.models);
    };

    Boxes.prototype.testCollisionBetween = function(boxA, boxB) {
      return this.collisionUtil.testCollisionBetween(boxA, boxB, {
        collisionType: 'outer-outer'
      });
    };

    Boxes.prototype.addNewBox = function() {
      var newBox;
      newBox = new Box(this.box_params);
      newBox.setXPosition(Math.min(newBox.getXPosition() + this.availableNewBoxId * newBox.getMoveOffset(), this.zone.width - newBox.getWidth()));
      newBox.setYPosition(Math.min(newBox.getYPosition() + this.availableNewBoxId * newBox.getMoveOffset(), this.zone.height - newBox.getHeight()));
      newBox.setTitleName(this.availableNewBoxId);
      newBox.set('boxId', this.availableNewBoxId);
      newBox.box().on("click", (function(_this) {
        return function() {
          Logger.debug("box" + (newBox.getTitleName()) + " clicked!");
          _this.flash = "box" + (newBox.getTitleName()) + " selected!";
          return _this.updateCurrentBox(newBox);
        };
      })(this));
      this.add(newBox);
      this.updateCurrentBox(newBox);
      this.flash = "box" + (this.currentBox.getTitleName()) + " selected!";
      this.availableNewBoxId += 1;
      return this.testCollision();
    };

    Boxes.prototype.removeCurrentBox = function() {
      if (this.length === 0) {
        this.flash = 'There is no box.';
      } else {
        this.deleteCollisionWith();
        this.currentBox.get('group').destroy();
        this.remove(this.currentBox);
        if (this.length === 0) {
          this.currentBox = new Box(this.box_params);
          this.flash = 'There is no box.';
        } else {
          this.currentBox = this.last();
        }
      }
      this.draw();
      this.showCurrentBoxPanel();
      this.flash = "box" + (this.currentBox.getTitleName()) + " selected!";
      return Logger.dev("remove button clicked!");
    };

    Boxes.prototype.testCollision = function() {
      var result;
      Logger.debug("...Collision start...");
      result = false;
      result = _.reduce(this.models, (function(status, box) {
        if (this.currentBox.getBoxId() !== box.getBoxId() && this.currentBox.getBoxId() !== 'nullID') {
          return this.testCollisionBetween(this.currentBox, box) || status;
        } else {
          return status;
        }
      }), false, this);
      result;
      Logger.debug("...Collision result: " + result);
      return this.draw();
    };

    Boxes.prototype.draw = function() {
      var box, index;
      index = 0;
      while (index < this.models.length) {
        box = this.models[index];
        Logger.dev("In draw: Box" + (box.getTitleName()) + ".collision=" + (box.get('collisionStatus')));
        box.changeFillColor();
        box.updateTitle(index + 1);
        this.layer.add(box.box());
        index += 1;
      }
      return this.layer.draw();
    };

    Boxes.prototype.updateCurrentBox = function(newBox) {
      if (newBox == null) {
        newBox = this.currentBox;
      }
      this.currentBox = newBox;
      return rivets.bind($('.box'), {
        box: newBox
      });
    };

    Boxes.prototype.showCurrentBoxPanel = function() {
      rivets.bind($('.box'), {
        box: this.currentBox
      });
      Logger.dev("showCurrentBoxPanel: Box number: " + this.length + "; ");
      Logger.dev("In Boxes: " + (this.pprint()) + "; ");
      this.pprint();
      if (this.length === 0) {
        return $('.panel').css('display', 'none');
      } else {
        return $('.panel').css('display', 'block');
      }
    };

    Boxes.prototype.up = function() {
      Logger.debug("@currentBox:\t" + this.currentBox.getTitleName());
      this.currentBox.setYPosition(this.currentBox.getYPosition() - this.currentBox.getMoveOffset());
      if (!this.validateZone(this.currentBox)) {
        this.currentBox.setYPosition(0);
        this.flash = "Box" + (this.currentBox.getTitleName()) + " cannot be moved UP!";
      } else {
        this.flash = "box" + (this.currentBox.getTitleName()) + " selected!";
      }
      this.testCollision();
      return this.updateCurrentBox();
    };

    Boxes.prototype.down = function() {
      Logger.debug("@currentBox:\t" + this.currentBox.getTitleName());
      this.currentBox.setYPosition(this.currentBox.getYPosition() + this.currentBox.getMoveOffset());
      if (!this.validateZone(this.currentBox)) {
        this.currentBox.setYPosition(this.zone.height - this.currentBox.getHeight());
        this.flash = "Box" + (this.currentBox.getTitleName()) + " cannot be moved DOWN!";
      } else {
        this.flash = "box" + (this.currentBox.getTitleName()) + " selected!";
      }
      this.testCollision();
      return this.updateCurrentBox();
    };

    Boxes.prototype.left = function() {
      Logger.debug("@currentBox:\t" + this.currentBox.getTitleName());
      this.currentBox.setXPosition(this.currentBox.getXPosition() - this.currentBox.getMoveOffset());
      if (!this.validateZone(this.currentBox)) {
        this.currentBox.setXPosition(0);
        this.flash = "Box" + (this.currentBox.getTitleName()) + " cannot be moved LEFT!";
      } else {
        this.flash = "box" + (this.currentBox.getTitleName()) + " selected!";
      }
      this.testCollision();
      return this.updateCurrentBox();
    };

    Boxes.prototype.right = function() {
      Logger.debug("@currentBox:\t" + this.currentBox.getTitleName());
      Logger.debug("@currentBox:\t" + this.currentBox.getXPosition());
      this.currentBox.setXPosition(this.currentBox.getXPosition() + this.currentBox.getMoveOffset());
      if (!this.validateZone(this.currentBox)) {
        this.currentBox.setXPosition(this.zone.width - this.currentBox.getWidth());
        this.flash = "Box" + (this.currentBox.getTitleName()) + " cannot be moved RIGHT!";
      } else {
        this.flash = "box" + (this.currentBox.getTitleName()) + " selected!";
      }
      this.testCollision();
      return this.updateCurrentBox();
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
      Logger.debug("validateZoneX: point.x " + point.x + ", @zone.width " + this.zone.width);
      return (0 <= (_ref = point.x) && _ref <= this.zone.width);
    };

    Boxes.prototype.validateZoneY = function(point) {
      var _ref;
      Logger.debug("validateZoneY: point.y " + point.y + ", @zone.width " + this.zone.height);
      return (0 <= (_ref = point.y) && _ref <= this.zone.height);
    };

    return Boxes;

  })(Backbone.Collection);

  CollisionPair = (function(_super) {
    var Relation, RelationCollection;

    __extends(CollisionPair, _super);

    function CollisionPair() {
      return CollisionPair.__super__.constructor.apply(this, arguments);
    }

    Relation = (function(_super1) {
      __extends(Relation, _super1);

      function Relation() {
        return Relation.__super__.constructor.apply(this, arguments);
      }

      Relation.prototype.defaults = {
        status: false
      };

      Relation.prototype.initialize = function(boxId) {
        return this.set({
          boxId: boxId
        });
      };

      Relation.prototype.pprint = function() {
        return "" + (this.get('boxId')) + " " + (this.get('status'));
      };

      return Relation;

    })(Backbone.Model);

    RelationCollection = (function(_super1) {
      __extends(RelationCollection, _super1);

      function RelationCollection() {
        return RelationCollection.__super__.constructor.apply(this, arguments);
      }

      RelationCollection.prototype.model = Relation;

      RelationCollection.prototype.pprint = function() {
        return _.reduce(this.models, (function(str, aRelation) {
          return "" + str + " | " + (aRelation.pprint());
        }), "");
      };

      RelationCollection.prototype.findRelationWith = function(boxId) {
        var aRelation;
        aRelation = _.find(this.models, function(aRelation) {
          return aRelation.get('boxId') === boxId;
        });
        if (aRelation === void 0) {
          aRelation = new Relation(boxId);
          this.add(aRelation);
        }
        return aRelation;
      };

      return RelationCollection;

    })(Backbone.Collection);

    CollisionPair.prototype.initialize = function(boxId) {
      return this.boxId = boxId;
    };

    CollisionPair.prototype.findRelationWith = function(boxId) {
      return this.get('relations').findRelationWith(boxId);
    };

    CollisionPair.prototype.pprint = function() {
      return "box" + this.boxId + " " + (this.get('relations').pprint());
    };

    CollisionPair.prototype.isRelationEmpty = function() {
      return this.get('relations') === void 0;
    };

    CollisionPair.prototype.isCollisionWith = function(boxId) {
      if (this.isRelationEmpty()) {
        this.makeUnCollisionRelationWith(boxId);
      }
      return this.findRelationWith(boxId).get('status');
    };

    CollisionPair.prototype.makeCollisionRelationWith = function(boxId) {
      var relations;
      if (this.get('boxId') === boxId) {
        return;
      }
      if (this.isRelationEmpty()) {
        this.set({
          relations: new RelationCollection
        });
        relations = this.get('relations');
        relations.add(new Relation(boxId));
        relations.findRelationWith(boxId).set('status', true);
      } else {
        relations = this.get('relations');
        relations.findRelationWith(boxId).set('status', true);
      }
    };

    CollisionPair.prototype.makeUnCollisionRelationWith = function(boxId) {
      var relations;
      if (this.get('boxId') === boxId) {
        return;
      }
      if (this.isRelationEmpty()) {
        this.set({
          relations: new RelationCollection
        });
        relations = this.get('relations');
        relations.add(new Relation(boxId));
      } else {
        relations = this.get('relations');
        relations.findRelationWith(boxId).set('status', false);
      }
    };

    CollisionPair.prototype.makeUnCollisionRelationAll = function() {
      var relations;
      relations = this.get('relations');
      if (relations !== void 0) {
        return _.each(relations.models, (function(aRelation) {
          aRelation.set('status', false);
          return Logger.dev("In makeUnCollisionRelationAll: Pair" + this.boxId + ", withBox" + (aRelation.get('boxId')) + " " + (aRelation.get('status')));
        }), this);
      }
    };

    return CollisionPair;

  })(Backbone.Model);

  CollisionUtil = (function(_super) {
    __extends(CollisionUtil, _super);

    function CollisionUtil() {
      return CollisionUtil.__super__.constructor.apply(this, arguments);
    }

    CollisionUtil.prototype.model = CollisionPair;

    CollisionUtil.prototype.initialize = function() {};

    CollisionUtil.prototype.pprint = function() {
      return _.each(this.models, function(pair) {
        return Logger.dev("In CollisionUtil: pair." + (pair.pprint()));
      });
    };

    CollisionUtil.prototype.findPair = function(boxId) {
      var aPair;
      aPair = _.find(this.models, function(pair) {
        return pair.boxId === boxId;
      });
      return aPair;
    };

    CollisionUtil.prototype.removeCollisionPair = function(boxA, boxB) {
      Logger.dev("removeCollisionPair: box" + (boxA.getBoxId()) + ", box" + (boxB.getBoxId()));
      this.updateCollisionRelationBetween({
        action: 'remove',
        boxAId: boxA.getBoxId(),
        boxBId: boxB.getBoxId()
      });
      Logger.dev("@isCollisionInclude(boxA) " + (this.isCollisionInclude(boxA)) + "  isCollisionInclude(boxB) " + (this.isCollisionInclude(boxB)));
      if (!this.isCollisionInclude(boxA)) {
        boxA.makeUnCollisionStatus();
      }
      if (!this.isCollisionInclude(boxB)) {
        return boxB.makeUnCollisionStatus();
      }
    };

    CollisionUtil.prototype.addCollisionPair = function(boxA, boxB) {
      Logger.dev("addCollisionPair: box" + (boxA.getBoxId()) + ", box" + (boxB.getBoxId()));
      this.updateCollisionRelationBetween({
        action: 'add',
        boxAId: boxA.getBoxId(),
        boxBId: boxB.getBoxId()
      });
      boxA.makeCollisionStatus();
      return boxB.makeCollisionStatus();
    };

    CollisionUtil.prototype.deleteCollisionWith = function(box, boxes) {
      var toDeletedBoxId;
      toDeletedBoxId = box.getBoxId();
      this.updateCollisionRelationBetween({
        action: 'delete',
        boxId: toDeletedBoxId
      });
      return _.each(boxes, (function(aBox) {
        if (this.isCollisionInclude(aBox)) {
          return aBox.makeCollisionStatus();
        } else {
          return aBox.makeUnCollisionStatus();
        }
      }), this);
    };

    CollisionUtil.prototype.updateCollisionRelationBetween = function(options) {
      var boxAId, boxAPair, boxBId, boxBPair, toDeletedBoxId, toDeletedBoxPair;
      boxAId = options.boxAId;
      boxBId = options.boxBId;
      toDeletedBoxId = options.boxId;
      if (options.action === 'add') {
        boxAPair = this.findPair(boxAId);
        boxBPair = this.findPair(boxBId);
        if (boxAPair === void 0) {
          boxAPair = new CollisionPair(boxAId);
          this.add(boxAPair);
        }
        if (boxBPair === void 0) {
          boxBPair = new CollisionPair(boxBId);
          this.add(boxBPair);
        }
        Logger.dev("CollisionUtil:\t addPair:  box" + boxAPair.boxId + " box" + boxBPair.boxId);
        boxAPair.makeCollisionRelationWith(boxBId);
        boxBPair.makeCollisionRelationWith(boxAId);
      } else if (options.action === 'remove') {
        boxAPair = this.findPair(boxAId);
        boxBPair = this.findPair(boxBId);
        if (boxAPair === void 0) {
          boxAPair = new CollisionPair(boxAId);
          this.add(boxAPair);
        }
        if (boxBPair === void 0) {
          boxBPair = new CollisionPair(boxBId);
          this.add(boxBPair);
        }
        Logger.dev("CollisionUtil:\t removePair:  box" + boxAPair.boxId + " box" + boxBPair.boxId);
        boxAPair.makeUnCollisionRelationWith(boxBId);
        boxBPair.makeUnCollisionRelationWith(boxAId);
      } else if (options.action === 'delete') {
        toDeletedBoxPair = this.findPair(toDeletedBoxId);
        _.each(this.models, (function(pair) {
          if (pair.boxId === toDeletedBoxId) {
            this.remove(toDeletedBoxPair);
          } else {
            pair.makeUnCollisionRelationWith(toDeletedBoxId);
          }
          Logger.dev("In delete: toDeletedBoxId: " + toDeletedBoxId);
          Logger.dev("In delete: pair Relation: " + (pair.pprint()));
          return Logger.dev("In delete: toDeletedBoxPair Relation: " + (toDeletedBoxPair.pprint()));
        }), this);
      } else if (options.action === 'changeID') {
        Logger.dev("CollisionUtil:\t changeID box");
      }
      Logger.dev("---->Show pair status: ");
      this.pprint();
      return Logger.dev("<----Show pair status: ");
    };

    CollisionUtil.prototype.isCollisionInclude = function(boxA) {
      var boxAId, result, status;
      boxAId = boxA.getBoxId();
      result = _.filter(this.models, function(pair) {
        return pair.boxId !== boxAId && pair.isCollisionWith(boxAId);
      });
      return status = result.length > 0;
    };

    CollisionUtil.prototype.testCollisionBetween = function(boxA, boxB, options) {
      var boxABottom, boxALeft, boxARight, boxATop, boxBBottom, boxBLeft, boxBRight, boxBTop, status;
      if (options == null) {
        options = {
          collisionType: 'inner-inner'
        };
      }
      status = false;
      if (options.collisionType === 'inner-inner') {
        boxATop = boxA.getYPosition();
        boxABottom = boxA.getYPosition() + boxA.getHeight();
        boxALeft = boxA.getXPosition();
        boxARight = boxA.getXPosition() + boxA.getWidth();
        boxBTop = boxB.getYPosition();
        boxBBottom = boxB.getYPosition() + boxB.getHeight();
        boxBLeft = boxB.getXPosition();
        boxBRight = boxB.getXPosition() + boxB.getWidth();
      } else if (options.collisionType === 'outer-outer') {
        if (boxA.hasOuterRect) {
          boxATop = boxA.getYPosition({
            innerOrOuter: 'outer'
          });
          boxABottom = boxA.getYPosition({
            innerOrOuter: 'outer'
          }) + boxA.getHeight({
            innerOrOuter: 'outer'
          });
          boxALeft = boxA.getXPosition({
            innerOrOuter: 'outer'
          });
          boxARight = boxA.getXPosition({
            innerOrOuter: 'outer'
          }) + boxA.getWidth({
            innerOrOuter: 'outer'
          });
          boxBTop = boxB.getYPosition();
          boxBBottom = boxB.getYPosition() + boxB.getHeight();
          boxBLeft = boxB.getXPosition();
          boxBRight = boxB.getXPosition() + boxB.getWidth();
        } else {
          boxATop = boxA.getYPosition();
          boxABottom = boxA.getYPosition() + boxA.getHeight();
          boxALeft = boxA.getXPosition();
          boxARight = boxA.getXPosition() + boxA.getWidth();
          boxBTop = boxB.getYPosition({
            innerOrOuter: 'outer'
          });
          boxBBottom = boxB.getYPosition({
            innerOrOuter: 'outer'
          }) + boxB.getHeight({
            innerOrOuter: 'outer'
          });
          boxBLeft = boxB.getXPosition({
            innerOrOuter: 'outer'
          });
          boxBRight = boxB.getXPosition({
            innerOrOuter: 'outer'
          }) + boxB.getWidth({
            innerOrOuter: 'outer'
          });
        }
      }
      if (!(boxABottom < boxBTop || boxATop > boxBBottom || boxALeft > boxBRight || boxARight < boxBLeft)) {
        status = true;
      }
      Logger.dev("testCollisionBetween: box" + (boxA.getBoxId()) + " box" + (boxB.getBoxId()) + " " + status);
      if (status) {
        this.addCollisionPair(boxA, boxB);
      } else {
        this.removeCollisionPair(boxA, boxB);
      }
      return status;
    };

    return CollisionUtil;

  })(Backbone.Collection);

  this.StackBoard = (function() {
    function StackBoard(params) {
      var boxes_params, longerEdge, margin, overhangBackground, overhangOffset, palletBackground, shorterEdge, stageBackground;
      this.zone = params.zone;
      longerEdge = Math.max(pallet.width, pallet.height);
      shorterEdge = Math.min(pallet.width, pallet.height);
      margin = Math.max(pallet.overhang, box.minDistance);
      overhangOffset = {
        x: 0,
        y: 0,
        edge: margin
      };
      if (box.minDistance > pallet.overhang) {
        overhangOffset.x = overhangOffset.y = box.minDistance - pallet.overhang;
        overhangOffset.edge = pallet.overhang - box.minDistance;
      }
      this.ratio = this.zone.height / (longerEdge + 2 * margin);
      stageBackground = new Kinetic.Rect({
        x: 0,
        y: 0,
        width: this.zone.width,
        height: this.zone.height,
        fill: 'white'
      });
      palletBackground = new Kinetic.Rect({
        x: margin * this.ratio,
        y: margin * this.ratio,
        width: shorterEdge * this.ratio,
        height: longerEdge * this.ratio,
        fillRed: 251,
        fillGreen: 209,
        fillBlue: 175
      });
      overhangBackground = new Kinetic.Rect({
        x: overhangOffset.x * this.ratio,
        y: overhangOffset.y * this.ratio,
        width: (shorterEdge + pallet.overhang * 2) * this.ratio,
        height: (longerEdge + pallet.overhang * 2) * this.ratio,
        strokeRed: 238,
        strokeGreen: 49,
        strokeBlue: 109,
        strokeAlpha: 0.5
      });
      overhangBackground.dash([4, 5]);
      this.stage = new Kinetic.Stage({
        container: "canvas_container",
        width: this.zone.width * this.zone.stage_zoom,
        height: this.zone.height * this.zone.stage_zoom
      });
      this.layer = new Kinetic.Layer();
      this.stage.add(this.layer);
      this.layer.add(stageBackground);
      this.layer.add(palletBackground);
      this.layer.add(overhangBackground);
      Logger.debug("StackBoard: Stage Initialized!");
      Logger.info("StackBoard: Initialized!");
      boxes_params = {
        layer: this.layer,
        zone: this.zone,
        box: params.box
      };
      this.boxes = new Boxes(boxes_params);
      this.boxes.shift();
      rivets.bind($('.boxes'), {
        boxes: this.boxes
      });
    }

    StackBoard.prototype.calculateOriginPoint = function() {};

    return StackBoard;

  })();

  pallet = {
    width: 250,
    height: 400,
    overhang: -10
  };

  box = {
    x: 0,
    y: 0,
    width: 60,
    height: 30,
    minDistance: 10
  };

  canvasZone = {
    width: 260,
    height: 320,
    stage_zoom: 1.5
  };

  params = {
    pallet: pallet,
    box: box,
    zone: canvasZone
  };

  this.board = new StackBoard(params);

  rivets.formatters.offset = function(value) {
    return value = value % 99;
  };

  $("input").prop("readonly", true);

  $(".offset").prop("readonly", false);

  $("#minDistance").prop("readonly", false);

  $("#ex8").slider();

  $("#ex8").on("slide", function(slideEvt) {
    $("#box-move-offset").val($("#ex8").val());
  });

}).call(this);

/*
//@ sourceMappingURL=app.js.map
*/
