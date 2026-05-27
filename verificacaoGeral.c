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
        int _t11;
        int _t12;
        int _t13;
        int _t14;
        int _t15;
        int _t16;
        int _t17;
        int _t18;
        int _t19;
        int _t20;

        _t2 = 1;
        _t1 = _t2;
        _t3 = 0;
        _t4 = _t1 == _t3;
        _t5 = !_t4;
        if(_t5) goto IFELSE_1;
        _t6 = 0;
        printf("%d\n", _t6);
        goto IFEND_1;
        IFELSE_1:
        _t7 = 1;
        _t8 = _t1 == _t7;
        _t19 = !_t8;
        if(_t19) goto ELIF1_1;
        _t9 = 1;
        printf("%d\n", _t9);
        _t10 = 0;
        _t11 = _t1 == _t10;
        _t12 = !_t11;
        if(_t12) goto IFELSE_2;
        _t13 = 0;
        printf("%d\n", _t13);
        goto IFEND_2;
        IFELSE_2:
        _t14 = 1;
        _t15 = _t1 == _t14;
        _t17 = !_t15;
        if(_t17) goto ELIF2_0;
        _t16 = 1;
        printf("%d\n", _t16);
        goto IFEND_2;
        ELIF2_0:
        _t18 = 2;
        printf("%d\n", _t18);
        IFEND_2:
        goto IFEND_1;
        ELIF1_1:
        _t20 = 2;
        printf("%d\n", _t20);
        IFEND_1:
        return 0;
}