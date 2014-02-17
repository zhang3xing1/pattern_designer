describe 'Box', ->
  it 'should have a default X position', ->
    s = new Box 
    expect(s.get('xPosition')).toBe(10)


