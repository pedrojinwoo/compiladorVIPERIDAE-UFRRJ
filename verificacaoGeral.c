/*Compilador VIPERIDAE*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main() {
        int _t1;
        int _t2;
        int _t3;
        int _t4;
        int _t5;
        int _t6;
        int _t7;

        _t2 = 0;
        _t1 = _t2;
        WHILESTART_1:
        _t3 = 5;
        _t4 = _t1 < _t3;
        _t5 = !_t4;
        if(_t5) goto WHILEEND_1;
        _t6 = 1;
        _t7 = _t1 + _t6;
        _t1 = _t7;
        printf("%d\n", _t1);
        goto WHILESTART_1;
        WHILEEND_1:
        return 0;
}