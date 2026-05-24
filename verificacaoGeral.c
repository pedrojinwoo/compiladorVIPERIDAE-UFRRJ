/*Compilador VIPERIDAE*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char _stringBuffer[10];
int _stringLength(char* _str);
void _keyboardCleanup();

int main() {
        char* _t1;
        char* _t2;
        int _t3;
        int _t4;

        scanf(" %5[^\n/]", _stringBuffer);
        //_keyboardCleanup();
        _t3 = _stringLength(_stringBuffer);
        _t1 = (char*)malloc(_t3);
        strcpy(_t1, _stringBuffer);
        scanf(" %5[^\n/]", _stringBuffer);
        //_keyboardCleanup();
        _t4 = _stringLength(_stringBuffer);
        _t2 = (char*)malloc(_t4);
        strcpy(_t2, _stringBuffer);
        printf("%s\n", _t1);
        printf("%s\n", _t2);
        return 0;
}

int _stringLength(char* _str) {
        int _len;
        char _tChar;
        char _tStrClose;
        int _temp1;
         int _tCond;

        _len = 0;
        _tChar = _str[_len];
        _tStrClose = '\0';
        _temp1 = _tChar != _tStrClose;
        _tCond = _temp1;
        while(_tCond) {
                _len++;
                _tChar = _str[_len];
                _temp1 = _tChar != _tStrClose;
                _tCond = _temp1;
        }
        _len++;
        return _len;
}
/*void _keyboardCleanup() {
        char _c1;
        char _c2;
        int _cTemp1;
        int _c3;
        int _cTemp2;
        int _c4;
        int _cTemp3;
        int _c5;

        _c1 = getchar();
        _c2 = '\n';
        _cTemp1 = _c1 != _c2;
        _c3 = _cTemp1;
        _cTemp2 = _c1 != EOF;
        _c4 = _cTemp2;
        _cTemp3 = _c3 && _c4;
        _c5 = _cTemp3;
        while(_c5) {
                _c1 = getchar();
                _cTemp1 = _c1 != _c2;
                _c3 = _cTemp1;
                _cTemp2 = _c1 != EOF;
                _c4 = _cTemp2;
                _cTemp3 = _c3 && _c4;
                _c5 = _cTemp3;
        }
}*/