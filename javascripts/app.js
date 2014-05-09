(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  require.config({
    baseUrl: "./javascripts",
    dir: "../dist",
    optimize: "uglify",
    optimizeCss: "standard.keepLines",
    removeCombined: true,
    fileExclusionRegExp: /^\./,
    paths: {
      jquery: "lib/jquery",
      underscore: "lib/underscore",
      backbone: "lib/backbone",
      rivets: "lib/rivets",
      kinetic: "lib/kinetic",
      bootstrap: 'lib/bootstrap'
    },
    shim: {
      underscore: {
        exports: "_"
      },
      backbone: {
        deps: ["underscore", "jquery"],
        exports: "Backbone"
      },
      rivets: {
        exports: "rivets"
      },
      kinetic: {
        exports: "Kinetic"
      },
      bootstrap: {
        deps: ["jquery"],
        exports: "Bootstrap"
      }
    }
  });

  require(['jquery', 'underscore', 'backbone', 'rivets', 'kinetic', 'bootstrap'], function($, _, Backbone, rivets, Kinetic) {
    var CollisionPair, CollisionUtil, box, canvasStage, color, pallet, params;
    console.log(Backbone);
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

      statuses = ['dev'];

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
          return console.log(instance.debug(message));
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
        boxId: '0',
        collisionStatus: false,
        settledStatus: false,
        moveOffset: 1,
        rotate: 0,
        vectorDegree: 0,
        vectorEnabled: false,
        crossZoneLeft: false,
        crossZoneRight: false,
        crossZoneTop: false,
        crossZoneBottom: false
      };

      Box.prototype.initialize = function(params) {
        var box_params, centerPointOnRect, outerBox, _ref;
        this.on('change:rect', this.rectChanged);
        _ref = [params.box, params.color, params.ratio, params.zone, params.palletOverhang], box_params = _ref[0], this.color_params = _ref[1], this.ratio = _ref[2], this.zone = _ref[3], this.palletOverhang = _ref[4];
        this.set({
          minDistance: box_params.minDistance
        });
        this.set({
          innerBox: {
            x: box_params.x,
            y: box_params.y,
            width: box_params.width,
            height: box_params.height
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
            x: this.get('rect').x() + this.get('rect').width() - 5,
            y: this.get('rect').y() + 5,
            fontSize: 14,
            fontFamily: "Calibri",
            fill: "white",
            text: this.get('boxId'),
            rotate: 0,
            offset: {
              x: 4,
              y: 4
            }
          })
        });
        centerPointOnRect = this.getCenterPoint('inner');
        this.set({
          dot: new Kinetic.Circle({
            x: centerPointOnRect.x,
            y: centerPointOnRect.y,
            radius: 2,
            fillRed: 1,
            fillGreen: 1,
            fillBlue: 1,
            fillAlpha: 1
          })
        });
        this.set({
          arrow: new Kinetic.Line({
            x: centerPointOnRect.x,
            y: centerPointOnRect.y,
            points: [centerPointOnRect.x, centerPointOnRect.y + 8, centerPointOnRect.x, centerPointOnRect.y - 8, centerPointOnRect.x - 4, centerPointOnRect.y, centerPointOnRect.x, centerPointOnRect.y - 8, centerPointOnRect.x + 4, centerPointOnRect.y],
            strokeRed: 1,
            strokeGreen: 1,
            strokeBlue: 1,
            strokeWidth: 2,
            strokeAlpha: 0,
            lineCap: "round",
            lineJoin: "round",
            offset: {
              x: centerPointOnRect.x,
              y: centerPointOnRect.y
            }
          })
        });
        this.set({
          innerShape: {
            x: this.get('rect').x() + this.get('rect').width() / 8,
            y: this.get('rect').y(),
            width: this.get('rect').width() * 0.75,
            height: this.get('rect').height() / 8
          }
        });
        this.set({
          orientationFlag: new Kinetic.Rect({
            x: this.get('innerShape').x,
            y: this.get('innerShape').y,
            width: this.get('innerShape').width,
            height: this.get('innerShape').height,
            fillRed: 255,
            fillGreen: 41,
            fillBlue: 86
          })
        });
        this.set({
          group: new Kinetic.Group({
            x: 0,
            y: 0,
            draggable: false
          })
        });
        this.get('rect').dash([4, 5]);
        this.get('group').add(this.get('rect'));
        this.get('group').add(this.get('title'));
        this.get('group').add(this.get('arrow'));
        this.get('group').add(this.get('dot'));
        this.get('group').add(this.get('orientationFlag'));
        outerBox = this.getOuterRectShape();
        this.set({
          outerRect: new Kinetic.Rect({
            x: outerBox.x,
            y: outerBox.y,
            width: outerBox.width,
            height: outerBox.height
          })
        });
        if (!(this.get('minDistance') > 0)) {
          this.get('outerRect').setFillAlpha(0);
        }
        this.get('outerRect').dash([4, 5]);
        this.get('group').add(this.get('outerRect'));
        return Logger.debug('Box: Generate a new box.');
      };

      Box.prototype.hasOuterRect = function() {
        return this.get('minDistance') > 0;
      };

      Box.prototype.getCenterPoint = function(options) {
        var centerPointOnGroup, centerPointOnRect;
        if (options === 'inner') {
          return centerPointOnRect = {
            x: this.get('rect').x() + this.get('rect').width() / 2,
            y: this.get('rect').y() + this.get('rect').height() / 2
          };
        } else if (options === 'byRatio') {
          return {
            x: (this.get('group').x() + this.get('rect').width() / 2) / this.ratio,
            y: (this.get('group').y() + this.get('rect').height() / 2) / this.ratio
          };
        } else {
          return centerPointOnGroup = {
            x: this.get('group').x() + this.get('rect').width() / 2,
            y: this.get('group').y() + this.get('rect').height() / 2
          };
        }
      };

      Box.prototype.getOuterRectShape = function() {
        var shape;
        return shape = {
          x: this.get('innerBox').x - this.get('minDistance'),
          y: this.get('innerBox').y - this.get('minDistance'),
          width: this.get('innerBox').width + 2 * this.get('minDistance'),
          height: this.get('innerBox').height + 2 * this.get('minDistance')
        };
      };

      Box.prototype.getBoxId = function() {
        return this.get('boxId');
      };

      Box.prototype.getMoveOffset = function() {
        Logger.debug("getMoveOffset " + (this.get('moveOffset')));
        return Math.round(parseFloat(Number(this.get('moveOffset') * this.ratio)) * 100) / 100;
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

      Box.prototype.getXPositionByRatio = function() {
        return ((this.get('group').x() + this.get('rect').getWidth() / 2) - this.zone.bound.left) / this.ratio - this.palletOverhang;
      };

      Box.prototype.getYPositionByRatio = function() {
        return (this.zone.bound.bottom - (this.get('group').y() - this.get('rect').getHeight() / 2) - this.getHeight()) / this.ratio - this.palletOverhang;
      };

      Box.prototype.getWidthByRatio = function() {
        return this.get('rect').width() / this.ratio;
      };

      Box.prototype.getHeightByRatio = function() {
        return this.get('rect').height() / this.ratio;
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
          y: this.getYPosition(),
          flag: 'A'
        };
      };

      Box.prototype.getPointB = function() {
        var pointB;
        return pointB = {
          x: this.getXPosition() + this.get('rect').getWidth(),
          y: this.getYPosition(),
          flag: 'B'
        };
      };

      Box.prototype.getPointC = function() {
        var pointC;
        Logger.debug("@getYPosition() " + (this.getYPosition()) + ", @get('rect').getHeight(): " + (this.get('rect').getHeight()));
        return pointC = {
          x: this.getXPosition(),
          y: this.getYPosition() + this.get('rect').getHeight(),
          flag: 'C'
        };
      };

      Box.prototype.getPointD = function() {
        var pointC;
        return pointC = {
          x: this.getXPosition() + this.get('rect').getWidth(),
          y: this.getYPosition() + this.get('rect').getHeight(),
          flag: 'D'
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
        Logger.debug("box" + (this.getTitleName()) + ": makeCollisionStatus");
        return this.set('collisionStatus', true);
      };

      Box.prototype.makeUnCollisionStatus = function() {
        Logger.debug("box" + (this.getTitleName()) + ": makeUnCollisionStatus");
        return this.set('collisionStatus', false);
      };

      Box.prototype.rotateWithAngle = function(angle) {
        var centerPointForGroup, newRotateAngle, outerBox, shape;
        newRotateAngle = (this.get('rotate') + angle) % 360;
        centerPointForGroup = this.getCenterPoint();
        switch (newRotateAngle) {
          case 0:
            this.get('rect').setWidth(this.get('innerBox').width);
            this.get('rect').setHeight(this.get('innerBox').height);
            this.get('group').setX(centerPointForGroup.x - this.get('rect').getWidth() / 2);
            this.get('group').setY(centerPointForGroup.y - this.get('rect').getHeight() / 2);
            outerBox = this.getOuterRectShape();
            this.get('outerRect').setWidth(outerBox.width);
            this.get('outerRect').setHeight(outerBox.height);
            shape = this.get('innerShape');
            this.get('orientationFlag').setX(this.get('rect').width() / 8);
            this.get('orientationFlag').setY(0);
            this.get('orientationFlag').setWidth(shape.width);
            this.get('orientationFlag').setHeight(shape.height);
            break;
          case 90:
            this.get('rect').setWidth(this.get('innerBox').height);
            this.get('rect').setHeight(this.get('innerBox').width);
            this.get('group').setX(centerPointForGroup.x - this.get('rect').getWidth() / 2);
            this.get('group').setY(centerPointForGroup.y - this.get('rect').getHeight() / 2);
            outerBox = this.getOuterRectShape();
            this.get('outerRect').setWidth(outerBox.height);
            this.get('outerRect').setHeight(outerBox.width);
            shape = this.get('innerShape');
            this.get('orientationFlag').setX(this.get('rect').width() / 8 * 7);
            this.get('orientationFlag').setY(this.get('rect').height() / 8);
            this.get('orientationFlag').setWidth(shape.height);
            this.get('orientationFlag').setHeight(shape.width);
            break;
          case 180:
            this.get('rect').setWidth(this.get('innerBox').width);
            this.get('rect').setHeight(this.get('innerBox').height);
            this.get('group').setX(centerPointForGroup.x - this.get('rect').getWidth() / 2);
            this.get('group').setY(centerPointForGroup.y - this.get('rect').getHeight() / 2);
            outerBox = this.getOuterRectShape();
            this.get('outerRect').setWidth(outerBox.width);
            this.get('outerRect').setHeight(outerBox.height);
            shape = this.get('innerShape');
            this.get('orientationFlag').setX(this.get('rect').width() / 8);
            this.get('orientationFlag').setY(this.get('rect').height() / 8 * 7);
            this.get('orientationFlag').setWidth(shape.width);
            this.get('orientationFlag').setHeight(shape.height);
            break;
          case 270:
            this.get('rect').setWidth(this.get('innerBox').height);
            this.get('rect').setHeight(this.get('innerBox').width);
            this.get('group').setX(centerPointForGroup.x - this.get('rect').getWidth() / 2);
            this.get('group').setY(centerPointForGroup.y - this.get('rect').getHeight() / 2);
            outerBox = this.getOuterRectShape();
            this.get('outerRect').setWidth(outerBox.height);
            this.get('outerRect').setHeight(outerBox.width);
            shape = this.get('innerShape');
            this.get('orientationFlag').setX(0);
            this.get('orientationFlag').setY(this.get('rect').height() / 8);
            this.get('orientationFlag').setWidth(shape.height);
            this.get('orientationFlag').setHeight(shape.width);
        }
        this.get('arrow').setX(this.get('rect').x() + this.get('rect').width() / 2);
        this.get('arrow').setY(this.get('rect').y() + this.get('rect').height() / 2);
        this.get('dot').setX(this.get('rect').x() + this.get('rect').width() / 2);
        this.get('dot').setY(this.get('rect').y() + this.get('rect').height() / 2);
        this.get('title').setX(this.get('rect').x() + this.get('rect').width() - 5);
        this.get('title').setY(this.get('rect').y() + 5);
        this.set('rotate', newRotateAngle);
        Logger.debug("[rotateWithAngle] width: " + (this.get('rect').getWidth()) + ", height: " + (this.get('rect').getHeight()));
        Logger.debug("[rotateWithAngle] group_x: " + (this.get('group').x()) + ", group_y: " + (this.get('group').y()));
        return Logger.debug("[rotateWithAngle] rect_x: " + (this.get('rect').x()) + ", rect_y: " + (this.get('rect').y()));
      };

      Box.prototype.changeFillColor = function() {
        Logger.debug("Box" + (this.getTitleName()) + " collisionStatus: " + (this.get('collisionStatus')) + "\t settledStatus: " + (this.get('settledStatus')));
        if (this.get('settledStatus')) {
          this.get('rect').fillRed(this.color_params.boxPlaced.inner.red);
          this.get('rect').fillGreen(this.color_params.boxPlaced.inner.green);
          this.get('rect').fillBlue(this.color_params.boxPlaced.inner.blue);
          this.get('rect').fillAlpha(this.color_params.boxPlaced.inner.alpha);
          this.get('rect').strokeRed(this.color_params.boxPlaced.inner.stroke.red);
          this.get('rect').strokeGreen(this.color_params.boxPlaced.inner.stroke.green);
          this.get('rect').strokeBlue(this.color_params.boxPlaced.inner.stroke.blue);
          this.get('rect').strokeAlpha(this.color_params.boxPlaced.inner.stroke.alpha);
          if (this.hasOuterRect()) {
            this.get('outerRect').fillRed(this.color_params.boxPlaced.outer.red);
            this.get('outerRect').fillGreen(this.color_params.boxPlaced.outer.green);
            this.get('outerRect').fillBlue(this.color_params.boxPlaced.outer.blue);
            this.get('outerRect').fillAlpha(this.color_params.boxPlaced.outer.alpha);
            this.get('outerRect').strokeRed(this.color_params.boxPlaced.outer.stroke.red);
            this.get('outerRect').strokeGreen(this.color_params.boxPlaced.outer.stroke.green);
            this.get('outerRect').strokeBlue(this.color_params.boxPlaced.outer.stroke.blue);
            return this.get('outerRect').strokeAlpha(this.color_params.boxPlaced.outer.stroke.alpha);
          }
        } else {
          if (this.get('collisionStatus')) {
            this.get('rect').fillRed(this.color_params.boxSelected.collision.inner.red);
            this.get('rect').fillGreen(this.color_params.boxSelected.collision.inner.green);
            this.get('rect').fillBlue(this.color_params.boxSelected.collision.inner.blue);
            this.get('rect').fillAlpha(this.color_params.boxSelected.collision.inner.alpha);
            this.get('rect').strokeRed(this.color_params.boxSelected.collision.inner.stroke.red);
            this.get('rect').strokeGreen(this.color_params.boxSelected.collision.inner.stroke.green);
            this.get('rect').strokeBlue(this.color_params.boxSelected.collision.inner.stroke.blue);
            this.get('rect').strokeAlpha(this.color_params.boxSelected.collision.inner.stroke.alpha);
            this.get('outerRect').fillRed(this.color_params.boxSelected.collision.outer.red);
            if (this.hasOuterRect()) {
              this.get('outerRect').fillGreen(this.color_params.boxSelected.collision.outer.green);
              this.get('outerRect').fillBlue(this.color_params.boxSelected.collision.outer.blue);
              this.get('outerRect').fillAlpha(this.color_params.boxSelected.collision.outer.alpha);
              this.get('outerRect').strokeRed(this.color_params.boxSelected.collision.outer.stroke.red);
              this.get('outerRect').strokeGreen(this.color_params.boxSelected.collision.outer.stroke.green);
              this.get('outerRect').strokeBlue(this.color_params.boxSelected.collision.outer.stroke.blue);
              return this.get('outerRect').strokeAlpha(this.color_params.boxSelected.collision.outer.stroke.alpha);
            }
          } else {
            this.get('rect').fillRed(this.color_params.boxSelected.uncollision.inner.red);
            this.get('rect').fillGreen(this.color_params.boxSelected.uncollision.inner.green);
            this.get('rect').fillBlue(this.color_params.boxSelected.uncollision.inner.blue);
            this.get('rect').fillAlpha(this.color_params.boxSelected.uncollision.inner.alpha);
            this.get('rect').strokeRed(this.color_params.boxSelected.uncollision.inner.stroke.red);
            this.get('rect').strokeGreen(this.color_params.boxSelected.uncollision.inner.stroke.green);
            this.get('rect').strokeBlue(this.color_params.boxSelected.uncollision.inner.stroke.blue);
            this.get('rect').strokeAlpha(this.color_params.boxSelected.uncollision.inner.stroke.alpha);
            if (this.hasOuterRect()) {
              this.get('outerRect').fillRed(this.color_params.boxSelected.uncollision.outer.red);
              this.get('outerRect').fillGreen(this.color_params.boxSelected.uncollision.outer.green);
              this.get('outerRect').fillBlue(this.color_params.boxSelected.uncollision.outer.blue);
              this.get('outerRect').fillAlpha(this.color_params.boxSelected.uncollision.outer.alpha);
              this.get('outerRect').strokeRed(this.color_params.boxSelected.uncollision.outer.stroke.red);
              this.get('outerRect').strokeGreen(this.color_params.boxSelected.uncollision.outer.stroke.green);
              this.get('outerRect').strokeBlue(this.color_params.boxSelected.uncollision.outer.stroke.blue);
              return this.get('outerRect').strokeAlpha(this.color_params.boxSelected.uncollision.outer.stroke.alpha);
            }
          }
        }
      };

      Box.prototype.printPoints = function(prefix) {
        return Logger.debug(("\n[" + prefix + "]: PointA(x:" + (this.getPointA().x) + ",y:" + (this.getPointA().y) + ")\n ") + ("[" + prefix + "]: PointB(x:" + (this.getPointB().x) + ",y:" + (this.getPointB().y) + ")\n ") + ("[" + prefix + "]: PointC(x:" + (this.getPointC().x) + ",y:" + (this.getPointC().y) + ")\n ") + ("[" + prefix + "]: PointD(x:" + (this.getPointD().x) + ",y:" + (this.getPointD().y) + ")\n "));
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
        this.moveByVector = __bind(this.moveByVector, this);
        this.rotateByVector = __bind(this.rotateByVector, this);
        this.rotate90 = __bind(this.rotate90, this);
        this.removeCurrentBox = __bind(this.removeCurrentBox, this);
        this.settleCurrentBox = __bind(this.settleCurrentBox, this);
        this.createNewBox = __bind(this.createNewBox, this);
        return Boxes.__super__.constructor.apply(this, arguments);
      }

      Boxes.prototype.model = Box;

      Boxes.prototype.initialize = function(params) {
        this.layer = params.layer;
        this.zone = params.zone;
        this.knob = params.knob;
        this.box_params = {
          box: params.box,
          color: params.color,
          ratio: params.ratio,
          zone: params.zone,
          palletOverhang: params.palletOverhang
        };
        this.ratio = this.box_params.ratio;
        this.CurrentBox = Backbone.Model.extend({
          initialize: function(box_params) {
            this.set({
              box: new Box(box_params)
            });
            this.set({
              title: this.get('box').getTitleName()
            });
            return this.on('change:box', this.updateBoxTitle);
          },
          updateBoxTitle: function() {
            return this.set({
              title: this.get('box').getTitleName()
            });
          }
        });
        this.on('all', this.draw);
        this.on('all', this.updateDashboardStatus);
        this.collisionUtil = new CollisionUtil;
        this.currentBox = new Box(this.box_params);
        this.otherCurrentBox = new this.CurrentBox(this.box_params);
        this.availableNewBoxId = 1;
        this.rivetsBinder = rivets.bind($('.boxes'), {
          boxes: this
        });
        this.rivetsBinderCurrentBox = rivets.bind($('.currentBox'), {
          currentBox: this.otherCurrentBox
        });
        this.flash = "Initialized completed!";
        this.alignGroup = new Kinetic.Group({
          x: 0,
          y: 0,
          draggable: false
        });
        this.xAlignLine = new Kinetic.Line({
          points: [0, 0, 0, 0],
          strokeRed: 65,
          strokeGreen: 219,
          strokeBlue: 248,
          strokeWidth: 1,
          strokeAlpha: 0,
          lineCap: "round",
          lineJoin: "round"
        });
        this.yAlignLine = new Kinetic.Line({
          points: [0, 0, 0, 0],
          strokeRed: 65,
          strokeGreen: 219,
          strokeBlue: 248,
          strokeWidth: 1,
          strokeAlpha: 0,
          lineCap: "round",
          lineJoin: "round"
        });
        this.alignGroup.add(this.xAlignLine);
        this.alignGroup.add(this.yAlignLine);
        return this.layer.add(this.alignGroup);
      };

      Boxes.prototype.precisionAdjustment = function(floatNumber, digitNumber) {
        var ratioBy10;
        if (digitNumber == null) {
          digitNumber = 0;
        }
        ratioBy10 = 1 * Math.pow(10, digitNumber);
        return Math.round(parseFloat(floatNumber) * ratioBy10) / ratioBy10;
      };

      Boxes.prototype.equalCompareWithFloatNumber = function(numberLeft, numberRight, digitNumber) {
        if (digitNumber == null) {
          digitNumber = 0;
        }
        Logger.debug("[equalCompareWithFloatNumber:] numberLeft " + (this.precisionAdjustment(numberLeft)));
        Logger.debug("[equalCompareWithFloatNumber:] numberRight " + (this.precisionAdjustment(numberRight)));
        Logger.debug("" + (this.precisionAdjustment(numberLeft) === this.precisionAdjustment(numberRight)));
        return this.precisionAdjustment(numberLeft) === this.precisionAdjustment(numberRight);
      };

      Boxes.prototype.nearCompareWithFloatNumber = function(numberLeft, numberRight, offset, digitNumber) {
        if (digitNumber == null) {
          digitNumber = 0;
        }
        return Math.abs(this.precisionAdjustment(numberLeft) - this.precisionAdjustment(numberRight)) < offset;
      };

      Boxes.prototype.updateAlignGroup = function(options) {
        var bottomBox, bottomBoxApproach, bottomSpan, bottomSpanApproach, currentBoxCenterPoint, currentBoxCenterPointByRatio, leftBox, leftBoxApproach, leftSpan, leftSpanApproach, notCurrentBox, rightBox, rightBoxApproach, rightSpan, rightSpanApproach, topBox, topBoxApproach, topSpan, topSpanApproach, xAlignFlag, yAlignFlag;
        if (options == null) {
          options = {};
        }
        Logger.debug("[updateAlignGroup] before: box" + (this.currentBox.getTitleName()));
        if (this.length <= 1) {
          return;
        }
        this.hideAlignLines();
        currentBoxCenterPoint = this.currentBox.getCenterPoint();
        currentBoxCenterPointByRatio = this.currentBox.getCenterPoint('byRatio');
        leftBox = rightBox = topBox = bottomBox = this.currentBox;
        leftSpan = rightSpan = topSpan = bottomSpan = 0;
        leftBoxApproach = rightBoxApproach = topBoxApproach = bottomBoxApproach = this.currentBox;
        leftSpanApproach = rightSpanApproach = topSpanApproach = bottomSpanApproach = 0;
        xAlignFlag = '';
        yAlignFlag = '';
        _.each(this.models, (function(aBox) {
          var aBoxCenterPoint, aBoxCenterPointByRatio, newBottomSpan, newBottomSpanApproach, newLeftSpan, newLeftSpanApproach, newRightSpan, newRightSpanApproach, newTopSpan, newTopSpanApproach;
          if (aBox.getBoxId() !== this.currentBox.getBoxId()) {
            aBoxCenterPoint = aBox.getCenterPoint();
            aBoxCenterPointByRatio = aBox.getCenterPoint('byRatio');
            if (this.nearCompareWithFloatNumber(aBox.getCenterPoint('byRatio').y, currentBoxCenterPointByRatio.y, this.currentBox.getWidthByRatio() / 2)) {
              newLeftSpanApproach = currentBoxCenterPoint.x - aBoxCenterPoint.x;
              newRightSpanApproach = aBoxCenterPoint.x - currentBoxCenterPoint.x;
              if (newLeftSpanApproach > leftSpanApproach) {
                leftBoxApproach = aBox;
                leftSpanApproach = newLeftSpanApproach;
              }
              if (newRightSpanApproach > rightSpanApproach) {
                rightBoxApproach = aBox;
                rightSpanApproach = newRightSpanApproach;
              }
              Logger.debug("[updateAlignGroup]:leftSpanApproach " + leftSpanApproach + ";  rightSpanApproach " + rightSpanApproach);
              xAlignFlag = 'approach';
            }
            if (this.nearCompareWithFloatNumber(aBox.getCenterPoint('byRatio').x, currentBoxCenterPointByRatio.x, this.currentBox.getWidthByRatio() / 2)) {
              newTopSpanApproach = currentBoxCenterPoint.y - aBoxCenterPoint.y;
              newBottomSpanApproach = aBoxCenterPoint.y - currentBoxCenterPoint.y;
              if (newBottomSpanApproach > bottomSpanApproach) {
                bottomBoxApproach = aBox;
                bottomSpanApproach = newBottomSpanApproach;
              }
              if (newTopSpanApproach > topSpanApproach) {
                topBoxApproach = aBox;
                topSpanApproach = newTopSpanApproach;
              }
              yAlignFlag = 'approach';
            }
            Logger.debug("aBox.getCenterPoint('byRatio').y - currentBoxCenterPointByRatio.y " + (aBox.getCenterPoint('byRatio').y - currentBoxCenterPointByRatio.y));
            if (this.equalCompareWithFloatNumber(aBox.getCenterPoint('byRatio').y, currentBoxCenterPointByRatio.y)) {
              newLeftSpan = currentBoxCenterPoint.x - aBoxCenterPoint.x;
              newRightSpan = aBoxCenterPoint.x - currentBoxCenterPoint.x;
              if (newLeftSpan > leftSpan) {
                leftBox = aBox;
                leftSpan = newLeftSpan;
              }
              if (newRightSpan > rightSpan) {
                rightBox = aBox;
                rightSpan = newRightSpan;
              }
              xAlignFlag = 'align';
            }
            Logger.debug("aBox.getCenterPoint('byRatio').x - currentBoxCenterPointByRatio.x : " + (aBox.getCenterPoint('byRatio').x - currentBoxCenterPointByRatio.x));
            if (this.equalCompareWithFloatNumber(aBox.getCenterPoint('byRatio').x, currentBoxCenterPointByRatio.x)) {
              newTopSpan = currentBoxCenterPoint.y - aBoxCenterPoint.y;
              newBottomSpan = aBoxCenterPoint.y - currentBoxCenterPoint.y;
              if (newBottomSpan > bottomSpan) {
                bottomBox = aBox;
                bottomSpan = newBottomSpan;
              }
              if (newTopSpan > topSpan) {
                topBox = aBox;
                topSpan = newTopSpan;
              }
              return yAlignFlag = 'align';
            }
          }
        }), this);
        if (xAlignFlag === 'align') {
          Logger.debug("[updateAlignGroup]: x align add: leftBox " + (leftBox.getTitleName()) + ", rightBox " + (rightBox.getTitleName()));
          this.updateYAlignLine(leftBox.getCenterPoint().x, rightBox.getCenterPoint().x, currentBoxCenterPoint.y, 50, 'alignment');
        } else if (xAlignFlag === 'approach') {
          if (leftBoxApproach.getTitleName() !== this.currentBox.getTitleName()) {
            notCurrentBox = leftBoxApproach;
          } else if (rightBoxApproach.getTitleName() !== this.currentBox.getTitleName()) {
            notCurrentBox = rightBoxApproach;
          } else {
            notCurrentBox = _.filter(this.models, (function(aBox) {
              return aBox.getTitleName() !== this.currentBox.getTitleName();
            }), this)[0];
          }
          this.updateYAlignLine(leftBoxApproach.getCenterPoint().x, rightBoxApproach.getCenterPoint().x, notCurrentBox.getCenterPoint().y, 50, 'approach');
        } else {
          this.yAlignLine.strokeAlpha(0);
        }
        if (yAlignFlag === 'align') {
          Logger.debug("[updateAlignGroup]: y align add: topBox" + (topBox.getTitleName()) + ": " + (topBox.getCenterPoint().y) + ", bottomBox" + (bottomBox.getTitleName()) + ": " + (bottomBox.getCenterPoint().y));
          this.updateXAlignLine(topBox.getCenterPoint().y, bottomBox.getCenterPoint().y, currentBoxCenterPoint.x, 50, 'alignment');
        } else if (yAlignFlag === 'approach') {
          if (topBoxApproach.getTitleName() !== this.currentBox.getTitleName()) {
            notCurrentBox = topBoxApproach;
          } else if (bottomBoxApproach.getTitleName() !== this.currentBox.getTitleName()) {
            notCurrentBox = bottomBoxApproach;
          } else {
            notCurrentBox = _.filter(this.models, (function(aBox) {
              return aBox.getTitleName() !== this.currentBox.getTitleName();
            }), this)[0];
          }
          this.updateXAlignLine(topBoxApproach.getCenterPoint().y, bottomBoxApproach.getCenterPoint().y, notCurrentBox.getCenterPoint().x, 50, 'approach');
        } else {
          this.xAlignLine.strokeAlpha(0);
        }
        Logger.debug("[updateAlignGroup] @xAlignLine.strokeAlpha(0) " + (this.xAlignLine.strokeAlpha()));
        Logger.debug("[updateAlignGroup] @yAlignLine.strokeAlpha(0) " + (this.yAlignLine.strokeAlpha()));
        Logger.debug("[updateAlignGroup] after: box" + (this.currentBox.getTitleName()));
        return this.draw();
      };

      Boxes.prototype.hideAlignLines = function() {
        this.xAlignLine.strokeAlpha(0);
        return this.yAlignLine.strokeAlpha(0);
      };

      Boxes.prototype.updateXAlignLine = function(pointTopY, pointBottomY, pointX, offset, status) {
        Logger.debug("[updateXAlignLine] pointTop: " + pointTopY + "  pointBottom: " + pointBottomY);
        this.xAlignLine.strokeAlpha(1);
        this.xAlignLine.points([pointX, pointTopY - offset, pointX, pointBottomY + offset]);
        if (status === 'approach') {
          this.xAlignLine.strokeRed(65);
          this.xAlignLine.strokeGreen(219);
          this.xAlignLine.strokeBlue(248);
        } else {
          this.xAlignLine.strokeRed(255);
          this.xAlignLine.strokeGreen(255);
          this.xAlignLine.strokeBlue(27);
        }
        return this.xAlignLine;
      };

      Boxes.prototype.updateYAlignLine = function(pointLeftX, pointRightX, pointY, offset, status) {
        this.yAlignLine.strokeAlpha(1);
        this.yAlignLine.points([pointLeftX - offset, pointY, pointRightX + offset, pointY]);
        if (status === 'approach') {
          this.yAlignLine.strokeRed(65);
          this.yAlignLine.strokeGreen(219);
          this.yAlignLine.strokeBlue(248);
        } else {
          this.yAlignLine.strokeRed(255);
          this.yAlignLine.strokeGreen(255);
          this.yAlignLine.strokeBlue(27);
        }
        return this.yAlignLine;
      };

      Boxes.prototype.availableNewTitle = function() {
        return this.length + 1;
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

      Boxes.prototype.createNewBox = function() {
        var newBox;
        newBox = new Box(this.box_params);
        if (this.length === 0) {
          newBox.setXPosition(Math.floor((this.zone.bound.left + this.zone.bound.right - newBox.get('rect').getWidth()) / 2));
          newBox.setYPosition(Math.floor((this.zone.bound.top + this.zone.bound.bottom - newBox.get('rect').getHeight()) / 2));
        } else {
          newBox.setXPosition(this.last().getXPosition());
          newBox.setYPosition(this.last().getYPosition());
        }
        newBox.setTitleName(this.availableNewBoxId);
        newBox.set('boxId', this.availableNewBoxId);
        newBox.box().on("click", (function(_this) {
          return function() {
            Logger.debug("box" + (newBox.getTitleName()) + " clicked!");
            if (!_this.testCollision()) {
              _this.flash = "box" + (newBox.getTitleName()) + " selected!";
              _this.updateCurrentBox(newBox);
              return _this.draw();
            } else {
              return _this.flash = "Collision!";
            }
          };
        })(this));
        this.add(newBox);
        this.updateCurrentBox(newBox);
        this.flash = "box" + (this.currentBox.getTitleName()) + " selected!";
        this.availableNewBoxId += 1;
        this.testCollision();
        if (!this.validateZone(this.currentBox)) {
          this.repairCrossZone(this.currentBox);
        }
        return Logger.debug("create button clicked!");
      };

      Boxes.prototype.settleCurrentBox = function() {
        if (this.currentBox.get('collisionStatus')) {
          return this.flash = "Box" + (this.currentBox.getTitleName()) + " cannot be placed in collision status!";
        } else {
          this.currentBox.set('settledStatus', true);
          this.currentBox.get('group').setDraggable(false);
          this.hideAlignLines();
          return this.draw();
        }
      };

      Boxes.prototype.updateDragStatus = function(draggableBox) {
        return _.each(this.models, (function(aBox) {
          if (aBox.getBoxId() === draggableBox.getBoxId()) {
            return draggableBox.get('group').setDraggable(true);
          } else {
            return aBox.get('group').setDraggable(false);
          }
        }), this);
      };

      Boxes.prototype.removeCurrentBox = function() {
        Logger.debug("" + this.length);
        if (this.length === 0) {
          this.flash = 'There is no box.';
        } else {
          this.deleteCollisionWith();
          this.currentBox.get('group').destroy();
          this.remove(this.currentBox);
          if (this.length === 0) {
            this.currentBox = new Box(this.box_params);
            this.updateCurrentBox(new Box(this.box_params));
            this.flash = 'There is no box.';
          } else {
            this.updateCurrentBox(this.last());
          }
        }
        this.draw();
        this.flash = "box" + (this.currentBox.getTitleName()) + " selected!";
        return Logger.debug("remove button clicked!");
      };

      Boxes.prototype.testCollision = function() {
        var result;
        Logger.debug("...Collision start...");
        result = false;
        result = _.reduce(this.models, (function(status, box) {
          if (this.currentBox.getBoxId() !== box.getBoxId() && this.currentBox.getBoxId() !== '0') {
            return this.testCollisionBetween(this.currentBox, box) || status;
          } else {
            return status;
          }
        }), false, this);
        return result;
      };

      Boxes.prototype.draw = function() {
        var box, index;
        index = 0;
        while (index < this.models.length) {
          box = this.models[index];
          Logger.debug("In draw: Box" + (box.getTitleName()) + ".collision=" + (box.get('collisionStatus')));
          box.changeFillColor();
          box.updateTitle(index + 1);
          this.layer.add(box.box());
          index += 1;
          Logger.debug("[draw]: Box" + (box.getTitleName()) + " " + (box.box().draggable()));
          Logger.debug("[draw]: X" + (box.getXPosition()) + " Y" + (box.getYPosition()));
        }
        this.layer.add(this.alignGroup);
        return this.layer.draw();
      };

      Boxes.prototype.updateCurrentBox = function(newBox) {
        if (newBox == null) {
          newBox = this.currentBox;
        }
        _.each(this.models, (function(aBox) {
          return aBox.set('settledStatus', true);
        }), this);
        newBox.set('settledStatus', false);
        this.currentBox = newBox;
        this.currentBox.get('group').setDraggable(true);
        this.currentBox.get('group').setDragBoundFunc((function(_this) {
          return function(position) {
            var newPosition;
            if (!_this.validateZone(_this.currentBox)) {
              _this.repairCrossZone(_this.currentBox);
              newPosition = {
                x: _this.currentBox.getXPosition(),
                y: _this.currentBox.getYPosition()
              };
            } else {
              newPosition = position;
            }
            _this.updateCurrentBox();
            return newPosition;
          };
        })(this));
        this.currentBox.get('group').on('dragend', (function(_this) {
          return function() {
            _this.currentBox.setXPosition(_this.precisionAdjustment(_this.currentBox.getXPosition()));
            _this.currentBox.setYPosition(_this.precisionAdjustment(_this.currentBox.getYPosition()));
            if (!_this.validateZone(_this.currentBox)) {
              _this.repairCrossZone(_this.currentBox);
            }
            return _this.testCollision();
          };
        })(this));
        Logger.debug("[updateCurrentBox] width: " + (this.currentBox.get('rect').getWidth()) + ", height: " + (this.currentBox.get('rect').getHeight()));
        this.otherCurrentBox.set('box', newBox);
        this.updateBinders();
        this.updateDragStatus(this.currentBox);
        this.updateAlignGroup();
        return rivets.bind($('.box'), {
          box: newBox
        });
      };

      Boxes.prototype.rotate90 = function() {
        this.currentBox.rotateWithAngle(90);
        this.testCollision();
        this.updateCurrentBox();
        return Logger.debug("[rotate90] width: " + (this.currentBox.get('rect').getWidth()) + ", height: " + (this.currentBox.get('rect').getHeight()));
      };

      Boxes.prototype.rotateByVector = function() {
        var vectorDegree;
        vectorDegree = this.currentBox.get('vectorDegree') + 45;
        if (vectorDegree <= 360) {
          this.currentBox.set('vectorEnabled', true);
          this.currentBox.get('dot').setFillAlpha(0);
          this.currentBox.get('arrow').strokeAlpha(1);
          this.currentBox.set('vectorDegree', vectorDegree);
          this.currentBox.get('arrow').rotation(this.currentBox.get('vectorDegree'));
        } else {
          this.currentBox.set('vectorEnabled', false);
          this.currentBox.get('dot').setFillAlpha(1);
          this.currentBox.get('arrow').strokeAlpha(0);
          this.currentBox.set('vectorDegree', -45);
        }
        Logger.debug("box" + (this.currentBox.getTitleName()) + " vector " + vectorDegree);
        return this.updateCurrentBox();
      };

      Boxes.prototype.moveByVector = function() {
        var moveDegree;
        moveDegree = $("input.dial").val();
        switch (Number(moveDegree)) {
          case 0:
            this.moveByX(0);
            this.moveByY(1);
            break;
          case 45:
            this.moveByX(1);
            this.moveByY(1);
            break;
          case 90:
            this.moveByX(1);
            this.moveByY(0);
            break;
          case 135:
            this.moveByX(1);
            this.moveByY(-1);
            break;
          case 180:
            this.moveByX(0);
            this.moveByY(-1);
            break;
          case 225:
            this.moveByX(-1);
            this.moveByY(-1);
            break;
          case 270:
            this.moveByX(-1);
            this.moveByY(0);
            break;
          case 315:
            this.moveByX(-1);
            this.moveByY(1);
            break;
          case 360:
            this.moveByX(0);
            this.moveByY(1);
        }
        this.testCollision();
        return this.updateCurrentBox();
      };

      Boxes.prototype.moveByY = function(direction, flash) {
        this.currentBox.setYPosition(Math.round(parseFloat(this.currentBox.getYPosition() - this.currentBox.getMoveOffset() * direction)));
        if (!this.validateZone(this.currentBox)) {
          this.repairCrossZone(this.currentBox);
        }
        return this.flash = flash;
      };

      Boxes.prototype.moveByX = function(direction, flash) {
        this.currentBox.setXPosition(Math.round(parseFloat(this.currentBox.getXPosition() + this.currentBox.getMoveOffset() * direction)));
        if (!this.validateZone(this.currentBox)) {
          this.repairCrossZone(this.currentBox);
        }
        return this.flash = flash;
      };

      Boxes.prototype.up = function() {
        Logger.debug("@currentBox:\t" + this.currentBox.getTitleName());
        this.currentBox.setYPosition(this.currentBox.getYPosition() - this.currentBox.getMoveOffset());
        if (!this.validateZone(this.currentBox)) {
          this.repairCrossZone(this.currentBox);
          this.flash = "Box" + (this.currentBox.getTitleName()) + " cannot be moved UP!";
        } else {
          this.flash = "box" + (this.currentBox.getTitleName()) + " selected!";
        }
        this.testCollision();
        return this.updateCurrentBox();
      };

      Boxes.prototype.down = function() {
        this.currentBox.setYPosition(this.currentBox.getYPosition() + this.currentBox.getMoveOffset());
        if (!this.validateZone(this.currentBox)) {
          this.repairCrossZone(this.currentBox);
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
        this.currentBox.set('crossZoneLeft', false);
        if (!this.validateZone(this.currentBox)) {
          this.repairCrossZone(this.currentBox);
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
          this.repairCrossZone(this.currentBox);
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
          return status && this.validateZoneX(point, box) && this.validateZoneY(point, box);
        }), true, this);
        Logger.debug("validresult:\t " + result);
        return result;
      };

      Boxes.prototype.validateZoneX = function(point, box) {
        Logger.debug("validateZoneX: @zone.bound.left " + this.zone.bound.left + " point (" + point.x + "," + point.y + "," + point.flag + "), @zone.bound.right " + this.zone.bound.right);
        if (this.zone.bound.left > point.x) {
          box.set('crossZoneLeft', true);
          return false;
        } else if (point.x > this.zone.bound.right) {
          box.set('crossZoneRight', true);
          return false;
        } else {
          return true;
        }
      };

      Boxes.prototype.validateZoneY = function(point, box) {
        Logger.debug("validateZoneY: @zone.bound.top " + this.zone.bound.top + " point (" + point.x + "," + point.y + "," + point.flag + "), @zone.bound.bottom " + this.zone.bound.bottom);
        if (this.zone.bound.top > point.y) {
          box.set('crossZoneTop', true);
          return false;
        } else if (point.y > this.zone.bound.bottom) {
          box.set('crossZoneBottom', true);
          return false;
        } else {
          return true;
        }
      };

      Boxes.prototype.repairCrossZone = function(box) {
        Logger.debug("[repairCrossZone before]: crossZoneLeft: " + (box.get('crossZoneLeft')) + " crossZoneRight: " + (box.get('crossZoneRight')));
        Logger.debug("[repairCrossZone before]: crossZoneTop: " + (box.get('crossZoneTop')) + " crossZoneBottom: " + (box.get('crossZoneBottom')));
        Logger.debug("[repairCrossZone before]: x: " + (box.getXPosition()) + " y: " + (box.getYPosition()));
        if (box.get('crossZoneLeft')) {
          box.setXPosition(this.zone.bound.left);
        }
        if (box.get('crossZoneRight')) {
          box.setXPosition(this.zone.bound.right - box.getWidth());
        }
        if (box.get('crossZoneTop')) {
          box.setYPosition(this.zone.bound.top);
        }
        if (box.get('crossZoneBottom')) {
          box.setYPosition(this.zone.bound.bottom - box.getHeight());
        }
        box.set({
          crossZoneLeft: false,
          crossZoneRight: false,
          crossZoneTop: false,
          crossZoneBottom: false
        });
        Logger.debug("[repairCrossZone after]: x: " + (box.getXPosition()) + " y: " + (box.getYPosition()));
        Logger.debug("[repairCrossZone after]: crossZoneLeft: " + (box.get('crossZoneLeft')) + " crossZoneRight: " + (box.get('crossZoneRight')));
        return Logger.debug("[repairCrossZone after]: crossZoneTop: " + (box.get('crossZoneTop')) + " crossZoneBottom: " + (box.get('crossZoneBottom')));
      };

      Boxes.prototype.updateDashboardStatus = function() {
        var settledStatuses;
        settledStatuses = _.reduce(this.models, (function(status, aBox) {
          Logger.debug("[updateDashboardStatus]: Box" + (aBox.getTitleName()) + " settledStatus " + (aBox.get('settledStatus')));
          return status && aBox.get('settledStatus');
        }), true);
        if (settledStatuses) {
          $('#createNewBox').prop("disabled", false);
          return $("button.placeCurrentBox").each(function() {
            return $(this).prop("disabled", true);
          });
        } else {
          $('#createNewBox').prop("disabled", true);
          return $("button.placeCurrentBox").each(function() {
            return $(this).prop("disabled", false);
          });
        }
      };

      Boxes.prototype.updateBinders = function() {
        this.rivetsBinder.unbind();
        this.rivetsBinder = rivets.bind($('.boxes'), {
          boxes: this
        });
        this.rivetsBinderCurrentBox.unbind();
        this.rivetsBinderCurrentBox = rivets.bind($('.currentBox'), {
          currentBox: this.otherCurrentBox
        });
        return Logger.debug("[updateBinders]: " + this.flash);
      };

      Boxes.prototype.showFlash = function() {
        return this.flash;
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
            return Logger.debug("In makeUnCollisionRelationAll: Pair" + this.boxId + ", withBox" + (aRelation.get('boxId')) + " " + (aRelation.get('status')));
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
          return Logger.debug("In CollisionUtil: pair." + (pair.pprint()));
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
        Logger.debug("removeCollisionPair: box" + (boxA.getBoxId()) + ", box" + (boxB.getBoxId()));
        this.updateCollisionRelationBetween({
          action: 'remove',
          boxAId: boxA.getBoxId(),
          boxBId: boxB.getBoxId()
        });
        Logger.debug("@isCollisionInclude(boxA) " + (this.isCollisionInclude(boxA)) + "  isCollisionInclude(boxB) " + (this.isCollisionInclude(boxB)));
        if (!this.isCollisionInclude(boxA)) {
          boxA.makeUnCollisionStatus();
        }
        if (!this.isCollisionInclude(boxB)) {
          return boxB.makeUnCollisionStatus();
        }
      };

      CollisionUtil.prototype.addCollisionPair = function(boxA, boxB) {
        Logger.debug("addCollisionPair: box" + (boxA.getBoxId()) + ", box" + (boxB.getBoxId()));
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
          Logger.debug("CollisionUtil:\t addPair:  box" + boxAPair.boxId + " box" + boxBPair.boxId);
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
          Logger.debug("CollisionUtil:\t removePair:  box" + boxAPair.boxId + " box" + boxBPair.boxId);
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
            Logger.debug("In delete: toDeletedBoxId: " + toDeletedBoxId);
            Logger.debug("In delete: pair Relation: " + (pair.pprint()));
            return Logger.debug("In delete: toDeletedBoxPair Relation: " + (toDeletedBoxPair.pprint()));
          }), this);
        } else if (options.action === 'changeID') {
          Logger.debug("CollisionUtil:\t changeID box");
        }
        Logger.debug("---->Show pair status: ");
        this.pprint();
        return Logger.debug("<----Show pair status: ");
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
          Logger.debug("testCollision -> inner-inner");
          boxATop = boxA.getYPosition();
          boxABottom = boxA.getYPosition() + boxA.getHeight();
          boxALeft = boxA.getXPosition();
          boxARight = boxA.getXPosition() + boxA.getWidth();
          boxBTop = boxB.getYPosition();
          boxBBottom = boxB.getYPosition() + boxB.getHeight();
          boxBLeft = boxB.getXPosition();
          boxBRight = boxB.getXPosition() + boxB.getWidth();
        } else if (options.collisionType === 'outer-outer') {
          if (boxA.hasOuterRect()) {
            Logger.debug("testCollision -> inner-inner  boxA:" + (boxA.getTitleName()) + " outer");
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
            Logger.debug("testCollision -> inner-inner  boxB:" + (boxB.getTitleName()) + " outer");
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
        Logger.debug("testCollisionBetween: box" + (boxA.getBoxId()) + " box" + (boxB.getBoxId()) + " " + status);
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
        var boxByRatio, boxes_params, color_coordinate, coordinateOriginPoint, longerEdge, margin, overhangBackground, overhangOffset, pallet, palletBackground, shorterEdge, stageBackground, xLabel, xLine, yLabel, yLine;
        pallet = params.pallet;
        longerEdge = Math.max(pallet.width, pallet.height);
        shorterEdge = Math.min(pallet.width, pallet.height);
        Logger.debug("pallet.overhang: " + pallet.overhang + ", box.minDistance: " + box.minDistance + ", margin: " + margin);
        margin = pallet.overhang;
        overhangOffset = {
          x: 0,
          y: 0
        };
        if (margin > 0) {
          this.ratio = Math.min(params.stage.height / (longerEdge + 2 * margin), params.stage.width / (shorterEdge + 2 * margin));
        } else {
          overhangOffset.x = overhangOffset.y = 0 - margin;
          margin = 0;
          this.ratio = Math.min(params.stage.height / (longerEdge + 2 * margin), params.stage.width / (shorterEdge + 2 * margin));
        }
        stageBackground = new Kinetic.Rect({
          x: 0,
          y: 0,
          width: params.stage.width,
          height: params.stage.height,
          fillRed: params.color.stage.red,
          fillGreen: params.color.stage.green,
          fillBlue: params.color.stage.blue
        });
        palletBackground = new Kinetic.Rect({
          x: margin * this.ratio,
          y: margin * this.ratio,
          width: shorterEdge * this.ratio,
          height: longerEdge * this.ratio,
          fillRed: params.color.pallet.red,
          fillGreen: params.color.pallet.green,
          fillBlue: params.color.pallet.blue
        });
        this.zone = {
          x: overhangOffset.x * this.ratio,
          y: overhangOffset.y * this.ratio,
          width: (shorterEdge + pallet.overhang * 2) * this.ratio,
          height: (longerEdge + pallet.overhang * 2) * this.ratio,
          bound: {
            top: overhangOffset.y * this.ratio,
            bottom: overhangOffset.y * this.ratio + (longerEdge + pallet.overhang * 2) * this.ratio,
            left: overhangOffset.x * this.ratio,
            right: overhangOffset.x * this.ratio + (shorterEdge + pallet.overhang * 2) * this.ratio
          }
        };
        overhangBackground = new Kinetic.Rect({
          x: this.zone.x,
          y: this.zone.y,
          width: this.zone.width,
          height: this.zone.height,
          strokeRed: params.color.overhang.stroke.red,
          strokeGreen: params.color.overhang.stroke.green,
          strokeBlue: params.color.overhang.stroke.blue,
          strokeAlpha: params.color.overhang.stroke.alpha
        });
        overhangBackground.dash([4, 5]);
        this.stage = new Kinetic.Stage({
          container: "canvas_container",
          width: params.stage.width * params.stage.stage_zoom,
          height: params.stage.height * params.stage.stage_zoom
        });
        this.layer = new Kinetic.Layer();
        color_coordinate = {
          red: 67,
          green: 123,
          blue: 188
        };
        this.palletZone = {
          bound: {
            top: margin * this.ratio,
            bottom: (margin + longerEdge) * this.ratio,
            left: margin * this.ratio,
            right: (margin + shorterEdge) * this.ratio
          }
        };
        coordinateOriginPoint = {
          x: this.palletZone.bound.left,
          y: this.palletZone.bound.bottom
        };
        xLine = new Kinetic.Line({
          points: [coordinateOriginPoint.x, coordinateOriginPoint.y, this.palletZone.bound.right * 0.2, coordinateOriginPoint.y, this.palletZone.bound.right * 0.2 - 15, coordinateOriginPoint.y - 3, this.palletZone.bound.right * 0.2, coordinateOriginPoint.y, this.palletZone.bound.right * 0.2 - 15, coordinateOriginPoint.y + 3],
          strokeRed: color_coordinate.red,
          strokeGreen: color_coordinate.green,
          strokeBlue: color_coordinate.blue,
          strokeWidth: 2,
          lineCap: "round",
          lineJoin: "round"
        });
        xLabel = new Kinetic.Text({
          x: this.palletZone.bound.right * 0.2,
          y: coordinateOriginPoint.y - 5,
          fontSize: 13,
          fontFamily: "Calibri",
          fill: "blue",
          text: 'X'
        });
        yLine = new Kinetic.Line({
          points: [coordinateOriginPoint.x - 3, this.palletZone.bound.top + this.palletZone.bound.bottom * 0.82 + 15, coordinateOriginPoint.x, this.palletZone.bound.top + this.palletZone.bound.bottom * 0.82, coordinateOriginPoint.x + 3, this.palletZone.bound.top + this.palletZone.bound.bottom * 0.82 + 15, coordinateOriginPoint.x, this.palletZone.bound.top + this.palletZone.bound.bottom * 0.82, coordinateOriginPoint.x, coordinateOriginPoint.y],
          strokeRed: color_coordinate.red,
          strokeGreen: color_coordinate.green,
          strokeBlue: color_coordinate.blue,
          strokeWidth: 2,
          lineCap: "round",
          lineJoin: "round"
        });
        yLabel = new Kinetic.Text({
          x: coordinateOriginPoint.x - 2,
          y: this.palletZone.bound.top + this.palletZone.bound.bottom * 0.82 - 15,
          fontSize: 13,
          fontFamily: "Calibri",
          fill: "blue",
          text: 'Y'
        });
        this.layer.add(stageBackground);
        this.layer.add(palletBackground);
        this.layer.add(overhangBackground);
        this.layer.add(xLine);
        this.layer.add(yLine);
        this.layer.add(xLabel);
        this.layer.add(yLabel);
        this.stage.add(this.layer);
        Logger.debug("StackBoard: Stage Initialized!");
        Logger.info("StackBoard: Initialized!");
        boxByRatio = {
          x: params.box.x,
          y: params.box.y,
          width: params.box.width * this.ratio,
          height: params.box.height * this.ratio,
          minDistance: params.box.minDistance * this.ratio
        };
        boxes_params = {
          layer: this.layer,
          zone: this.zone,
          box: boxByRatio,
          color: params.color,
          ratio: this.ratio,
          palletOverhang: pallet.overhang
        };
        boxes_params.knob = params.knob;
        this.boxes = new Boxes(boxes_params);
        this.boxes.shift();
      }

      return StackBoard;

    })();
    canvasStage = {
      width: 280,
      height: 360,
      stage_zoom: 1.5
    };
    color = {
      stage: {
        red: 255,
        green: 255,
        blue: 255
      },
      pallet: {
        red: 251,
        green: 209,
        blue: 175
      },
      overhang: {
        stroke: {
          red: 238,
          green: 49,
          blue: 109,
          alpha: 0.5
        }
      },
      boxPlaced: {
        inner: {
          red: 79,
          green: 130,
          blue: 246,
          alpha: 0.8,
          stroke: {
            red: 147,
            green: 218,
            blue: 87,
            alpha: 0.5
          }
        },
        outer: {
          red: 0,
          green: 0,
          blue: 0,
          alpha: 0,
          stroke: {
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0
          }
        }
      },
      boxSelected: {
        collision: {
          inner: {
            red: 255,
            green: 0,
            blue: 0,
            alpha: 1,
            stroke: {
              red: 147,
              green: 218,
              blue: 87,
              alpha: 0.5
            }
          },
          outer: {
            red: 255,
            green: 0,
            blue: 0,
            alpha: 0.5,
            stroke: {
              red: 255,
              green: 0,
              blue: 0,
              alpha: 0.5
            }
          }
        },
        uncollision: {
          inner: {
            red: 108,
            green: 153,
            blue: 57,
            alpha: 1,
            stroke: {
              red: 72,
              green: 82,
              blue: 38,
              alpha: 0.5
            }
          },
          outer: {
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0,
            stroke: {
              red: 70,
              green: 186,
              blue: 3,
              alpha: 0.5
            }
          }
        }
      }
    };
    pallet = {
      width: 200,
      height: 250,
      overhang: 10
    };
    box = {
      x: 0,
      y: 0,
      width: 60,
      height: 20,
      minDistance: 10
    };
    params = {
      pallet: pallet,
      box: box,
      stage: canvasStage,
      color: color
    };
    this.board = new StackBoard(params);
    rivets.formatters.suffix_cm = function(value) {
      return "" + (Math.abs(value.toFixed(0)));
    };
    rivets.formatters.availableNewTitle = function(value) {
      return "" + (value + 100);
    };
    $("input").prop("readonly", true);
    $("input.dial").prop("readonly", false);
    $("#hide_button").click(function() {
      $("#right_board").animate({
        marginLeft: "-100%"
      }, 1000, function() {
        return $("#right_board").hide();
      });
    });
    return $("#show_button").click(function() {
      $("#right_board").show();
      $("#right_board").animate({
        marginLeft: "20%"
      }, 1000);
    });
  });

}).call(this);

/*
//@ sourceMappingURL=app.js.map
*/
