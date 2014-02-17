(function() {
  describe('Box', function() {
    return it('should have a default X position', function() {
      var s;
      s = new Box;
      return expect(s.get('xPosition')).toBe(10);
    });
  });

}).call(this);
