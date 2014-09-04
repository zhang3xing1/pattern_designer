(function() {
  define(function() {
    var Logger;
    Logger = (function() {
      var Horn, instance, statuses;

      function Logger() {}

      instance = null;

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
          return console.log(instance.debug(message));
        }
      };

      return Logger;

    })();
    return {
      create: Logger
    };
  });

}).call(this);

/*
//@ sourceMappingURL=logger.js.map
*/
