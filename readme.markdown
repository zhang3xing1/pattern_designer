1. line in and line out are not the same value;   -- ok

2. tool setting in box picking page;   --ok 

2.1 edit frame info in frame page and tool info in box picking page -- ok

2.1 calculate the tool data by moving tcp to the center of box -- todo after discussion

3. temp mission data save, especially layer data; -- almost ok.

4. load pallet size infomation after getting detail info from multipack

5. animation when transitting

6. csv review -- ok

7. implement tcp




UI Validator
1. Layer_name cannot contain blank char.

UI function:

1. Mission rename
2. Mission update
3. Mission load
4. Mission delete
5. Mission create
6. Mission edit, some validators.

7. sleepsheet height


PDL:

1. cross site request



Time delay problem:


inteval time should be considered. 

if the inteval time of two requesest is too short, the result could be wrong.
for exapmle: frame line in, frame line out.

in load mission data page, I try load 3 times load mission, worked in my macbook.


layer and used_layers connected by ulid 