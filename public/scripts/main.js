(function() {
  require.config({
    baseUrl: "./scripts",
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
      bootstrap: 'lib/bootstrap',
      jqueryMultiSelect: 'lib/jquery.multi-select'
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

  require(['rivets', 'router', "app"], function(rivets, Router, App) {
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
    window.router = Router.create;
  });

}).call(this);

/*
//@ sourceMappingURL=main.js.map
*/
