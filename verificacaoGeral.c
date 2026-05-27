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
        int _t8;
        int _t9;
        int _t10;

        _t2 = 0;
        _t1 = _t2;
        _t3 = 0;
        _t10 = _t1 == _t3;
        if(_t10) goto CASE1_1;
        goto SWITCHEND_1;
        CASE1_1:
        _t4 = 1;
        printf("%d\n", _t4);
        _t6 = 0;
        _t5 = _t6;
        _t7 = 0;
        _t9 = _t1 == _t7;
        if(_t9) goto CASE2_0;
        goto SWITCHEND_2;
        CASE2_0:
        _t8 = 2;
        printf("%d\n", _t8);
        goto SWITCHEND_2;
        SWITCHEND_2:
        goto SWITCHEND_1;
        SWITCHEND_1:
        return 0;
}