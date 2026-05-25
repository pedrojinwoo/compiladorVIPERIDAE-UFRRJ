/*Compilador VIPERIDAE*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main() {
        int _t1;
        int _t2;
        char _t3;
        int _t4;
        int _t5;
        int _t6;
        int _t7;
        int _t8;
        int _t9;
        int _t10;

        _t2 = 0;
        _t1 = _t2;
        WHILESTART_1:
        _t3 = '\n';
        _t5 = (int) _t3;
        _t4 = _t1 != _t5;
        _t6 = -1;
        _t7 = _t1 != _t6;
        _t8 = _t4 && _t7;
        _t9 = !_t8;
        if(_t9) goto WHILEEND_1;
        _t10 = 1;
        _t1 = _t10;
        goto WHILESTART_1;
        WHILEEND_1:
        return 0;
}