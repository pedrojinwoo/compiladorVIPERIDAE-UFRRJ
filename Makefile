# SCANNER := flex # (LINUX/MAC)
SCANNER := win_flex # (PARA WINDOWS (INSTALADO POR WINGET))
SCANNER_PARAMS := lexico.l 
PARSER := win_bison # (PARA WINDOWS (INSTALADO POR WINGET))
# PARSER := bison # (LINUX/MAC)
PARSER_PARAMS := -d --yacc sintatico.y
CXXFLAGS := -Wno-free-nonheap-object
FILE := testeGeral.viper

all: glf translate

compile: glf

glf: y.tab.c lex.yy.c
		g++ $(CXXFLAGS) -o glf y.tab.c

lex.yy.c: lexico.l
		$(SCANNER) $(SCANNER_PARAMS)

y.tab.c y.tab.h: sintatico.y
		$(PARSER) $(PARSER_PARAMS)

translate: glf
		glf < $(FILE)
#		./glf < $(FILE) # (PARA LINUX/MAC)

.SILENT:
winRun: glf
	@
		glf < testeGeral.viper > output.c && \
		type output.c && \
		echo. && \
		gcc output.c -o exec.exe && \
		exec.exe && \
		del /f /q output.c exec.exe && \
		del /f /q y.tab.c y.tab.h lex.yy.c glf.exe && \
		echo. && \
		echo. && \
		echo.  \

.SILENT:
linuxRun: glf
	glf < testeGeral.viper > output.c
	cat output.c
	echo ""
	gcc output.c -o exec.exe
	./exec.exe
	rm -f output.c exec.exe
	rm -f y.tab.c y.tab.h lex.yy.c glf.exe;
	echo ""
	echo ""
	echo ""

ifndef DIR
winExtra:
	$(ERROR Erro: Pasta necessária)
else
FILES_TO_RUN := $(wildcard $(DIR)/*.viper)
winExtra: glf
	@$(foreach f,$(FILES_TO_RUN), \
		echo "$(f)" && \
		glf < $(f) > output.c && \
		type output.c && \
		echo. && \
		gcc output.c -o exec.exe && \
		exec.exe && \
		del /f /q output.c exec.exe && \
		echo. && \
		echo. && \
		echo.  && \
	) echo. && \
	del /f /q y.tab.c y.tab.h lex.yy.c glf.exe
endif

ifndef DIR
linuxExtra:
	$(ERROR erro: Pasta necessária)
else
FILES_TO_RUN := $(wildcard $(DIR)/*.viper)
linuxExtra: glf
	for f in $(FILES_TO_RUN); do \
		echo "$$f" ; \
		glf < $$f > output.c ; \
		cat output.c ; \
		echo "" ; \
		gcc output.c -o exec.exe ; \
		./exec.exe ; \
		rm -f output.c exec.exe ; \
		rm -f y.tab.c y.tab.h lex.yy.c glf.exe
		echo "" ; \
		echo "" ; \
		echo "" ; \
	done
endif

clean:
	del /f /q y.tab.c y.tab.h lex.yy.c glf.exe