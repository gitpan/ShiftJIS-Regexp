use ShiftJIS::Regexp qw(:all);

for(qw/
 [A-A]
 [\xA1-\xDf]
 [\xDF-\x{e1fc}]
 [\x7F-\x{e1fc}]
 [\x7f-\xa1]
 [\cJ-\xa2]
 [\0-\x{fcfc}]
 [\x{8F7e}-\xe1\xfc]
 [\x{8140}-\x{fcfc}]
 [\x{9e80}-\x{e0fc}]
 [\x{9e80}-\x{e081}]
 [\x{9e80}-\x{e080}]
 [\x{9e80}-\x{e07e}]
 [\x{9e80}-\x{e1fc}]
 [\x{9e7e}-\x{e0fc}]
 [\x{85aa}-\x{85aa}]
 [\x{9f7e}-\x{e0fc}]
 [\x{9e80}-\x{e1fc}]
 [\x{9d40}-\x{e1fc}]
 [\x{9e80}-\x{e17e}]
 [\x{8efc}-\x{e040}\x{fcfc}-\x{fcfc}]
 [\x{84fa}-\x{e240}]
 [\x{9ffc}-\x{e040}]
 [\x{9ffb}-\x{e041}]
 [\x{9f7e}-\x{e080}\x{fcfc}]
/){
 print $_,"\n    ",re($_),"\n";
}
