
.PHONY : compile
compile:
	lex ../src/lexer.l 
	yacc -d ../src/parser.y 
	gcc -o out lex.yy.c y.tab.c -ll  
.PHONY: clean
clean:
	rm out y.tab.c y.tab.h
	rm -rf out

filename= $(basename $(file))
.PHONE :run
run:
	@echo "Compiling $(filename)"
	./out "../test/$(file)"
	@echo "------------------------------------------------------------------------------------"
	@echo "Cpp file created at  ../test/$(filename).cpp" 
	@echo "------------------------------------------------------------------------------------"
	@echo "Formatting the cpp file: $(filename)"
	clang-format -i  "../test/$(filename).cpp"
	@echo "Fomratting Completed"
debug:
	lldb ./out "../test/$(file)"


		

