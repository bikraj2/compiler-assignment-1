
.PHONY : compile
compile:
	lex ../src/lexer.l 
	yacc -d ../src/parser.y 
	gcc -o out lex.yy.c y.tab.c -ll  
.PHONY: clean
clean:
	rm out y.tab.c y.tab.h
	rm -rf *.out

filename= $(basename $(file))
.PHONE :run
run:
	@echo "Compiling $(filename)"
	./out "../test/input/$(file)"
	@echo "------------------------------------------------------------------------------------"
	@echo "Cpp file created at  ../test/output/$(filename).cpp" 
	@echo "------------------------------------------------------------------------------------"
	@echo "Formatting the cpp file: $(filename)"
	clang-format -i  "../test/output/$(filename).cpp"
	@echo "Fomratting Completed"
	@echo "Compiling CPP File"
	g++ ../test/output/$(filename).cpp
	./a.out > ../test/printed/$(filename).txt

debug:
	lldb ./out "../test/$(file)"


		

