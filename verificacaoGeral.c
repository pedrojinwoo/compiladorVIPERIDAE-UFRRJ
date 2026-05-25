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
        _t8 = 1;
        printf("%d\n", _t8);
        WHILESTART_2:
        _t9 = 5;
        _t10 = _t1 < _t9;
        _t11 = !_t10;
        if(_t11) goto WHILEEND_2;
        _t12 = 1;
        _t13 = _t1 + _t12;
        _t1 = _t13;
        _t14 = 2;
        printf("%d\n", _t14);
        WHILESTART_3:
        _t15 = 5;
        _t16 = _t1 < _t15;
        _t17 = !_t16;
        if(_t17) goto WHILEEND_3;
        _t18 = 1;
        _t19 = _t1 + _t18;
        _t1 = _t19;
        _t20 = 3;
        printf("%d\n", _t20);
        goto WHILEEND_1;
        goto WHILESTART_3;
        WHILEEND_3:
        goto WHILESTART_2;
        WHILEEND_2:
        goto WHILESTART_1;
        WHILEEND_1:
        return 0;
}