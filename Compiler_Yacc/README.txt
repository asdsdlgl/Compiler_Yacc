30分的加分題都有做實作
IF_ELSE 的實作Grammer使用
A : IF'(' relation ')' '{' dlcs '}'
    | IF'(' relation ')' '{' dlcs '}' ELSE '{' dlcs '}'
    | IF'(' relation ')' '{' dlcs '}' ELSE A
當不斷的CALL IF_ELSE可以不斷的遞迴下去

Scope利用多在struct中多設立一個block的範圍作為判斷
，當遇到'{'就block往上加，當遇到'}'就減回去，並且當
在Scope範圍內可以宣告然後放入Table中，並且在block結束後free掉