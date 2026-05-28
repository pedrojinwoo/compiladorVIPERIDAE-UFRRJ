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
run: glf
		@
			glf < testeGeral.viper > output.c && \
			type output.c && \
			echo. && \
			gcc output.c -o exec.exe && \
			exec.exe && \
			del /f /q output.c exec.exe && \
			echo. && \
			echo. && \
			echo.  \

ifndef DIR
extra:
	$(ERROR Erro: Pasta necessária)
else
FILES_TO_RUN := $(wildcard $(DIR)/*.viper)
extra: glf
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
		echo.  \
	)
endif

clean:
	del /f /q y.tab.c y.tab.h lex.yy.c glf.exe